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

class MarketRepository {
  MarketRepository({
    Map<ExchangeId, ExchangeClient>? clients,
    List<Detector>? detectors,
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

    final total = exchanges.length * timeframes.length * symbols.length;
    var done = 0;
    final hits = <Detection>[];

    for (final exchange in exchanges) {
      final client = clients[exchange];
      if (client == null) continue;

      for (final tf in timeframes) {
        for (final symbol in symbols) {
          if (isCancelled?.call() == true) {
            return _finalize(hits, request.minScore);
          }

          onProgress?.call(ScanProgress(
            done: done,
            total: total,
            label: '${exchange.short} · ${symbol.display} · ${tf.label}',
          ));

          try {
            final candles = await client.fetchCandles(
              symbol: symbol,
              timeframe: tf,
              limit: 240,
            );
            for (final det in activeDetectors) {
              hits.addAll(
                det.detect(
                  exchange: exchange,
                  symbol: symbol,
                  timeframe: tf,
                  candles: candles,
                ),
              );
            }
          } catch (_) {
            // Skip symbol/venue failures; scan continues.
          }

          done++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      }
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
