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
              StructureShiftDetector(lookback: 5, recentBars: 3),
              MaRegimeDetector(),
              LevelsDetector(),
            ],
        universeService = universeService ?? UniverseService(),
        concurrency = concurrency ?? (kIsWeb ? 8 : 18);

  final Map<ExchangeId, ExchangeClient> clients;
  final List<Detector> detectors;
  final UniverseService universeService;
  final int concurrency;

  /// Last built universe size (for UI / recap).
  int lastUniverseSize = 0;
  int lastRawPairCount = 0;

  Future<List<Detection>> scan(
    ScanRequest request, {
    ProgressCb? onProgress,
    bool Function()? isCancelled,
  }) async {
    final exchanges = request.exchanges.toList();
    final timeframes = request.timeframes.toList();
    final activeDetectors =
        detectors.where((d) => request.detectors.contains(d.kind)).toList();

    onProgress?.call(ScanProgress(done: 0, total: 1, label: 'Universe…'));
    final universe = await universeService.build(
      exchanges: request.exchanges,
      clients: clients,
    );
    lastUniverseSize = universe.symbols.length;
    lastRawPairCount = universe.rawPairCount;

    // One primary venue per coin — duplicates only annotated on symbol.alsoListedOn.
    final jobs = <_Job>[
      for (final entry in universe.symbols)
        for (final tf in timeframes) _Job(entry, tf),
    ];

    final total = jobs.length;
    if (total == 0) {
      onProgress?.call(ScanProgress(done: 1, total: 1, label: 'Done'));
      return const [];
    }

    var done = 0;
    final hits = <Detection>[];
    final hitsLock = Object();

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
          synchronizedAdd(hits, hitsLock, local);
        }
      } catch (_) {
        // Skip dead / rate-limited pairs.
      } finally {
        done++;
        if (done % 3 == 0 || done == total) {
          onProgress?.call(ScanProgress(
            done: done,
            total: total,
            label: '${job.entry.primaryExchange.short} · ${sym.display} · ${job.tf.label}',
          ));
        }
      }
    }

    // Fixed-size worker pool — keeps sockets saturated without stampeding APIs.
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

    onProgress?.call(ScanProgress(done: total, total: total, label: 'Done'));
    return _finalize(hits, request.minScore);
  }

  void synchronizedAdd(
    List<Detection> target,
    Object lock,
    List<Detection> batch,
  ) {
    // Dart is single-threaded; lock is documentation for intent.
    target.addAll(batch);
  }

  List<Detection> _finalize(List<Detection> hits, double minScore) {
    final filtered = hits.where((d) => d.score >= minScore).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return filtered;
  }
}
