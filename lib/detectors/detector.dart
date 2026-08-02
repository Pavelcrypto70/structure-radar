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

List<int> pivotHighIndexes(List<Candle> candles, {int left = 3, int right = 3}) {
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
