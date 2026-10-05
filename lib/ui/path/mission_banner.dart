import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models.dart';
import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/tokens.dart';
import 'empty_hit_sheet.dart';
import 'path_kit.dart';

/// Mission overlay on the Radar tab: goal, live step hint, lens summary.
class MissionBanner extends StatelessWidget {
  const MissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.watch<PathController>();
    final c = context.watch<ScanController>();
    final locale = context.watch<LocaleController>();
    final pl = PathL10n(locale.lang);
    final n = path.activeMission;
    if (n == null) return const SizedBox.shrink();
    final theme = Theme.of(context).textTheme;

    final emptyAfterScan = c.lensScanDone && !c.scanning && c.results.isEmpty;
    final String hint;
    if (c.scanning) {
      hint = pl.bannerScanning;
    } else if (path.missionHitReady) {
      hint = pl.bannerReady;
    } else if (emptyAfterScan) {
      hint = pl.bannerEmpty;
    } else if (c.results.isNotEmpty) {
      hint = pl.bannerOpenHit(n);
    } else {
      hint = pl.bannerFind;
    }

    final kind = path.activeMissionKind;
    final detector = kind == null
        ? pl.lensAll
        : locale.t.detectorLabel(kind.name);
    final tfs = (c.selectedTimeframes.toList()
          ..sort((a, b) => a.index.compareTo(b.index)))
        .map((e) => e.label)
        .join('/');

    return Container(
      padding: const EdgeInsets.all(SrSpace.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SrColors.accentSoft, SrColors.accentDim],
        ),
        borderRadius: BorderRadius.circular(SrRadius.lg),
        border: Border.all(color: SrColors.accent.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: PathCap(pl.bannerKicker(n))),
              TextButton(
                onPressed: path.leaveMission,
                style: TextButton.styleFrom(
                  foregroundColor: SrColors.muted,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(pl.bannerBack),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(pl.missionName(n), style: theme.headlineSmall),
          const SizedBox(height: 6),
          Text(pl.missionGoal(n), style: theme.bodyMedium),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SrSpace.md),
            decoration: BoxDecoration(
              color: SrColors.bg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SrRadius.md),
              border: Border.all(color: SrColors.lineSoft),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  path.missionHitReady
                      ? Icons.check_circle_outline
                      : Icons.arrow_forward_rounded,
                  size: 18,
                  color: path.missionHitReady
                      ? SrColors.bull
                      : SrColors.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    style: theme.bodyMedium?.copyWith(color: SrColors.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pl.lensLine(detector, tfs, c.minScore.round()),
            style: theme.labelSmall,
          ),
          if (path.missionHitReady) ...[
            const SizedBox(height: 12),
            PathButton(
              label: pl.bannerComplete,
              onPressed: () => path.completeMission(),
            ),
          ] else if (emptyAfterScan) ...[
            const SizedBox(height: 12),
            PathButton(
              label: pl.bannerWhyEmpty,
              onPressed: () => showEmptyHitSheet(
                context,
                pl: pl,
                onContinue: () => path.completeMission(emptyOk: true),
              ),
            ),
          ],
        ],
      ),
    );
  }
}