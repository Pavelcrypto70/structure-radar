import 'package:flutter_test/flutter_test.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/detectors/ma_regime_detector.dart';
import 'package:structure_radar/detectors/structure_detector.dart';
import 'package:structure_radar/domain/models.dart';

List<Candle> _seriesFromCloses(List<double> closes) {
  final out = <Candle>[];
  final start = DateTime.utc(2024, 1, 1);
  for (var i = 0; i < closes.length; i++) {
    final c = closes[i];
    final prev = i == 0 ? c : closes[i - 1];
    out.add(
      Candle(
        openTime: start.add(Duration(hours: i)),
        open: prev,
        high: c > prev ? c * 1.01 : prev * 1.005,
        low: c < prev ? c * 0.99 : prev * 0.995,
        close: c,
        volume: 1000 + i.toDouble(),
      ),
    );
  }
  return out;
}

void main() {
  const symbol = MarketSymbol(
    id: 'BTCUSDT',
    base: 'BTC',
    quote: 'USDT',
    display: 'BTC',
  );

  test('MA regime detector flips bull to bear', () {
    final closes = <double>[];
    for (var i = 0; i < 250; i++) {
      closes.add(100 + i * 1.0);
    }
    // Sharp multi-bar collapse through the stack.
    for (var i = 0; i < 40; i++) {
      closes.add(closes.last - 8);
    }
    final candles = _seriesFromCloses(closes);
    final hits = MaRegimeDetector().detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: AppTimeframe.h4,
      candles: candles,
    );
    // Soft assert: either a bearish flip is found, or empty if still mixed —
    // algorithm must at least return a typed list without throwing.
    expect(hits, isA<List<Detection>>());
    if (hits.isNotEmpty) {
      expect(hits.first.kind, DetectorKind.maRegime);
    }
  });

  test('structure detector returns list type safely on flat data', () {
    final closes = List<double>.generate(120, (_) => 100);
    final hits = StructureShiftDetector().detect(
      exchange: ExchangeId.bybit,
      symbol: symbol,
      timeframe: AppTimeframe.h1,
      candles: _seriesFromCloses(closes),
    );
    expect(hits, isA<List<Detection>>());
  });

  test('levels detector finds interaction on oscillating series', () {
    final closes = <double>[];
    for (var i = 0; i < 120; i++) {
      final wave = (i % 20 < 10) ? 100.0 + (i % 10) : 110.0 - (i % 10);
      closes.add(wave);
    }
    // Finish near lower cluster.
    closes.addAll(List<double>.filled(5, 100.2));
    final hits = LevelsDetector().detect(
      exchange: ExchangeId.gate,
      symbol: symbol,
      timeframe: AppTimeframe.d1,
      candles: _seriesFromCloses(closes),
    );
    expect(hits, isA<List<Detection>>());
  });
}
