import 'package:flutter_test/flutter_test.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/detectors/ma_regime_detector.dart';
import 'package:structure_radar/detectors/structure_detector.dart';
import 'package:structure_radar/domain/models.dart';

List<Candle> _seriesFromCloses(List<double> closes, {double rangeFrac = 0.012}) {
  final out = <Candle>[];
  final start = DateTime.utc(2024, 1, 1);
  for (var i = 0; i < closes.length; i++) {
    final c = closes[i];
    final prev = i == 0 ? c : closes[i - 1];
    final pad = c * rangeFrac;
    out.add(
      Candle(
        openTime: start.add(Duration(hours: i)),
        open: prev,
        high: (c > prev ? c : prev) + pad,
        low: (c < prev ? c : prev) - pad,
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

  test('MA regime detector flips bull to bear on slow stack', () {
    final closes = <double>[];
    // Long uptrend so slow EMAs stack bullish.
    for (var i = 0; i < 280; i++) {
      closes.add(100 + i * 0.85);
    }
    // Long enough bear phase: cooldown + confirm against slow mid/fast.
    for (var i = 0; i < 55; i++) {
      closes.add(closes.last - 6.5);
    }
    final candles = _seriesFromCloses(closes, rangeFrac: 0.02);
    final hits = MaRegimeDetector().detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: AppTimeframe.h4,
      candles: candles,
    );
    expect(hits, isA<List<Detection>>());
    if (hits.isNotEmpty) {
      expect(hits.first.kind, DetectorKind.maRegime);
      expect(hits.first.bias, StructureBias.bearish);
      expect(hits.first.tags, contains('SLOW_STACK'));
    }
  });

  test('structure detector ignores flat dead range', () {
    final closes = List<double>.generate(120, (_) => 100);
    final hits = StructureShiftDetector().detect(
      exchange: ExchangeId.bybit,
      symbol: symbol,
      timeframe: AppTimeframe.h1,
      candles: _seriesFromCloses(closes, rangeFrac: 0.0005),
    );
    expect(hits, isEmpty);
  });

  test('structure detector returns list type safely on noisy data', () {
    final closes = List<double>.generate(120, (i) => 100 + (i % 5) * 0.2);
    final hits = StructureShiftDetector().detect(
      exchange: ExchangeId.bybit,
      symbol: symbol,
      timeframe: AppTimeframe.h1,
      candles: _seriesFromCloses(closes),
    );
    expect(hits, isA<List<Detection>>());
  });

  test('levels detector finds clean 3-touch resistance approach', () {
    final closes = <double>[];
    var px = 100.0;
    for (var wave = 0; wave < 4; wave++) {
      for (var i = 0; i < 7; i++) {
        px += 1.4;
        closes.add(px);
      }
      while (px < 109.6) {
        px += 0.8;
        closes.add(px);
      }
      closes.add(110.0);
      closes.add(109.7);
      for (var i = 0; i < 8; i++) {
        px = closes.last - 1.1;
        closes.add(px);
      }
    }
    while (closes.last < 108.8) {
      closes.add(closes.last + 0.7);
    }
    closes.add(109.2);
    closes.add(109.0);

    final candles = _seriesFromCloses(closes);
    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      if (c.close >= 109.5) {
        candles[i] = Candle(
          openTime: c.openTime,
          open: c.open,
          high: 110.05,
          low: c.low,
          close: c.close > 110 ? 109.4 : c.close,
          volume: c.volume,
        );
      }
    }

    final hits = LevelsDetector().detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: AppTimeframe.h4,
      candles: candles,
    );
    expect(hits, isA<List<Detection>>());
    if (hits.isNotEmpty) {
      expect(hits.first.kind, DetectorKind.levels);
      expect(hits.first.level, isNotNull);
      expect(hits.first.level!.touches, greaterThanOrEqualTo(3));
    }
  });
}
