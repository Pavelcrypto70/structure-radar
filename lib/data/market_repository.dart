import 'package:flutter/foundation.dart';

import '../detectors/detector.dart';
import '../detectors/levels_detector.dart';
import '../detectors/ma_regime_detector.dart';
import '../detectors/structure_detector.dart';
import '../domain/models.dart';
import 'exchanges/binance_client.dart';
import 'exchanges/bybit_client.dart';
import 'exchanges/exchange_client.dart';
import 'exchanges/gate_client.dart';
import 'universe_service.dart';

typedef ProgressCb = void Function(ScanProgress progress);
typedef PartialCb = void Function(List<Detection> partial);

class _Job {
  _Job(this.entry, this.tf);
  final UniverseEntry entry;
  final AppTimeframe tf;
}

/// Tiny async mutex so web never stampeding the public market-data host.
class _Gate {
  Future<void> _tail = Future.value();

  Future<T> schedule<T>(Future<T> Function() run, {Duration gap = Duration.zero}) {
    final starter = _tail;
    late final Future<T> mine;
    mine = starter.then((_) async {
      if (gap > Duration.zero) await Future<void>.delayed(gap);
      return run();
    });
    _tail = mine.then((_) {}, onError: (_) {});
    return mine;
  }
}

class MarketRepository {
  MarketRepository({
    Map<ExchangeId, ExchangeClient>? clients,
    List<Detector>? detectors,
    UniverseService? universeService,
    int? concurrency,
  })  : clients = clients ??
            {
              ExchangeId.binance: BinanceClient(),
              ExchangeId.bybit: BybitClient(),
              ExchangeId.gate: GateClient(),
            },
        detectors = detectors ??
            [
              StructureShiftDetector(lookback: 4, recentBars: 5),
              MaRegimeDetector(),
              LevelsDetector(
                minTouches: 3,
                minTouchGapBars: 4,
                minTouchSpanBars: 10,
                clusterTolAtr: 0.28,
                approachAtr: 1.25,
                tightApproachAtr: 0.7,
                breakToleranceAtr: 0.35,
              ),
            ],
        universeService = universeService ?? UniverseService(),
        concurrency = concurrency ?? (kIsWeb ? 2 : 14);

  final Map<ExchangeId, ExchangeClient> clients;
  final List<Detector> detectors;
  final UniverseService universeService;
  final int concurrency;
  final _Gate _gate = _Gate();

  int lastUniverseSize = 0;
  int lastRawPairCount = 0;
  int lastFetchOk = 0;
  int lastFetchFail = 0;
  String lastUniverseSource = '';

  Future<List<Detection>> scan(
    ScanRequest request, {
    ProgressCb? onProgress,
    PartialCb? onPartial,
    bool Function()? isCancelled,
  }) async {
    lastFetchOk = 0;
    lastFetchFail = 0;

    // Web: candles only from Binance vision (open CORS). Other venues = labels only.
    final exchangeSet = kIsWeb
        ? ({ExchangeId.binance}.intersection(request.exchanges).isNotEmpty
            ? {ExchangeId.binance}
            : request.exchanges)
        : request.exchanges;

    final timeframes = request.timeframes.toList();
    final activeDetectors =
        detectors.where((d) => request.detectors.contains(d.kind)).toList();

    onProgress?.call(ScanProgress(done: 0, total: 1, label: 'Universe…'));
    var universe = await universeService.build(
      exchanges: kIsWeb ? exchangeSet : request.exchanges,
      clients: clients,
      lightweight: false,
    );
    if (universe.symbols.isEmpty) {
      universe = await universeService.build(
        exchanges: exchangeSet,
        clients: clients,
        forceRefresh: true,
        lightweight: true,
      );
    }
    lastUniverseSize = universe.symbols.length;
    lastRawPairCount = universe.rawPairCount;
    lastUniverseSource = universe.source;

    if (universe.symbols.isEmpty) {
      throw StateError('EMPTY_UNIVERSE');
    }

    // Keep web under Binance weight limits: fewer pairs, still mid/small-cap heavy.
    final maxPairs = kIsWeb ? 80 : universe.symbols.length;
    final entries = universe.symbols.take(maxPairs).toList();
    lastUniverseSize = entries.length;

    // Attach also-on from the original multi-venue selection for UI.
    if (kIsWeb && request.exchanges.length > 1) {
      final also = request.exchanges.where((e) => e != ExchangeId.binance).toList();
      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        entries[i] = UniverseEntry(
          primaryExchange: e.primaryExchange,
          symbol: e.symbol.copyWith(
            alsoListedOn: {
              ...e.symbol.alsoListedOn,
              ...also,
            }.where((x) => x != e.primaryExchange).toList(),
          ),
        );
      }
    }

