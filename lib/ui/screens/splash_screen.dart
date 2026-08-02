import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_lang.dart';
import '../../state/locale_controller.dart';
import '../../theme/tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final t = locale.t;
    final reduce = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: SrColors.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _ambient,
            builder: (_, __) => CustomPaint(
              painter: _RadarAtmospherePainter(
                t: reduce ? 0.2 : _ambient.value,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t.splashMark,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => locale.setLang(
                          locale.lang == AppLang.ru ? AppLang.en : AppLang.ru,
                        ),
                        child: Text(
                          locale.lang == AppLang.ru ? 'EN' : 'RU',
                          style: const TextStyle(
                            color: SrColors.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: reduce
                        ? const AlwaysStoppedAnimation(1)
                        : CurvedAnimation(
                            parent: _enter,
                            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.splashTag,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: SrColors.accent,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.splashTitle,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.splashSub,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onDone();
                      },
                      child: Text(t.splashCta),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.eduOnly,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarAtmospherePainter extends CustomPainter {
  _RadarAtmospherePainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final sweep = t * math.pi * 2;
    final center = Offset(size.width * 0.72, size.height * 0.28);
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(
        center,
        36.0 * i,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = SrColors.accent.withValues(alpha: 0.05 + i * 0.015),
      );
    }
    final ray = Paint()
      ..shader = SweepGradient(
        startAngle: sweep,
        endAngle: sweep + 1.2,
        colors: [
          SrColors.accent.withValues(alpha: 0.0),
          SrColors.accent.withValues(alpha: 0.18),
          SrColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 220));
    canvas.drawCircle(center, 220, ray);

    // Scanline texture
    final line = Paint()..color = SrColors.lineSoft.withValues(alpha: 0.35);
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarAtmospherePainter oldDelegate) =>
      oldDelegate.t != t;
}
