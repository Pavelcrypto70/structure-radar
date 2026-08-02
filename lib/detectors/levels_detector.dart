import 'dart:math';

import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'detector.dart';

/// Clean multi-touch horizontals + triangle squeezes (Telegram-style setups).
///
/// Design goals from reference charts:
/// - flat resistance/support with **≥3 separated touches**
/// - tight price cluster (not fat ATR blobs)
/// - price **approaching** the level now
/// - optional ascending/descending triangle when diagonal converges
class LevelsDetector implements Detector {
  LevelsDetector({
    this.pivotLookback = 4,
    this.minTouches = 3,
    this.minTouchGapBars = 5,
    this.minTouchSpanBars = 12,
    this.clusterTolAtr = 0.22,
    this.clusterTolPct = 0.0025,
    this.approachAtr = 1.05,
    this.tightApproachAtr = 0.55,
    this.breakToleranceAtr = 0.28,
  });

  final int pivotLookback;
  final int minTouches;
  final int minTouchGapBars;
  final int minTouchSpanBars;
  final double clusterTolAtr;
  final double clusterTolPct;
  final double approachAtr;
  final double tightApproachAtr;
  final double breakToleranceAtr;
  final _uuid = const Uuid();

  @override
  DetectorKind get kind => DetectorKind.levels;

  @override
  List<Detection> detect({
    required ExchangeId exchange,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    required List<Candle> candles,
  }) {
    if (candles.length < 80) return const [];

    final atrVal = atr(candles);
    if (atrVal <= 0) return const [];

    final highs = pivotHighIndexes(
      candles,
      left: pivotLookback,
      right: pivotLookback,
    );
    final lows = pivotLowIndexes(
      candles,
      left: pivotLookback,
      right: pivotLookback,
    );

    final resist = _buildLevels(
      candles: candles,
      pivotIndexes: highs,
      priceOf: (c) => c.high,
      side: LevelSide.resistance,
      atrVal: atrVal,
    );
    final support = _buildLevels(
      candles: candles,
      pivotIndexes: lows,
      priceOf: (c) => c.low,
      side: LevelSide.support,
      atrVal: atrVal,
    );

    final candidates = <_LevelCandidate>[...resist, ...support];
    final close = candles.last.close;
    final lastIdx = candles.length - 1;
    final out = <Detection>[];

    for (final cand in candidates) {
      final prox = (close - cand.price).abs() / atrVal;
      if (prox > approachAtr) continue;

      final intact = _levelStillValid(
        candles: candles,
        level: cand.price,
        side: cand.side,
        atrVal: atrVal,
        fromIndex: cand.touchIndexes.first,
      );
      if (!intact) continue;

      final approaching = _isApproaching(
        candles: candles,
        level: cand.price,
        side: cand.side,
        atrVal: atrVal,
        proximity: prox,
      );
      if (!approaching) continue;

      final triangle = _tryTriangle(
        candles: candles,
        flat: cand,
        atrVal: atrVal,
        oppositePivots: cand.side == LevelSide.resistance ? lows : highs,
      );

      final score = _score(
        touches: cand.touchIndexes.length,
        proximity: prox,
        spanBars: cand.touchIndexes.last - cand.touchIndexes.first,
        tightness: cand.tightnessAtr,
        hasTriangle: triangle != null,
        recentTouch: lastIdx - cand.touchIndexes.last,
      );

      final pattern = triangle?.pattern ?? LevelPattern.horizontal;
      final zone = LevelZone(
        price: cand.price,
        side: cand.side,
        touches: cand.touchIndexes.length,
        strength: score,
        touchIndexes: cand.touchIndexes,
        pattern: pattern,
        trendStartIndex: triangle?.startIndex,
        trendStartPrice: triangle?.startPrice,
        trendEndIndex: triangle?.endIndex,
        trendEndPrice: triangle?.endPrice,
      );

      final bias = cand.side == LevelSide.support
          ? StructureBias.bullish
          : StructureBias.bearish;

      out.add(
        Detection(
          id: _uuid.v4(),
          kind: kind,
          exchange: exchange,
          symbol: symbol,
          timeframe: timeframe,
          title: _title(cand, pattern),
          summary: _summary(cand, pattern, close),
          score: score,
          detectedAt: candles.last.openTime,
          bias: bias,
          candles: candles,
          price: close,
          level: zone,
          tags: [
            cand.side == LevelSide.support ? 'SUPPORT' : 'RESISTANCE',
            'TOUCHES_${cand.touchIndexes.length}',
            if (pattern == LevelPattern.ascendingTriangle) 'ASC_TRIANGLE',
            if (pattern == LevelPattern.descendingTriangle) 'DESC_TRIANGLE',
            'APPROACH',
            timeframe.label,
            exchange.short,
          ],
          detailBullets: [
            'Level: ${_fmt(cand.price)}',
            'Touches: ${cand.touchIndexes.length} (span ${cand.touchIndexes.last - cand.touchIndexes.first} bars)',
            'Distance ≈ ${prox.toStringAsFixed(2)} × ATR',
            if (triangle != null) 'Triangle squeeze detected on opposing swings.',
            'Heuristic — confirm rejection/break on the chart.',
          ],
        ),
      );
    }

    out.sort((a, b) => b.score.compareTo(a.score));
    return _dedupeNear(out, atrVal).take(2).toList();
  }

