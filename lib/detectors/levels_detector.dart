import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'detector.dart';

class LevelsDetector implements Detector {
  LevelsDetector({this.maxLevels = 6});

  final int maxLevels;
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
    final tol = atrVal * 0.35;
    final highs = pivotHighIndexes(candles);
    final lows = pivotLowIndexes(candles);

    final pivots = <double>[
      ...highs.map((i) => candles[i].high),
      ...lows.map((i) => candles[i].low),
    ]..sort();

    if (pivots.isEmpty) return const [];

    final clusters = <_Cluster>[];
    for (final p in pivots) {
      if (clusters.isEmpty) {
        clusters.add(_Cluster(p));
        continue;
      }
      final last = clusters.last;
      if ((p - last.mean).abs() <= tol) {
        last.add(p);
      } else {
        clusters.add(_Cluster(p));
      }
    }

    clusters.sort((a, b) => b.count.compareTo(a.count));
    final close = candles.last.close;
    final out = <Detection>[];

    for (final c in clusters.take(maxLevels)) {
      if (c.count < 2) continue;
      final dist = (close - c.mean).abs();
      final proximity = dist / atrVal;
      if (proximity > 0.85) continue;

      final side = close >= c.mean ? LevelSide.support : LevelSide.resistance;
      // If price is above cluster it's acting as support candidate; below → resistance.
      final strength = (c.count * 12 + (1.2 - proximity) * 30).clamp(40, 96).toDouble();
      final interacting = proximity <= 0.55;
      if (!interacting) continue;

      final zone = LevelZone(
        price: c.mean,
        side: side,
        touches: c.count,
        strength: strength,
      );

      out.add(
        Detection(
          id: _uuid.v4(),
          kind: kind,
          exchange: exchange,
          symbol: symbol,
          timeframe: timeframe,
          title: side == LevelSide.support
              ? 'Support interaction'
              : 'Resistance interaction',
          summary: side == LevelSide.support
              ? 'Price is interacting with a clustered support zone built from repeated swing pivots.'
              : 'Price is interacting with a clustered resistance zone built from repeated swing pivots.',
          score: strength,
          detectedAt: candles.last.openTime,
          bias: side == LevelSide.support
              ? StructureBias.bullish
              : StructureBias.bearish,
          candles: candles,
          price: close,
          level: zone,
          tags: [
            side == LevelSide.support ? 'SUPPORT' : 'RESISTANCE',
            'TOUCHES_${c.count}',
            timeframe.label,
            exchange.short,
          ],
          detailBullets: [
            'Zone midpoint: ${_fmt(c.mean)}',
            'Approximate touches: ${c.count}',
            'Distance ≈ ${proximity.toStringAsFixed(2)} × ATR',
            'Zones are soft — expect wicks and false breaks.',
          ],
        ),
      );
    }

    out.sort((a, b) => b.score.compareTo(a.score));
    return out.take(2).toList();
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }
}

class _Cluster {
  _Cluster(double first) : values = [first];
  final List<double> values;
  void add(double v) => values.add(v);
  int get count => values.length;
  double get mean => values.reduce((a, b) => a + b) / values.length;
}
