import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../theme/app_theme.dart';

class DetectionCard extends StatelessWidget {
  const DetectionCard({
    super.key,
    required this.detection,
    required this.onTap,
  });

  final Detection detection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final biasColor = switch (detection.bias) {
      StructureBias.bullish => AppTokens.bull,
      StructureBias.bearish => AppTokens.bear,
      StructureBias.neutral => AppTokens.info,
    };

    return Material(
      color: AppTokens.bgElevated,
      borderRadius: BorderRadius.circular(AppTokens.radius16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
        child: Container(
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radius16),
            border: Border.all(color: AppTokens.strokeSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: biasColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    detection.kind.short,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTokens.accent,
                          fontSize: 11,
                          letterSpacing: 1.1,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    detection.score.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTokens.textPrimary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${detection.symbol.display} · ${detection.exchange.label} · ${detection.timeframe.label}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                detection.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                detection.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
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
