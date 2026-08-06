import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'detector.dart';

/// Quality structure shift: clean prior swing geometry + ATR-sized BOS.
/// Drops "emerging" micro-breaks that fire in flat chop.
class StructureShiftDetector implements Detector {
  StructureShiftDetector({
    this.lookback = 4,
    this.recentBars = 8,
    this.minBreakAtr = 0.28,
    this.confirmCloses = 2,
  });

  final int lookback;
  final int recentBars;

  /// Close must clear the swing by at least this × ATR (anti false spike).
  final double minBreakAtr;

  /// Need this many recent closes beyond the level (not a single wick poke).
  final int confirmCloses;

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
    if (candles.length < 80) return const [];
    if (!isVolatileEnough(candles, minAtrPct: minAtrPctForTf(timeframe))) {
      return const [];
    }

    final atrVal = atr(candles);
    if (atrVal <= 0) return const [];

    final highs = pivotHighIndexes(candles, left: lookback, right: lookback);
    final lows = pivotLowIndexes(candles, left: lookback, right: lookback);
    if (highs.length < 3 || lows.length < 3) return const [];

    final lastHighs = highs.sublist(highs.length - 3);
    final lastLows = lows.sublist(lows.length - 3);

    final hh =
        candles[lastHighs[2]].high > candles[lastHighs[1]].high &&
        candles[lastHighs[1]].high > candles[lastHighs[0]].high;
    final hl =
        candles[lastLows[2]].low > candles[lastLows[1]].low &&
        candles[lastLows[1]].low > candles[lastLows[0]].low;
    final lh =
        candles[lastHighs[2]].high < candles[lastHighs[1]].high &&
        candles[lastHighs[1]].high < candles[lastHighs[0]].high;
    final ll =
        candles[lastLows[2]].low < candles[lastLows[1]].low &&
        candles[lastLows[1]].low < candles[lastLows[0]].low;

    final priorBull = hh && hl;
    final priorBear = lh && ll;
    // Only clean prior geometry — no emerging LH/LL spam in ranges.
    if (!priorBull && !priorBear) return const [];

    final close = candles.last.close;
    final prevSwingLow = candles[lastLows[1]].low;
    final prevSwingHigh = candles[lastHighs[1]].high;
    final breakIdxLow = lastLows[1];
    final breakIdxHigh = lastHighs[1];
    final lastIdx = candles.length - 1;
    final freshBars = recentBars + lookback + 10;
    final pad = atrVal * minBreakAtr;

    final bearBreak =
        priorBull &&
        close < prevSwingLow - pad &&
        (lastIdx - breakIdxLow) <= freshBars &&
        _closesBeyond(candles, below: prevSwingLow - pad, count: confirmCloses);
    final bullBreak =
        priorBear &&
        close > prevSwingHigh + pad &&
        (lastIdx - breakIdxHigh) <= freshBars &&
        _closesBeyond(
          candles,
          above: prevSwingHigh + pad,
          count: confirmCloses,
        );

    final out = <Detection>[];

    if (bearBreak) {
      final score = _score(
        separationAtr: (prevSwingLow - close) / atrVal,
        recencyBars: lastIdx - breakIdxLow,
        atrPct: atrPercent(candles),
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
              'Confirmed break below a prior higher-low after clean HH/HL geometry. ATR-filtered to skip flat spikes.',
          score: score,
          detectedAt: candles.last.openTime,
          bias: StructureBias.bearish,
          candles: candles,
          price: close,
          tags: [
            'PRIOR_HH_HL',
            'BOS_DOWN',
            'ATR_CONFIRM',
            timeframe.label,
            exchange.short,
          ],
          detailBullets: [
            'Prior swing low: ${_fmt(prevSwingLow)}',
            'Last close: ${_fmt(close)} (pad ${minBreakAtr.toStringAsFixed(2)}×ATR)',
            'ATR%: ${(atrPercent(candles) * 100).toStringAsFixed(2)}%',
            'Heuristic only — confirm invalidation on the chart.',
          ],
        ),
      );
    }

    if (bullBreak) {
      final score = _score(
        separationAtr: (close - prevSwingHigh) / atrVal,
        recencyBars: lastIdx - breakIdxHigh,
        atrPct: atrPercent(candles),
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
              'Confirmed break above a prior lower-high after clean LH/LL geometry. ATR-filtered to skip flat spikes.',
          score: score,
          detectedAt: candles.last.openTime,
          bias: StructureBias.bullish,
          candles: candles,
          price: close,
          tags: [
            'PRIOR_LH_LL',
            'BOS_UP',
            'ATR_CONFIRM',
            timeframe.label,
            exchange.short,
          ],
          detailBullets: [
            'Prior swing high: ${_fmt(prevSwingHigh)}',
            'Last close: ${_fmt(close)} (pad ${minBreakAtr.toStringAsFixed(2)}×ATR)',
            'ATR%: ${(atrPercent(candles) * 100).toStringAsFixed(2)}%',
            'Heuristic only — confirm invalidation on the chart.',
          ],
        ),
      );
    }

    return out;
  }

  bool _closesBeyond(
    List<Candle> candles, {
    double? above,
    double? below,
    required int count,
  }) {
    if (candles.length < count) return false;
    var n = 0;
    for (var i = candles.length - count; i < candles.length; i++) {
      final c = candles[i].close;
      if (above != null && c > above) n++;
      if (below != null && c < below) n++;
    }
    return n >= count;
  }

  double _score({
    required double separationAtr,
    required int recencyBars,
    required double atrPct,
  }) {
    var s = 64.0;
    s += separationAtr.clamp(0, 2) * 8;
    s += (10 - recencyBars).clamp(0, 10).toDouble();
    s += ((atrPct - 0.01) * 400).clamp(0, 8);
    return s.clamp(55, 97);
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }
}
