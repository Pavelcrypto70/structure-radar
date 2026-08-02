import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../theme/app_theme.dart';

class CandleChart extends StatelessWidget {
  const CandleChart({
    super.key,
    required this.candles,
    this.level,
    this.bias = StructureBias.neutral,
  });

  final List<Candle> candles;
  final LevelZone? level;
  final StructureBias bias;

  @override
  Widget build(BuildContext context) {
    final slice = candles.length > 80 ? candles.sublist(candles.length - 80) : candles;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppTokens.bgElevated,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
        border: Border.all(color: AppTokens.strokeSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomPaint(
          painter: _CandlePainter(slice, level, bias),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  _CandlePainter(this.candles, this.level, this.bias);

  final List<Candle> candles;
  final LevelZone? level;
  final StructureBias bias;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    var minP = candles.first.low;
    var maxP = candles.first.high;
    for (final c in candles) {
      if (c.low < minP) minP = c.low;
      if (c.high > maxP) maxP = c.high;
    }
    if (level != null) {
      minP = minP < level!.price ? minP : level!.price;
      maxP = maxP > level!.price ? maxP : level!.price;
    }
    final pad = (maxP - minP) * 0.08;
    minP -= pad;
    maxP += pad;
    if (maxP == minP) maxP += 1;

    double y(double price) =>
        size.height - ((price - minP) / (maxP - minP)) * size.height;

    if (level != null) {
      final yp = y(level!.price);
      final paint = Paint()
        ..color = AppTokens.accent.withValues(alpha: 0.85)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      final dash = Paint()
        ..color = AppTokens.accentSoft
        ..strokeWidth = 6;
      canvas.drawLine(Offset(0, yp), Offset(size.width, yp), dash);
      canvas.drawLine(Offset(0, yp), Offset(size.width, yp), paint);
    }

    final slot = size.width / candles.length;
    final bodyW = (slot * 0.62).clamp(1.5, 7.0);

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final cx = slot * i + slot / 2;
      final color = c.isBullish ? AppTokens.bull : AppTokens.bear;
      final wick = Paint()
        ..color = color.withValues(alpha: 0.9)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, y(c.high)), Offset(cx, y(c.low)), wick);

      final top = y(c.open > c.close ? c.open : c.close);
      final bottom = y(c.open > c.close ? c.close : c.open);
      final rect = Rect.fromLTRB(cx - bodyW / 2, top, cx + bodyW / 2, bottom == top ? top + 1 : bottom);
      canvas.drawRect(rect, Paint()..color = color);
    }

    // Bias wash on the right edge
    final wash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          (bias == StructureBias.bullish
                  ? AppTokens.bull
                  : bias == StructureBias.bearish
                      ? AppTokens.bear
                      : AppTokens.accent)
              .withValues(alpha: 0.08),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.candles != candles ||
      oldDelegate.level?.price != level?.price ||
      oldDelegate.bias != bias;
}
