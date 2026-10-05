import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models.dart';
import '../../l10n/glossary_l10n.dart';
import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'path_kit.dart';

/// P3 — three detector cards (structure / MA / levels), shown after 3 hits.
class GlossaryTour extends StatefulWidget {
  const GlossaryTour({super.key});

  @override
  State<GlossaryTour> createState() => _GlossaryTourState();
}

class _GlossaryTourState extends State<GlossaryTour> {
  int page = 0;
  static const _kinds = DetectorKind.values; // structure, ma, levels

  @override
  Widget build(BuildContext context) {
    final path = context.read<PathController>();
    final lang = context.watch<LocaleController>().lang;
    final pl = PathL10n(lang);
    final theme = Theme.of(context).textTheme;
    final entries = GlossaryLocalized.entries(lang);
    final last = page == _kinds.length - 1;
    final kind = _kinds[page];
    Map<String, String>? entry;
    for (final e in entries) {
      if (e['id'] == kind.glossaryKey) entry = e;
    }
    // Mission numbers align with kinds: structure=1, ma=2, levels=3.
    final lookFor = pl.missionLookFor(page + 1);

    return PathPage(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: PathCap(pl.gtKicker)),
              Text(
                pl.gtCounter(page + 1, _kinds.length),
                style: theme.labelMedium,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: path.dismissGlossaryTour,
                style: TextButton.styleFrom(foregroundColor: SrColors.muted),
                child: Text(pl.skip),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PathProgressBars(total: _kinds.length, done: page + 1),
        ],
      ),
      body: AnimatedSwitcher(
        duration: SrMotion.standard,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: Column(
          key: ValueKey(page),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pl.gtTitle, style: theme.bodyMedium),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SrSpace.lg),
              decoration: BoxDecoration(
                color: SrColors.surface,
                borderRadius: BorderRadius.circular(SrRadius.xl),
                border: Border.all(
                  color: SrColors.accent.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PathChip(label: kind.short),
                  const SizedBox(height: 12),
                  Text(
                    entry?['title'] ?? kind.label,
                    style: theme.headlineMedium,
                  ),
                  if (entry?['subtitle'] != null) ...[
                    const SizedBox(height: 4),
                    Text(entry!['subtitle']!, style: theme.bodySmall),
                  ],
                  const SizedBox(height: 16),
                  PathCap(pl.gtLookFor),
                  const SizedBox(height: 8),
                  Text(
                    lookFor,
                    style: theme.bodyLarge?.copyWith(fontSize: 15),
                  ),
                  if (entry?['limitations'] != null) ...[
                    const SizedBox(height: 16),
                    PathCap(pl.gtLimit, color: SrColors.warn),
                    const SizedBox(height: 8),
                    Text(entry!['limitations']!, style: theme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      footer: PathButton(
        label: last ? pl.gotIt : pl.next,
        onPressed: () {
          if (last) {
            path.dismissGlossaryTour();
          } else {
            setState(() => page++);
          }
        },
      ),
    );
  }
}