    final jobs = <_Job>[
      for (final entry in entries)
        for (final tf in timeframes) _Job(entry, tf),
    ];

    final total = jobs.length;
    var done = 0;
    final hits = <Detection>[];
    var nextPartialAt = 1;
    final gap = kIsWeb ? const Duration(milliseconds: 120) : Duration.zero;

    Future<void> runJob(_Job job) async {
      if (isCancelled?.call() == true) return;
      var exchange = job.entry.primaryExchange;
      if (kIsWeb && clients.containsKey(ExchangeId.binance)) {
        exchange = ExchangeId.binance;
      }
      final client = clients[exchange];
      if (client == null) return;

      final sym = job.entry.symbol;
      try {
        final candles = await _gate.schedule(
          () => _fetchCandlesWithRetry(
            client: client,
            symbol: sym,
            timeframe: job.tf,
          ),
          gap: gap,
        );
        if (isCancelled?.call() == true) return;
        if (candles.isEmpty) {
          lastFetchFail++;
          return;
        }
        lastFetchOk++;
        final local = <Detection>[];
        for (final det in activeDetectors) {
          local.addAll(
            det.detect(
              exchange: exchange,
              symbol: sym,
              timeframe: job.tf,
              candles: candles,
            ),
          );
        }
        if (local.isNotEmpty) {
          hits.addAll(local);
          final snapshot = _finalize(hits, request.minScore);
          if (snapshot.length >= nextPartialAt) {
            nextPartialAt = snapshot.length + 1;
            onPartial?.call(snapshot);
          }
        }
      } catch (_) {
        lastFetchFail++;
      } finally {
        done++;
        if (done == 1 || done % 4 == 0 || done == total) {
          onProgress?.call(ScanProgress(
            done: done,
            total: total,
            label: '${exchange.short} · ${sym.display} · ${job.tf.label}',
          ));
        }
      }
    }

    var next = 0;
    Future<void> worker() async {
      while (true) {
        if (isCancelled?.call() == true) return;
        final i = next++;
        if (i >= jobs.length) return;
        await runJob(jobs[i]);
      }
    }

    final workers = List.generate(
      concurrency.clamp(1, 32),
      (_) => worker(),
    );
    await Future.wait(workers);

    if (lastFetchOk == 0 && lastFetchFail > 0) {
      throw StateError('ALL_FETCHES_FAILED');
    }

    onProgress?.call(ScanProgress(done: total, total: total, label: 'Done'));
    return _finalize(hits, request.minScore);
  }

  Future<List<Candle>> _fetchCandlesWithRetry({
    required ExchangeClient client,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
  }) async {
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await client.fetchCandles(
          symbol: symbol,
          timeframe: timeframe,
          limit: 220,
        );
      } catch (e) {
        final msg = '$e';
        final is429 = msg.contains('429') || msg.contains('Too Many');
        if (!is429 || attempt >= 3) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
      }
    }
  }

  List<Detection> _finalize(List<Detection> hits, double minScore) {
    final filtered = hits.where((d) => d.score >= minScore).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return filtered;
  }
}
