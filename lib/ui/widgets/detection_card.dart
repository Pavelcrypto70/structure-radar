import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../l10n/app_lang.dart';
import '../../l10n/detection_copy.dart';
import '../../theme/app_theme.dart';

class DetectionCard extends StatelessWidget {
  const DetectionCard({
    super.key,
    required this.detection,
    required this.lang,
    required this.onTap,
  });

  final Detection detection;
  final AppLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = L10n(lang);
    final biasColor = switch (detection.bias) {
      StructureBias.bullish => AppTokens.bull,
      StructureBias.bearish => AppTokens.bear,
      StructureBias.neutral => AppTokens.info,
    };
    final title = DetectionCopy.title(detection, lang);
    final summary = DetectionCopy.summary(detection, lang);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radius20),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTokens.bgElevated,
            borderRadius: BorderRadius.circular(AppTokens.radius20),
            border: Border.all(color: AppTokens.strokeSoft),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: biasColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              t.detectorShort(detection.kind.name),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppTokens.accent,
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                  ),
                            ),
                            const Spacer(),
                            _ScorePill(score: detection.score),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${detection.symbol.display} · ${detection.exchange.label} · ${detection.timeframe.label}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (detection.symbol.alsoListedOn.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            detection.symbol.alsoOnLabel(ru: lang == AppLang.ru),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTokens.textMuted,
                                ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTokens.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTokens.bgSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTokens.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (score / 100).clamp(0, 1),
                backgroundColor: AppTokens.strokeSoft,
                color: AppTokens.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score.toStringAsFixed(0),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTokens.textPrimary,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class FilterChipToggle extends StatelessWidget {
  const FilterChipToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTokens.accentSoft : AppTokens.bgSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppTokens.accent : AppTokens.stroke,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? AppTokens.accent : AppTokens.textSecondary,
                  fontSize: 12,
                ),
          ),
        ),
      ),
    );
  }
}

class AmbientPanel extends StatelessWidget {
  const AmbientPanel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radius20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF151922),
            Color(0xFF10141B),
            Color(0xFF1A1712),
          ],
        ),
        border: Border.all(color: AppTokens.strokeSoft),
      ),
      child: child,
    );
  }
}