  List<_LevelCandidate> _buildLevels({
    required List<Candle> candles,
    required List<int> pivotIndexes,
    required double Function(Candle) priceOf,
    required LevelSide side,
    required double atrVal,
  }) {
    if (pivotIndexes.length < minTouches) return const [];

    final points = [
      for (final i in pivotIndexes) (i, priceOf(candles[i])),
    ]..sort((a, b) => a.$2.compareTo(b.$2));

    final clusters = <List<(int, double)>>[];
    for (final p in points) {
      if (clusters.isEmpty) {
        clusters.add([p]);
        continue;
      }
      final last = clusters.last;
      final mean = last.map((e) => e.$2).reduce((a, b) => a + b) / last.length;
      final tol = _tol(mean, atrVal);
      if ((p.$2 - mean).abs() <= tol) {
        last.add(p);
      } else {
        clusters.add([p]);
      }
    }

    final out = <_LevelCandidate>[];
    for (final cluster in clusters) {
      if (cluster.length < minTouches) continue;
      cluster.sort((a, b) => a.$1.compareTo(b.$1));

      // Enforce temporal separation — consecutive micro-pivots ≠ 3 touches.
      final filtered = <(int, double)>[cluster.first];
      for (var i = 1; i < cluster.length; i++) {
        if (cluster[i].$1 - filtered.last.$1 >= minTouchGapBars) {
          filtered.add(cluster[i]);
        } else {
          // Keep the extreme more aligned with side (higher for resistance).
          final prev = filtered.last;
          final better = side == LevelSide.resistance
              ? (cluster[i].$2 >= prev.$2 ? cluster[i] : prev)
              : (cluster[i].$2 <= prev.$2 ? cluster[i] : prev);
          filtered[filtered.length - 1] = better;
        }
      }
      if (filtered.length < minTouches) continue;

      final span = filtered.last.$1 - filtered.first.$1;
      if (span < minTouchSpanBars) continue;

      final prices = filtered.map((e) => e.$2).toList()..sort();
      final mid = prices[prices.length ~/ 2];
      final spread = prices.last - prices.first;
      final tightness = spread / atrVal;

      // Reject fat / messy zones.
      if (tightness > 0.45) continue;

      out.add(
        _LevelCandidate(
          price: mid,
          side: side,
          touchIndexes: filtered.map((e) => e.$1).toList(),
          tightnessAtr: tightness,
        ),
      );
    }
    return out;
  }

  double _tol(double price, double atrVal) =>
      min(atrVal * clusterTolAtr, price * clusterTolPct * 2.2);

  bool _levelStillValid({
    required List<Candle> candles,
    required double level,
    required LevelSide side,
    required double atrVal,
    required int fromIndex,
  }) {
    final slack = atrVal * breakToleranceAtr;
    var closesThrough = 0;
    for (var i = fromIndex; i < candles.length; i++) {
      final c = candles[i].close;
      final broken = side == LevelSide.resistance
          ? c > level + slack
          : c < level - slack;
      if (broken) {
        closesThrough++;
        if (closesThrough >= 2) return false;
      } else {
        closesThrough = 0;
      }
    }
    return true;
  }

  bool _isApproaching({
    required List<Candle> candles,
    required double level,
    required LevelSide side,
    required double atrVal,
    required double proximity,
  }) {
    final close = candles.last.close;
    final onCorrectSide = side == LevelSide.resistance
        ? close <= level + atrVal * breakToleranceAtr
        : close >= level - atrVal * breakToleranceAtr;
    if (!onCorrectSide) return false;

    if (proximity <= tightApproachAtr) return true;

    // Drift toward level over last ~8 bars.
    if (candles.length < 10) return proximity <= approachAtr;
    final older = candles[candles.length - 9].close;
    final newer = close;
    final toward = side == LevelSide.resistance
        ? newer > older && newer <= level
        : newer < older && newer >= level;
    return toward && proximity <= approachAtr;
  }

