import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'journey_map.dart';
import 'path_kit.dart';

/// P1 — mission rail 1..4, locked until the previous one is done.
class LiteracyHome extends StatelessWidget {
  const LiteracyHome({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.watch<PathController>();
    final pl = PathL10n(context.watch<LocaleController>().lang);
    final theme = Theme.of(context).textTheme;
    final done = path.literacyStep.clamp(0, 4);

    return PathPage(
      header: Row(
        children: [
          Expanded(child: PathCap(pl.homeKicker)),
          TextButton.icon(
            onPressed: () => JourneyMapScreen.open(context),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: Text(pl.nsMap),
            style: TextButton.styleFrom(foregroundColor: SrColors.accent),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pl.homeTitle, style: theme.headlineLarge),
          const SizedBox(height: 10),
          Text(pl.homeSub, style: theme.bodyMedium),
          const SizedBox(height: 18),
          PathProgressBars(total: 4, done: done),
          const SizedBox(height: 8),
          Text(
            pl.homeProgress(done),
            style: theme.labelMedium?.copyWith(color: SrColors.accent),
          ),
          const SizedBox(height: 20),
          for (var n = 1; n <= 4; n++) ...[
            _MissionCard(n: n, pl: pl, path: path),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          Text(pl.eduFooter, style: theme.bodySmall),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.n, required this.pl, required this.path});
  final int n;
  final PathL10n pl;
  final PathController path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final done = path.missionDone(n);
    final open = path.missionUnlocked(n) && !done;
    final locked = !done && !open;
    final accent = done
        ? SrColors.bull
        : (open ? SrColors.accent : SrColors.faint);

    return AnimatedOpacity(
      duration: SrMotion.standard,
      opacity: locked ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.all(SrSpace.lg),
        decoration: BoxDecoration(
          color: open ? SrColors.surface2 : SrColors.surface,
          borderRadius: BorderRadius.circular(SrRadius.lg),
          border: Border.all(
            color: open
                ? SrColors.accent.withValues(alpha: 0.5)
                : SrColors.lineSoft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.14),
                    border: Border.all(color: accent.withValues(alpha: 0.6)),
                  ),
                  child: done
                      ? Icon(Icons.check, size: 18, color: accent)
                      : (locked
                            ? Icon(Icons.lock_outline, size: 16, color: accent)
                            : Text(
                                '$n',
                                style: theme.labelLarge?.copyWith(
                                  color: accent,
                                ),
                              )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pl.missionName(n), style: theme.titleMedium),
                      const SizedBox(height: 2),
                      Text(pl.missionTech(n), style: theme.labelSmall),
                    ],
                  ),
                ),
                if (done)
                  PathChip(label: pl.missionDoneLabel, color: SrColors.bull),
              ],
            ),
            const SizedBox(height: 10),
            Text(pl.missionGoal(n), style: theme.bodyMedium),
            if (open) ...[
              const SizedBox(height: 14),
              PathButton(
                label: pl.missionStart(n),
                onPressed: () => path.startMission(n),
              ),
            ] else if (locked) ...[
              const SizedBox(height: 8),
              Text(pl.missionLocked, style: theme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
