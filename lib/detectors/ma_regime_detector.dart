import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'detector.dart';

enum _Regime { bull, bear, mixed }

/// Slow MA regime — periods sized like a *higher* chart on this TF
/// (e.g. 5m traders using 15–30m averages → ~3–6× bar multiple).
/// Plus: confirm bars, long cooldown after last flip, flat skip.
class MaRegimeDetector implements Detector {
  MaRegimeDetector({
    this.confirmBars = 3,
    this.minBarsSinceFlip = 18,
  });

  /// Regime must hold this many closes (anti 1-bar whipsaw).
  final int confirmBars;

  /// After a flip, ignore new flips until this many bars pass.
  final int minBarsSinceFlip;

  final _uuid = const Uuid();

  @override
  DetectorKind get kind => DetectorKind.maRegime;

  /// Slow stack per TF — "quality trend", not scalp cross.
  ({int fast, int mid, int slow}) _periods(AppTimeframe tf) => switch (tf) {
        // 15m with ~1H-ish framing; 30m with ~2H framing.
        AppTimeframe.m15 => (fast: 55, mid: 100, slow: 200),
        AppTimeframe.m30 => (fast: 45, mid: 90, slow: 180),
        // Analog: 1H bars with averages traders put on 4H-ish framing.
        AppTimeframe.h1 => (fast: 55, mid: 100, slow: 200),
        AppTimeframe.h4 => (fast: 40, mid: 80, slow: 180),
        AppTimeframe.d1 => (fast: 30, mid: 60, slow: 150),
      };

  @override
  List<Detection> detect({
    required ExchangeId exchange,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    required List<Candle> candles,
  }) {
    final p = _periods(timeframe);
    final need = p.slow + minBarsSinceFlip + 5;
    if (candles.length < need) return const [];
    if (!isVolatileEnough(candles, minAtrPct: minAtrPctForTf(timeframe))) {
      return const [];
    }

    final closes = candles.map((c) => c.close).toList();
    final eFast = emaSeries(closes, p.fast);
    final eMid = emaSeries(closes, p.mid);
    final eSlow = emaSeries(closes, p.slow);
    final atrVal = atr(candles);
    if (atrVal <= 0) return const [];

    _Regime regimeAt(int i) {
      final px = closes[i];
      final a = eFast[i];
      final b = eMid[i];
      // Flat stack: MAs glued together → chop, not regime.
      if ((a - b).abs() < atrVal * 0.12) return _Regime.mixed;
      if (px > a && a > b) return _Regime.bull;
      if (px < a && a < b) return _Regime.bear;
      return _Regime.mixed;
    }

    final i = closes.length - 1;

    final now = regimeAt(i);
    if (now == _Regime.mixed) return const [];

    var runLen = 0;
    for (var k = 0; k < minBarsSinceFlip + 40; k++) {
      if (regimeAt(i - k) == now) {
        runLen++;
      } else {
        break;
      }
    }
    // Emit only on the bar where confirm window just completed.
    if (runLen != confirmBars) return const [];

    final flipStart = i - confirmBars + 1;
    var lastOther = -1;
    for (var k = confirmBars; k < confirmBars + minBarsSinceFlip + 60; k++) {
      final idx = i - k;
      if (idx < 0) break;
      final r = regimeAt(idx);
      if (r != _Regime.mixed && r != now) {
        lastOther = idx;
        break;
      }
    }
    if (lastOther < 0) return const [];
    if (flipStart - lastOther < minBarsSinceFlip) return const [];

    final before = regimeAt(lastOther);
    if (before == now || before == _Regime.mixed) return const [];

    final bullish = now == _Regime.bull;
    final stackBonus = bullish
        ? (eMid[i] > eSlow[i] ? 10.0 : 0.0)
        : (eMid[i] < eSlow[i] ? 10.0 : 0.0);
    final slope = eFast[i] - eFast[i - 5];
    final slopeAligned = bullish ? slope > 0 : slope < 0;
    var score = 66.0 + stackBonus + (slopeAligned ? 8 : 0);
    final sep = (closes[i] - eFast[i]).abs() / atrVal;
    score += sep.clamp(0, 1.2) * 6;
    score += ((atrPercent(candles) - 0.01) * 300).clamp(0, 6);
    score = score.clamp(55, 97);

    return [
      Detection(
        id: _uuid.v4(),
        kind: kind,
        exchange: exchange,
        symbol: symbol,
        timeframe: timeframe,
        title: bullish ? 'MA regime → Bullish' : 'MA regime → Bearish',
        summary: bullish
            ? 'Slow EMA stack (${p.fast}/${p.mid}/${p.slow}) confirmed bullish after cooldown — quality regime, not a scalp cross.'
            : 'Slow EMA stack (${p.fast}/${p.mid}/${p.slow}) confirmed bearish after cooldown — quality regime, not a scalp cross.',
        score: score,
        detectedAt: candles.last.openTime,
        bias: bullish ? StructureBias.bullish : StructureBias.bearish,
        candles: candles,
        price: closes[i],
        tags: [
          'EMA_${p.fast}_${p.mid}',
          'SLOW_STACK',
          'COOLDOWN_${minBarsSinceFlip}',
          if (stackBonus > 0) 'EMA_SLOW_ALIGN',
          timeframe.label,
          exchange.short,
        ],
        detailBullets: [
          'Close: ${_fmt(closes[i])}',
          'EMA${p.fast}: ${_fmt(eFast[i])} · EMA${p.mid}: ${_fmt(eMid[i])} · EMA${p.slow}: ${_fmt(eSlow[i])}',
          'Confirm: $confirmBars bars · min gap since opposite: $minBarsSinceFlip bars',
          'ATR%: ${(atrPercent(candles) * 100).toStringAsFixed(2)}% — flat markets filtered.',
        ],
      ),
    ];
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }
}
