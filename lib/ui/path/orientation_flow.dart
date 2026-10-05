import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'path_kit.dart';

/// P0 — three full-screen orientation steps (progress = persisted orientStep).
class OrientationFlow extends StatelessWidget {
  const OrientationFlow({super.key});

  static const _icons = [
    Icons.visibility_outlined,
    Icons.layers_outlined,
    Icons.flag_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final path = context.watch<PathController>();
    final pl = PathL10n(context.watch<LocaleController>().lang);
    final theme = Theme.of(context).textTheme;
    final idx = path.orientStep.clamp(0, 2); // 0..2
    final step = idx + 1;

    return PathPage(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PathProgressBars(total: 3, done: step),
          const SizedBox(height: 14),
          PathCap(pl.orientKicker(step)),
        ],
      ),
      body: AnimatedSwitcher(
        duration: SrMotion.standard,
        switchInCurve: SrMotion.curveIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: Column(
          key: ValueKey(step),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SrColors.accentSoft,
                borderRadius: BorderRadius.circular(SrRadius.lg),
                border: Border.all(
                  color: SrColors.accent.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(_icons[idx], color: SrColors.accent, size: 28),
            ),
            const SizedBox(height: 24),
            Text(pl.orientTitle(step), style: theme.headlineLarge),
            const SizedBox(height: 16),
            Text(pl.orientBody(step), style: theme.bodyMedium),
            const SizedBox(height: 24),
            PathPoints(pl.orientPoints(step)),
          ],
        ),
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PathButton(label: pl.orientCta(step), onPressed: path.advanceOrient),
          const SizedBox(height: 10),
          Text(pl.eduFooter, style: theme.bodySmall),
        ],
      ),
    );
  }
}
