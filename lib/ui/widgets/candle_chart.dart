import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../detectors/detector.dart';
import '../../domain/models.dart';
import '../../theme/app_theme.dart';

class CandleChart extends StatelessWidget {
  const CandleChart({
    super.key,
    required this.candles,
    this.level,
    this.bias = StructureBias.neutral,
    this.showMa = true,
  });

  final List<Candle> candles;
  final LevelZone? level;
  final StructureBias bias;
  final bool showMa;

  @override
  Widget build(BuildContext context) {
    final full = candles;
    final start = full.length > 90 ? full.length - 90 : 0;
    final slice = full.sublist(start);
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppTokens.bgElevated,
        borderRadius: BorderRadius.circular(AppTokens.radius20),
        border: Border.all(color: AppTokens.strokeSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
        child: CustomPaint(
          painter: _CandlePainter(
            slice,
            level,
            bias,
            showMa,
            indexOffset: start,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  _CandlePainter(
    this.candles,
    this.level,
    this.bias,
    this.showMa, {
    required this.indexOffset,
  });

  final List<Candle> candles;
  final LevelZone? level;
  final StructureBias bias;
  final bool showMa;
  final int indexOffset;

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
      minP = math.min(minP, level!.price);
      maxP = math.max(maxP, level!.price);
      if (level!.trendStartPrice != null) {
        minP = math.min(minP, level!.trendStartPrice!);
        maxP = math.max(maxP, level!.trendStartPrice!);
      }
      if (level!.trendEndPrice != null) {
        minP = math.min(minP, level!.trendEndPrice!);
        maxP = math.max(maxP, level!.trendEndPrice!);
      }
    }
    final pad = (maxP - minP) * 0.1;
    minP -= pad;
    maxP += pad;
    if (maxP == minP) maxP += 1;

    double y(double price) =>
        size.height - ((price - minP) / (maxP - minP)) * size.height;

    final grid = Paint()
      ..color = AppTokens.strokeSoft
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final gy = size.height * i / 4;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), grid);
    }

    final slot = size.width / candles.length;

    if (level != null) {
      final levelColor = level!.side == LevelSide.resistance
          ? AppTokens.bear
          : AppTokens.bull;
      final yp = y(level!.price);
      final band = Paint()..color = levelColor.withValues(alpha: 0.10);
      canvas.drawRect(Rect.fromLTWH(0, yp - 4, size.width, 8), band);
      final paint = Paint()
        ..color = levelColor.withValues(alpha: 0.95)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(0, yp), Offset(size.width, yp), paint);

      // Diagonal squeeze line.
      final ts = level!.trendStartIndex;
      final te = level!.trendEndIndex;
      final sp = level!.trendStartPrice;
      final ep = level!.trendEndPrice;
      if (ts != null && te != null && sp != null && ep != null) {
        final i0 = ts - indexOffset;
        final i1 = te - indexOffset;
        if (i0 >= 0 && i1 < candles.length) {
          final x0 = slot * i0 + slot / 2;
          final x1 = slot * i1 + slot / 2;
          canvas.drawLine(
            Offset(x0, y(sp)),
            Offset(x1, y(ep)),
            Paint()
              ..color = AppTokens.info.withValues(alpha: 0.9)
              ..strokeWidth = 1.4,
          );
        }
      }

      // Touch triangles (Telegram-style markers).
      for (final fullIdx in level!.touchIndexes) {
        final i = fullIdx - indexOffset;
        if (i < 0 || i >= candles.length) continue;
        final cx = slot * i + slot / 2;
        final isRes = level!.side == LevelSide.resistance;
        final tipY = isRes ? yp - 7 : yp + 7;
        final baseY = isRes ? yp - 1 : yp + 1;
        final path = Path()
          ..moveTo(cx, tipY)
          ..lineTo(cx - 4.5, baseY)
          ..lineTo(cx + 4.5, baseY)
          ..close();
        canvas.drawPath(path, Paint()..color = levelColor);
      }
    }

    if (showMa && candles.length > 25) {
      final closes = candles.map((c) => c.close).toList();
      final e20 = emaSeries(closes, 20);
      final e50 = emaSeries(closes, 50);
      _drawLine(canvas, size, e20, y, AppTokens.info.withValues(alpha: 0.85));
      _drawLine(canvas, size, e50, y, AppTokens.accentDeep.withValues(alpha: 0.8));
    }

    final bodyW = (slot * 0.58).clamp(1.4, 6.5);

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final cx = slot * i + slot / 2;
      final color = c.isBullish ? AppTokens.bull : AppTokens.bear;
      final wick = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(cx, y(c.high)), Offset(cx, y(c.low)), wick);

      final top = y(c.open > c.close ? c.open : c.close);
      final bottom = y(c.open > c.close ? c.close : c.open);
      final rect = Rect.fromLTRB(
        cx - bodyW / 2,
        top,
        cx + bodyW / 2,
        bottom == top ? top + 1 : bottom,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        Paint()..color = color,
      );
    }

    final washColor = switch (bias) {
      StructureBias.bullish => AppTokens.bull,
      StructureBias.bearish => AppTokens.bear,
      StructureBias.neutral => AppTokens.accent,
    };
    final wash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          washColor.withValues(alpha: 0.07),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> series,
    double Function(double) y,
    Color color,
  ) {
    if (series.length < 2) return;
    final path = Path();
    final slot = size.width / series.length;
    for (var i = 0; i < series.length; i++) {
      final x = slot * i + slot / 2;
      final p = Offset(x, y(series[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.candles != candles ||
      oldDelegate.level?.price != level?.price ||
      oldDelegate.level?.touches != level?.touches ||
      oldDelegate.bias != bias ||
      oldDelegate.showMa != showMa;
}
