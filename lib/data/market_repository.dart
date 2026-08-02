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
        concurrency = concurrency ?? (kIsWeb ? 6 : 18);

  final Map<ExchangeId, ExchangeClient> clients;
  final List<Detector> detectors;
  final UniverseService universeService;
  final int concurrency;

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

    final timeframes = request.timeframes.toList();
    final activeDetectors =
        detectors.where((d) => request.detectors.contains(d.kind)).toList();

    onProgress?.call(ScanProgress(done: 0, total: 1, label: 'Universe…'));
    final universe = await universeService.build(
      exchanges: request.exchanges,
      clients: clients,
      lightweight: kIsWeb,
    );
    lastUniverseSize = universe.symbols.length;
    lastRawPairCount = universe.rawPairCount;
    lastUniverseSource = universe.source;

    if (universe.symbols.isEmpty) {
      throw StateError('EMPTY_UNIVERSE');
    }

    final jobs = <_Job>[
      for (final entry in universe.symbols)
        for (final tf in timeframes) _Job(entry, tf),
    ];

    final total = jobs.length;
    var done = 0;
    final hits = <Detection>[];
    var nextPartialAt = 1;

    Future<void> runJob(_Job job) async {
      if (isCancelled?.call() == true) return;
      final client = clients[job.entry.primaryExchange];
      if (client == null) return;

      final sym = job.entry.symbol;
      try {
        final candles = await client.fetchCandles(
          symbol: sym,
          timeframe: job.tf,
          limit: 220,
        );
        if (isCancelled?.call() == true) return;
        lastFetchOk++;
        final local = <Detection>[];
        for (final det in activeDetectors) {
          local.addAll(
            det.detect(
              exchange: job.entry.primaryExchange,
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
        if (done == 1 || done % 5 == 0 || done == total) {
          onProgress?.call(ScanProgress(
            done: done,
            total: total,
            label:
                '${job.entry.primaryExchange.short} · ${sym.display} · ${job.tf.label}',
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

  List<Detection> _finalize(List<Detection> hits, double minScore) {
    final filtered = hits.where((d) => d.score >= minScore).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return filtered;
  }
}
