import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'detector.dart';

enum _Regime { bull, bear, mixed }

class MaRegimeDetector implements Detector {
  MaRegimeDetector();

  final _uuid = const Uuid();

  @override
  DetectorKind get kind => DetectorKind.maRegime;

  @override
  List<Detection> detect({
    required ExchangeId exchange,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    required List<Candle> candles,
  }) {
    if (candles.length < 210) return const [];

    final closes = candles.map((c) => c.close).toList();
    final e20 = emaSeries(closes, 20);
    final e50 = emaSeries(closes, 50);
    final e200 = emaSeries(closes, 200);

    _Regime regimeAt(int i) {
      final px = closes[i];
      final a = e20[i];
      final b = e50[i];
      if (px > a && a > b) return _Regime.bull;
      if (px < a && a < b) return _Regime.bear;
      return _Regime.mixed;
    }

    final i = closes.length - 1;
    final prev = i - 1;
    final now = regimeAt(i);
    final before = regimeAt(prev);
    if (now == before || now == _Regime.mixed) return const [];

    // Require that "before" was a clean opposite regime recently (look back a few bars).
    var hadOpposite = before == _Regime.bull || before == _Regime.bear;
    if (!hadOpposite) {
      for (var k = 2; k <= 6; k++) {
        final r = regimeAt(i - k);
        if (r != _Regime.mixed && r != now) {
          hadOpposite = true;
          break;
        }
      }
    }
    if (!hadOpposite) return const [];

    final bullish = now == _Regime.bull;
    final stackBonus = bullish
        ? (e50[i] > e200[i] ? 10.0 : 0.0)
        : (e50[i] < e200[i] ? 10.0 : 0.0);
    final slope = e20[i] - e20[i - 3];
    final slopeAligned = bullish ? slope > 0 : slope < 0;
    var score = 62.0 + stackBonus + (slopeAligned ? 8 : 0);
    final sep = (closes[i] - e20[i]).abs() / closes[i];
    score += (sep * 500).clamp(0, 10);
    score = score.clamp(0, 99);

    return [
      Detection(
        id: _uuid.v4(),
        kind: kind,
        exchange: exchange,
        symbol: symbol,
        timeframe: timeframe,
        title: bullish ? 'MA regime → Bullish' : 'MA regime → Bearish',
        summary: bullish
            ? 'Price and EMA20/EMA50 stack flipped into a bullish regime on the latest bar.'
            : 'Price and EMA20/EMA50 stack flipped into a bearish regime on the latest bar.',
        score: score,
        detectedAt: candles.last.openTime,
        bias: bullish ? StructureBias.bullish : StructureBias.bearish,
        candles: candles,
        price: closes[i],
        tags: [
          'EMA_20_50',
          if (stackBonus > 0) 'EMA200_ALIGN',
          timeframe.label,
          exchange.short,
        ],
        detailBullets: [
          'Close: ${_fmt(closes[i])}',
          'EMA20: ${_fmt(e20[i])} · EMA50: ${_fmt(e50[i])} · EMA200: ${_fmt(e200[i])}',
          'Regime uses EMA stack alignment, not prediction.',
          'Whipsaws around averages are common — treat as context, not a signal to enter.',
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
