import '../detectors/detector.dart';
import '../detectors/levels_detector.dart';
import '../detectors/ma_regime_detector.dart';
import '../detectors/structure_detector.dart';
import '../domain/models.dart';
import 'exchanges/binance_client.dart';
import 'exchanges/bybit_client.dart';
import 'exchanges/exchange_client.dart';
import 'exchanges/gate_client.dart';
import 'symbol_universe.dart';

typedef ProgressCb = void Function(ScanProgress progress);

class _Job {
  _Job(this.exchange, this.tf, this.symbol);
  final ExchangeId exchange;
  final AppTimeframe tf;
  final MarketSymbol symbol;
}

class MarketRepository {
  MarketRepository({
    Map<ExchangeId, ExchangeClient>? clients,
    List<Detector>? detectors,
    this.concurrency = 4,
  })  : clients = clients ??
            {
              ExchangeId.binance: BinanceClient(),
              ExchangeId.bybit: BybitClient(),
              ExchangeId.gate: GateClient(),
            },
        detectors = detectors ??
            [
              StructureShiftDetector(),
              MaRegimeDetector(),
              LevelsDetector(),
            ];

  final Map<ExchangeId, ExchangeClient> clients;
  final List<Detector> detectors;
  final int concurrency;

  Future<List<Detection>> scan(
    ScanRequest request, {
    ProgressCb? onProgress,
    bool Function()? isCancelled,
  }) async {
    final exchanges = request.exchanges.toList();
    final timeframes = request.timeframes.toList();
    final activeDetectors =
        detectors.where((d) => request.detectors.contains(d.kind)).toList();
    final symbols = SymbolUniverse.symbols;

    final jobs = <_Job>[
      for (final exchange in exchanges)
        for (final tf in timeframes)
          for (final symbol in symbols) _Job(exchange, tf, symbol),
    ];

    final total = jobs.length;
    var done = 0;
    final hits = <Detection>[];

    Future<void> runJob(_Job job) async {
      if (isCancelled?.call() == true) return;
      final client = clients[job.exchange];
      if (client == null) return;

      onProgress?.call(ScanProgress(
        done: done,
        total: total,
        label: '${job.exchange.short} · ${job.symbol.display} · ${job.tf.label}',
      ));

      try {
        final candles = await client.fetchCandles(
          symbol: job.symbol,
          timeframe: job.tf,
          limit: 240,
        );
        for (final det in activeDetectors) {
          hits.addAll(
            det.detect(
              exchange: job.exchange,
              symbol: job.symbol,
              timeframe: job.tf,
              candles: candles,
            ),
          );
        }
      } catch (_) {
        // Skip failures.
      } finally {
        done++;
        onProgress?.call(ScanProgress(
          done: done,
          total: total,
          label: '${job.exchange.short} · ${job.symbol.display} · ${job.tf.label}',
        ));
      }
    }

    for (var i = 0; i < jobs.length; i += concurrency) {
      if (isCancelled?.call() == true) break;
      final slice = jobs.skip(i).take(concurrency).toList();
      await Future.wait(slice.map(runJob));
      await Future<void>.delayed(const Duration(milliseconds: 12));
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
