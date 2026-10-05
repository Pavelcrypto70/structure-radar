import 'package:flutter_test/flutter_test.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/domain/models.dart';

List<Candle> _candlesFrom(List<double> closes) {
  final start = DateTime.utc(2024, 1, 1);
  return [
    for (var i = 0; i < closes.length; i++)
      Candle(
        openTime: start.add(Duration(hours: 4 * i)),
        open: closes[i] - 0.1,
        high: closes[i] + 0.4,
        low: closes[i] - 0.4,
        close: closes[i],
        volume: 1000,
      ),
  ];
}

void main() {
  const symbol = MarketSymbol(
    id: 'TESTUSDT',
    base: 'TEST',
    quote: 'USDT',
    display: 'TEST',
  );

  test('two rising lows under resistance do NOT label ascending triangle', () {
    // Flat resistance ~110 with 3 touches + only 2 higher lows — old detector
    // called this a triangle; new gates require ≥3 opposing pivots + 25% squeeze.
    final closes = <double>[];
    for (var i = 0; i < 40; i++) {
      closes.add(100 + (i % 7) * 0.3);
    }
    // Build a noisy series then stamp resistance touches and two rising lows.
    while (closes.length < 100) {
      closes.add(105 + (closes.length % 5) * 0.2);
    }

    final candles = _candlesFrom(closes);
    // Resistance touches near 110
    void stampHigh(int i, double high) {
      final c = candles[i];
      candles[i] = Candle(
        openTime: c.openTime,
        open: c.open,
        high: high,
        low: c.low,
        close: high - 0.5,
        volume: c.volume,
      );
    }

    void stampLow(int i, double low) {
      final c = candles[i];
      candles[i] = Candle(
        openTime: c.openTime,
        open: c.open,
        high: c.high,
        low: low,
        close: low + 0.4,
        volume: c.volume,
      );
    }

    stampHigh(50, 110.2);
    stampLow(55, 104.0);
    stampHigh(60, 110.1);
    stampLow(70, 105.5); // only 2 rising lows
    stampHigh(80, 110.0);
    // Approach resistance
    for (var i = 90; i < candles.length; i++) {
      final c = candles[i];
      candles[i] = Candle(
        openTime: c.openTime,
        open: 108.5,
        high: 109.2,
        low: 108.0,
        close: 108.8,
        volume: c.volume,
      );
    }

    final hits = LevelsDetector().detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: AppTimeframe.h4,
      candles: candles,
    );

    for (final h in hits) {
      expect(
        h.level?.pattern,
        isNot(LevelPattern.ascendingTriangle),
        reason: '2-pivot squeeze must stay horizontal, got ${h.title}',
      );
      expect(h.tags.contains('ASC_TRIANGLE'), isFalse);
    }
  });

  test('15m timeframe never emits triangle tags', () {
    final closes = List.generate(120, (i) => 100 + (i % 11) * 0.15);
    final candles = _candlesFrom(closes);
    final hits = LevelsDetector().detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: AppTimeframe.m15,
      candles: candles,
    );
    for (final h in hits) {
      expect(h.level?.pattern, LevelPattern.horizontal);
      expect(h.tags.contains('ASC_TRIANGLE'), isFalse);
      expect(h.tags.contains('DESC_TRIANGLE'), isFalse);
    }
  });
}
