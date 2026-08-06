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

class _Gate {
  Future<void> _tail = Future.value();

  Future<T> schedule<T>(
    Future<T> Function() run, {
    Duration gap = Duration.zero,
  }) {
    final starter = _tail;
    late final Future<T> mine;
    mine = starter.then((_) async {
      if (gap > Duration.zero) {
        await Future<void>.delayed(gap);
      }
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
  }) : clients =
           clients ??
           {
             ExchangeId.binance: BinanceClient(),
             ExchangeId.bybit: BybitClient(),
             ExchangeId.gate: GateClient(),
           },
       detectors =
           detectors ??
           [
             StructureShiftDetector(),
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
       concurrency = concurrency ?? (kIsWeb ? 1 : 14);

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

    // Web: never fan-out to Gate/Bybit candle APIs (CORS relays → 429).
    final scanExchanges = kIsWeb
        ? (request.exchanges.contains(ExchangeId.binance)
              ? {ExchangeId.binance}
              : {request.exchanges.first})
        : request.exchanges;

    final activeDetectors = detectors
        .where((d) => request.detectors.contains(d.kind))
        .toList();

    // Web: keep weight low, but always include 15m/30m for Levels when selected.
    final timeframes = kIsWeb
        ? _webTimeframes(request.timeframes, request.detectors)
        : request.timeframes.toList();

    onProgress?.call(ScanProgress(done: 0, total: 1, label: 'Universe…'));

    // Web: lightweight universe (no multi-MB ticker) — avoids 429 before scan starts.
    final universe = await universeService.build(
      exchanges: scanExchanges,
      clients: clients,
      forceRefresh: kIsWeb,
      lightweight: kIsWeb,
    );
    lastUniverseSize = universe.symbols.length;
    lastRawPairCount = universe.rawPairCount;
    lastUniverseSource = universe.source;

    if (universe.symbols.isEmpty) {
      throw StateError('EMPTY_UNIVERSE');
    }

    // Fewer pairs when web fans out across extra TFs (15m/30m + primary).
    final maxPairs = kIsWeb
        ? (timeframes.length >= 3 ? 32 : 40)
        : universe.symbols.length;
    final entries = universe.symbols.take(maxPairs).toList();
    lastUniverseSize = entries.length;

    if (kIsWeb && request.exchanges.length > 1) {
      final also = request.exchanges
          .where((e) => e != ExchangeId.binance)
          .toList();
      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        entries[i] = UniverseEntry(
          primaryExchange: ExchangeId.binance,
          symbol: e.symbol.copyWith(
            alsoListedOn: also.where((x) => x != ExchangeId.binance).toList(),
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
    final gap = kIsWeb ? const Duration(milliseconds: 450) : Duration.zero;

    Future<void> runJob(_Job job) async {
      if (isCancelled?.call() == true) return;
      final exchange = kIsWeb ? ExchangeId.binance : job.entry.primaryExchange;
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
        // Extra cool-down after failures (likely 429).
        if (kIsWeb) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
        }
      } finally {
        done++;
        if (done == 1 || done % 2 == 0 || done == total) {
          onProgress?.call(
            ScanProgress(
              done: done,
              total: total,
              label: '${exchange.short} · ${sym.display} · ${job.tf.label}',
            ),
          );
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

    await Future.wait(List.generate(concurrency.clamp(1, 32), (_) => worker()));

    if (lastFetchOk == 0 && lastFetchFail > 0) {
      throw StateError('ALL_FETCHES_FAILED');
    }

    onProgress?.call(ScanProgress(done: total, total: total, label: 'Done'));
    return _finalize(hits, request.minScore);
  }

  /// Web TF set: one primary higher frame + 15m/30m when Levels is armed.
  List<AppTimeframe> _webTimeframes(
    Set<AppTimeframe> selected,
    Set<DetectorKind> detectors,
  ) {
    if (selected.isEmpty) return const [AppTimeframe.h4];
    final out = <AppTimeframe>{};

    final primary = _pickWebPrimaryTf(selected);
    out.add(primary);

    final levelsOn = detectors.contains(DetectorKind.levels);
    if (levelsOn) {
      if (selected.contains(AppTimeframe.m15)) out.add(AppTimeframe.m15);
      if (selected.contains(AppTimeframe.m30)) out.add(AppTimeframe.m30);
    } else {
      // No Levels → still honor explicit short TFs if that is all the user picked.
      if (primary != AppTimeframe.m15 && selected.contains(AppTimeframe.m15)) {
        out.add(AppTimeframe.m15);
      }
      if (primary != AppTimeframe.m30 && selected.contains(AppTimeframe.m30)) {
        out.add(AppTimeframe.m30);
      }
    }

    // Stable order: short → long.
    final order = [
      AppTimeframe.m15,
      AppTimeframe.m30,
      AppTimeframe.h1,
      AppTimeframe.h4,
      AppTimeframe.d1,
    ];
    return order.where(out.contains).toList();
  }

  AppTimeframe _pickWebPrimaryTf(Set<AppTimeframe> selected) {
    if (selected.contains(AppTimeframe.h4)) return AppTimeframe.h4;
    if (selected.contains(AppTimeframe.d1)) return AppTimeframe.d1;
    if (selected.contains(AppTimeframe.h1)) return AppTimeframe.h1;
    if (selected.contains(AppTimeframe.m30)) return AppTimeframe.m30;
    if (selected.contains(AppTimeframe.m15)) return AppTimeframe.m15;
    return AppTimeframe.h4;
  }

  Future<List<Candle>> fetchCandles({
    required ExchangeId exchange,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
  }) async {
    // Web: Binance vision CORS only — same as scan path.
    final ex = kIsWeb ? ExchangeId.binance : exchange;
    final client = clients[ex];
    if (client == null) {
      throw StateError('No client for ${ex.label}');
    }
    return _fetchCandlesWithRetry(
      client: client,
      symbol: symbol,
      timeframe: timeframe,
    );
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
          limit: 280,
        );
      } catch (e) {
        final msg = '$e';
        final is429 = msg.contains('429') || msg.contains('Too Many');
        if (!is429 || attempt >= 4) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 900 * attempt));
      }
    }
  }

  List<Detection> _finalize(List<Detection> hits, double minScore) {
    final filtered = hits.where((d) => d.score >= minScore).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return filtered;
  }
}