  _TriangleHint? _tryTriangle({
    required List<Candle> candles,
    required _LevelCandidate flat,
    required double atrVal,
    required List<int> oppositePivots,
  }) {
    // Opposing swings after first flat touch, in the consolidation window.
    final start = flat.touchIndexes.first;
    final ops = oppositePivots.where((i) => i >= start).toList();
    if (ops.length < 2) return null;

    final lastOps = ops.length > 4 ? ops.sublist(ops.length - 4) : ops;
    if (lastOps.length < 2) return null;

    if (flat.side == LevelSide.resistance) {
      // Ascending triangle: higher lows under flat resistance.
      var rising = true;
      for (var i = 1; i < lastOps.length; i++) {
        if (candles[lastOps[i]].low <= candles[lastOps[i - 1]].low) {
          rising = false;
          break;
        }
      }
      if (!rising) return null;
      final a = lastOps.first;
      final b = lastOps.last;
      // Converging: last low closer to flat than first low.
      final firstGap = flat.price - candles[a].low;
      final lastGap = flat.price - candles[b].low;
      if (lastGap >= firstGap * 0.92) return null;
      if (lastGap < atrVal * 0.15) return null;
      return _TriangleHint(
        pattern: LevelPattern.ascendingTriangle,
        startIndex: a,
        startPrice: candles[a].low,
        endIndex: b,
        endPrice: candles[b].low,
      );
    }

    // Descending triangle: lower highs above flat support.
    var falling = true;
    for (var i = 1; i < lastOps.length; i++) {
      if (candles[lastOps[i]].high >= candles[lastOps[i - 1]].high) {
        falling = false;
        break;
      }
    }
    if (!falling) return null;
    final a = lastOps.first;
    final b = lastOps.last;
    final firstGap = candles[a].high - flat.price;
    final lastGap = candles[b].high - flat.price;
    if (lastGap >= firstGap * 0.92) return null;
    if (lastGap < atrVal * 0.15) return null;
    return _TriangleHint(
      pattern: LevelPattern.descendingTriangle,
      startIndex: a,
      startPrice: candles[a].high,
      endIndex: b,
      endPrice: candles[b].high,
    );
  }

  double _score({
    required int touches,
    required double proximity,
    required int spanBars,
    required double tightness,
    required bool hasTriangle,
    required int recentTouch,
  }) {
    var s = 52.0;
    s += (touches - 2) * 9.0; // 3→+9, 4→+18…
    s += (1.1 - proximity).clamp(0, 1.1) * 18;
    s += (spanBars / 40).clamp(0, 1) * 8;
    s += (0.45 - tightness).clamp(0, 0.45) * 20;
    if (hasTriangle) s += 10;
    if (recentTouch <= 8) s += 6;
    return s.clamp(55, 97);
  }

  String _title(_LevelCandidate c, LevelPattern pattern) {
    final px = _fmt(c.price);
    final n = c.touchIndexes.length;
    switch (pattern) {
      case LevelPattern.ascendingTriangle:
        return 'Ascending triangle · resistance $px ($n touches)';
      case LevelPattern.descendingTriangle:
        return 'Descending triangle · support $px ($n touches)';
      case LevelPattern.horizontal:
        return c.side == LevelSide.resistance
            ? 'Approaching resistance: $px ($n touches)'
            : 'Approaching support: $px ($n touches)';
    }
  }

  String _summary(_LevelCandidate c, LevelPattern pattern, double close) {
    final px = _fmt(c.price);
    final n = c.touchIndexes.length;
    switch (pattern) {
      case LevelPattern.ascendingTriangle:
        return 'Flat resistance at $px with $n touches and rising lows — classic ascending-triangle squeeze. Last close ${_fmt(close)}.';
      case LevelPattern.descendingTriangle:
        return 'Flat support at $px with $n touches and lower highs — descending-triangle / post-impulse squeeze. Last close ${_fmt(close)}.';
      case LevelPattern.horizontal:
        return c.side == LevelSide.resistance
            ? 'Price is approaching a clean horizontal resistance at $px confirmed by $n separated swing touches.'
            : 'Price is approaching a clean horizontal support at $px confirmed by $n separated swing touches.';
    }
  }

  List<Detection> _dedupeNear(List<Detection> hits, double atrVal) {
    final kept = <Detection>[];
    for (final h in hits) {
      final p = h.level?.price;
      if (p == null) continue;
      final clash = kept.any(
        (k) => (k.level!.price - p).abs() < atrVal * 0.35,
      );
      if (!clash) kept.add(h);
    }
    return kept;
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }
}

class _LevelCandidate {
  _LevelCandidate({
    required this.price,
    required this.side,
    required this.touchIndexes,
    required this.tightnessAtr,
  });

  final double price;
  final LevelSide side;
  final List<int> touchIndexes;
  final double tightnessAtr;
}

class _TriangleHint {
  _TriangleHint({
    required this.pattern,
    required this.startIndex,
    required this.startPrice,
    required this.endIndex,
    required this.endPrice,
  });

  final LevelPattern pattern;
  final int startIndex;
  final double startPrice;
  final int endIndex;
  final double endPrice;
}
