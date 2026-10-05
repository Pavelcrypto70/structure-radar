import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'path_kit.dart';

/// P2 — missions done: invite into the daily habit.
class Phase2Bridge extends StatelessWidget {
  const Phase2Bridge({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.read<PathController>();
    final pl = PathL10n(context.watch<LocaleController>().lang);
    final theme = Theme.of(context).textTheme;

    return PathPage(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PathProgressBars(total: 4, done: 4),
          const SizedBox(height: 14),
          PathCap(pl.p2Kicker, color: SrColors.bull),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SrColors.bullSoft,
              borderRadius: BorderRadius.circular(SrRadius.lg),
              border: Border.all(color: SrColors.bull.withValues(alpha: 0.4)),
            ),
            child: const Icon(
              Icons.local_fire_department_outlined,
              color: SrColors.bull,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(pl.p2Title, style: theme.headlineLarge),
          const SizedBox(height: 16),
          Text(pl.p2Body, style: theme.bodyMedium),
          const SizedBox(height: 24),
          PathPoints(pl.p2Points),
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PathButton(label: pl.p2Cta, onPressed: path.dismissPhase2Bridge),
          const SizedBox(height: 10),
          Text(pl.eduFooter, style: theme.bodySmall),
        ],
      ),
    );
  }
}
