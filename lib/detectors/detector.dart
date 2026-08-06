import '../domain/models.dart';

abstract class Detector {
  DetectorKind get kind;

  List<Detection> detect({
    required ExchangeId exchange,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    required List<Candle> candles,
  });
}

List<int> pivotHighIndexes(
  List<Candle> candles, {
  int left = 3,
  int right = 3,
}) {
  final out = <int>[];
  for (var i = left; i < candles.length - right; i++) {
    final h = candles[i].high;
    var ok = true;
    for (var j = i - left; j <= i + right; j++) {
      if (j == i) continue;
      if (candles[j].high >= h) {
        ok = false;
        break;
      }
    }
    if (ok) out.add(i);
  }
  return out;
}

List<int> pivotLowIndexes(List<Candle> candles, {int left = 3, int right = 3}) {
  final out = <int>[];
  for (var i = left; i < candles.length - right; i++) {
    final l = candles[i].low;
    var ok = true;
    for (var j = i - left; j <= i + right; j++) {
      if (j == i) continue;
      if (candles[j].low <= l) {
        ok = false;
        break;
      }
    }
    if (ok) out.add(i);
  }
  return out;
}

double atr(List<Candle> candles, {int period = 14}) {
  if (candles.length < period + 1) {
    return candles.isEmpty ? 0 : (candles.last.high - candles.last.low).abs();
  }
  var sum = 0.0;
  for (var i = candles.length - period; i < candles.length; i++) {
    final c = candles[i];
    final prev = candles[i - 1];
    final tr = [
      c.high - c.low,
      (c.high - prev.close).abs(),
      (c.low - prev.close).abs(),
    ].reduce((a, b) => a > b ? a : b);
    sum += tr;
  }
  return sum / period;
}

List<double> emaSeries(List<double> values, int period) {
  if (values.isEmpty) return const [];
  final k = 2 / (period + 1);
  final out = List<double>.filled(values.length, 0);
  var ema = values.first;
  out[0] = ema;
  for (var i = 1; i < values.length; i++) {
    ema = values[i] * k + ema * (1 - k);
    out[i] = ema;
  }
  return out;
}

/// ATR as % of last close — primary volatility gate.
double atrPercent(List<Candle> candles, {int period = 14}) {
  if (candles.isEmpty) return 0;
  final px = candles.last.close;
  if (px <= 0) return 0;
  return atr(candles, period: period) / px;
}

/// Longer-window ATR% to detect compression (flat / chop).
double atrPercentLookback(
  List<Candle> candles, {
  int period = 14,
  int lookback = 48,
}) {
  if (candles.length < lookback + 1) {
    return atrPercent(candles, period: period);
  }
  final slice = candles.sublist(candles.length - lookback);
  return atrPercent(slice, period: period);
}

/// True when market is moving enough for structure/MA flips to mean something.
/// [minAtrPct] is TF-dependent; also rejects ATR compression vs prior window.
bool isVolatileEnough(
  List<Candle> candles, {
  required double minAtrPct,
  double compressionMax = 0.55,
}) {
  final now = atrPercent(candles);
  if (now < minAtrPct) return false;
  final prior = atrPercentLookback(candles, lookback: 56);
  if (prior <= 0) return now >= minAtrPct;
  // Flat: current ATR collapsed vs recent history.
  if (now / prior < compressionMax && now < minAtrPct * 1.35) return false;
  return true;
}

double minAtrPctForTf(AppTimeframe tf) => switch (tf) {
  AppTimeframe.m15 => 0.0045,
  AppTimeframe.m30 => 0.006,
  AppTimeframe.h1 => 0.008,
  AppTimeframe.h4 => 0.012,
  AppTimeframe.d1 => 0.018,
};
