import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'detector.dart';

class StructureShiftDetector implements Detector {
  StructureShiftDetector({this.lookback = 3, this.recentBars = 5});

  final int lookback;
  final int recentBars;
  final _uuid = const Uuid();

  @override
  DetectorKind get kind => DetectorKind.structureShift;

  @override
  List<Detection> detect({
    required ExchangeId exchange,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    required List<Candle> candles,
  }) {
    if (candles.length < 60) return const [];

    final highs = pivotHighIndexes(candles, left: lookback, right: lookback);
    final lows = pivotLowIndexes(candles, left: lookback, right: lookback);
    if (highs.length < 3 || lows.length < 3) return const [];

    final lastHighs = highs.sublist(highs.length - 3);
    final lastLows = lows.sublist(lows.length - 3);

    final hh = candles[lastHighs[2]].high > candles[lastHighs[1]].high &&
        candles[lastHighs[1]].high > candles[lastHighs[0]].high;
    final hl = candles[lastLows[2]].low > candles[lastLows[1]].low &&
        candles[lastLows[1]].low > candles[lastLows[0]].low;
    final lh = candles[lastHighs[2]].high < candles[lastHighs[1]].high &&
        candles[lastHighs[1]].high < candles[lastHighs[0]].high;
    final ll = candles[lastLows[2]].low < candles[lastLows[1]].low &&
        candles[lastLows[1]].low < candles[lastLows[0]].low;

    final priorBull = hh && hl;
    final priorBear = lh && ll;

    final close = candles.last.close;
    final prevSwingLow = candles[lastLows[1]].low;
    final prevSwingHigh = candles[lastHighs[1]].high;
    final breakIdxLow = lastLows[1];
    final breakIdxHigh = lastHighs[1];
    final lastIdx = candles.length - 1;

    final recentBearBreak = priorBull &&
        close < prevSwingLow &&
        (lastIdx - breakIdxLow) <= recentBars + lookback + 8;
    final recentBullBreak = priorBear &&
        close > prevSwingHigh &&
        (lastIdx - breakIdxHigh) <= recentBars + lookback + 8;

    // Also catch emerging LH+LL after bullish swings without waiting for deep prior purity.
    final emergingBear = !priorBear &&
        candles[lastHighs[2]].high < candles[lastHighs[1]].high &&
        candles[lastLows[2]].low < candles[lastLows[1]].low &&
        close < candles[lastLows[1]].low &&
        (lastIdx - lastLows[2]) <= 12;
    final emergingBull = !priorBull &&
        candles[lastHighs[2]].high > candles[lastHighs[1]].high &&
        candles[lastLows[2]].low > candles[lastLows[1]].low &&
        close > candles[lastHighs[1]].high &&
        (lastIdx - lastHighs[2]) <= 12;

    final out = <Detection>[];

    if (recentBearBreak || emergingBear) {
      final score = _score(
        cleanPrior: priorBull,
        separation: (prevSwingLow - close).abs() / prevSwingLow,
        recencyBars: lastIdx - (recentBearBreak ? breakIdxLow : lastLows[2]),
      );
      out.add(
        Detection(
          id: _uuid.v4(),
          kind: kind,
          exchange: exchange,
          symbol: symbol,
          timeframe: timeframe,
          title: 'Bull → Bear structure shift',
          summary:
              'Price broke below a prior higher-low. Swing structure is flipping from uptrend geometry toward lower highs / lower lows.',
          score: score,
          detectedAt: candles.last.openTime,
          bias: StructureBias.bearish,
          candles: candles,
          price: close,
          tags: [
            if (priorBull) 'PRIOR_HH_HL',
            'BOS_DOWN',
            timeframe.label,
            exchange.short,
          ],
          detailBullets: [
            'Prior swing low reference: ${_fmt(prevSwingLow)}',
            'Last close: ${_fmt(close)}',
            if (priorBull) 'Prior sequence showed higher-highs and higher-lows.',
            'Heuristic only — confirm invalidation and context on the chart.',
          ],
        ),
      );
    }

    if (recentBullBreak || emergingBull) {
      final score = _score(
        cleanPrior: priorBear,
        separation: (close - prevSwingHigh).abs() / prevSwingHigh,
        recencyBars: lastIdx - (recentBullBreak ? breakIdxHigh : lastHighs[2]),
      );
      out.add(
        Detection(
          id: _uuid.v4(),
          kind: kind,
          exchange: exchange,
          symbol: symbol,
          timeframe: timeframe,
          title: 'Bear → Bull structure shift',
          summary:
              'Price broke above a prior lower-high. Swing structure is flipping from downtrend geometry toward higher highs / higher lows.',
          score: score,
          detectedAt: candles.last.openTime,
          bias: StructureBias.bullish,
          candles: candles,
          price: close,
          tags: [
            if (priorBear) 'PRIOR_LH_LL',
            'BOS_UP',
            timeframe.label,
            exchange.short,
          ],
          detailBullets: [
            'Prior swing high reference: ${_fmt(prevSwingHigh)}',
            'Last close: ${_fmt(close)}',
            if (priorBear) 'Prior sequence showed lower-highs and lower-lows.',
            'Heuristic only — confirm invalidation and context on the chart.',
          ],
        ),
      );
    }

    return out;
  }

  double _score({
    required bool cleanPrior,
    required double separation,
    required int recencyBars,
  }) {
    var s = 58.0;
    if (cleanPrior) s += 16;
    s += (separation * 400).clamp(0, 14);
    s += (12 - recencyBars).clamp(0, 12).toDouble();
    return s.clamp(0, 99);
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }
}
