import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/disclaimers.dart';
import '../../domain/models.dart';
import '../../state/locale_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/tokens.dart';
import '../widgets/coach_banner.dart';
import '../widgets/detection_card.dart';
import '../widgets/sr_chrome.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({
    super.key,
    required this.showCoach,
    required this.onDismissCoach,
  });

  final bool showCoach;
  final VoidCallback onDismissCoach;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final locale = context.watch<LocaleController>();
    final t = locale.t;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
      children: [
        SrSurface(
          gradient: true,
          accentBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SrKicker(t.isRu ? 'РАДАР' : 'RADAR'),
                  const Spacer(),
                  SrModeBadge(live: !kIsWeb),
                ],
              ),
              const SizedBox(height: 10),
              Text(t.scanTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(t.scanSubtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text(
                t.etaHint,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: SrColors.accent,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (showCoach) ...[
          CoachBanner(t: t, onDismiss: onDismissCoach),
          const SizedBox(height: 12),
        ],
        SrSurface(
          padding: const EdgeInsets.all(SrSpace.md),
          child: Text(
            AppDisclaimers.shortBanner(locale.lang),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 20),
        SrSectionTitle(t.exchanges),
        const SizedBox(height: 10),
        Wrap(
          children: ExchangeId.values
              .map(
                (e) => FilterChipToggle(
                  label: e.label,
                  selected: c.selectedExchanges.contains(e),
                  onTap: () => c.toggleExchange(e),
                ),
              )
              .toList(),
        ),
        SrSectionTitle(t.timeframes),
        const SizedBox(height: 10),
        Wrap(
          children: AppTimeframe.values
              .map(
                (e) => FilterChipToggle(
                  label: e.label,
                  selected: c.selectedTimeframes.contains(e),
                  onTap: () => c.toggleTimeframe(e),
                ),
              )
              .toList(),
        ),
        SrSectionTitle(t.detectors),
        const SizedBox(height: 10),
        Wrap(
          children: DetectorKind.values
              .map(
                (e) => FilterChipToggle(
                  label: t.detectorLabel(e.name),
                  selected: c.selectedDetectors.contains(e),
                  onTap: () => c.toggleDetector(e),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(t.minScore, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text(
              c.minScore.toStringAsFixed(0),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SrColors.accent,
                  ),
            ),
          ],
        ),
        Slider(
          value: c.minScore,
          min: 50,
          max: 90,
          divisions: 8,
          onChanged: c.setMinScore,
        ),
        if (c.scanning) ...[
          const SizedBox(height: 8),
          const SrSkeleton(),
          const SizedBox(height: 12),
          if (c.progress != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 4,
                value: c.progress!.fraction == 0 ? null : c.progress!.fraction,
                color: SrColors.accent,
                backgroundColor: SrColors.surface2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.progressOf(
                c.progress!.done,
                c.progress!.total,
                c.progress!.label,
              ),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ],
        if (c.error != null) ...[
          const SizedBox(height: 10),
          Text(c.error!, style: const TextStyle(color: SrColors.bear)),
        ],
        if (c.results.isNotEmpty) ...[
          const SizedBox(height: 18),
          SrSectionTitle('${t.latestResults} (${c.results.length})'),
          const SizedBox(height: 10),
          ...c.results.take(6).map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DetectionCard(
                    detection: d,
                    lang: locale.lang,
                    onTap: () => c.selectDetection(d),
                  ),
                ),
              ),
          if (c.results.length > 6)
            Text(t.openResultsHint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
