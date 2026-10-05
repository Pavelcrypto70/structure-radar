import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'journey_map.dart';
import 'path_kit.dart';

/// Top-of-Radar card. Priority: finish mission → daily scan → check-in →
/// glossary → club → academy → day clear.
class NextStepCard extends StatelessWidget {
  const NextStepCard({
    super.key,
    required this.onScan,
    required this.onOpenResults,
    this.scanning = false,
  });

  final VoidCallback onScan;
  final VoidCallback onOpenResults;
  final bool scanning;

  @override
  Widget build(BuildContext context) {
    final path = context.watch<PathController>();
    final pl = PathL10n(context.watch<LocaleController>().lang);
    final theme = Theme.of(context).textTheme;

    String title;
    String body;
    String? cta;
    VoidCallback? onCta;
    String? ctaSecondary;
    VoidCallback? onSecondary;
    IconData icon = Icons.flag_outlined;
    Color accent = SrColors.accent;

    if (!path.missionsDone) {
      final n = (path.literacyStep + 1).clamp(1, 4);
      title = pl.nsMissionTitle(n);
      body = pl.missionGoal(n);
      cta = pl.nsMissionCta;
      onCta = () => path.startMission(n);
      icon = Icons.explore_outlined;
    } else if (!path.scannedToday) {
      title = pl.nsDailyTitle;
      body = pl.nsDailyBody(path.habitDays);
      cta = pl.nsDailyCta;
      onCta = scanning ? null : onScan;
      icon = Icons.radar;
    } else if (path.canCheckInToday) {
      title = pl.nsCheckInTitle;
      body = pl.nsCheckInBody;
      cta = pl.nsCheckInCta;
      onCta = path.markHabitDay;
      ctaSecondary = pl.nsOpenResults;
      onSecondary = onOpenResults;
      icon = Icons.event_available_outlined;
    } else if (!path.glossaryTourSeen && path.hitsOpened < 3) {
      title = pl.nsGlossaryTitle(3 - path.hitsOpened);
      body = pl.nsGlossaryBody(path.hitsOpened);
      cta = pl.nsOpenResults;
      onCta = onOpenResults;
      icon = Icons.menu_book_outlined;
    } else if (!path.clubBridgeSeen && path.habitDays < 3) {
      title = pl.nsClubTitle(3 - path.habitDays);
      body = pl.nsClubBody(path.habitDays);
      icon = Icons.forum_outlined;
    } else if (!path.academyBridgeSeen && path.habitDays < 7) {
      title = pl.nsAcademyTitle(7 - path.habitDays);
      body = pl.nsAcademyBody(path.habitDays);
      icon = Icons.school_outlined;
    } else {
      title = pl.nsDoneTitle;
      body = pl.nsDoneBody;
      icon = Icons.check_circle_outline;
      accent = SrColors.bull;
    }

    return Container(
      padding: const EdgeInsets.all(SrSpace.lg),
      decoration: BoxDecoration(
        color: SrColors.surface,
        borderRadius: BorderRadius.circular(SrRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: PathCap(pl.nsKicker, color: accent)),
              InkWell(
                onTap: () => JourneyMapScreen.open(context),
                borderRadius: BorderRadius.circular(SrRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: SrColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(pl.nsMap, style: theme.labelMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SrRadius.sm),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.titleMedium),
                    const SizedBox(height: 4),
                    Text(body, style: theme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          if (cta != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PathButton(label: cta, onPressed: onCta, compact: true),
                ),
                if (ctaSecondary != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: PathButton(
                      label: ctaSecondary,
                      onPressed: onSecondary,
                      secondary: true,
                      compact: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
