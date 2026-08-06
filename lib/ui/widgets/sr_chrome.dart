import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class SrSurface extends StatelessWidget {
  const SrSurface({
    super.key,
    required this.child,
    this.padding,
    this.accentBorder = false,
    this.gradient = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool accentBorder;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(SrSpace.lg),
      decoration: BoxDecoration(
        color: gradient ? null : SrColors.surface,
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [SrColors.surface, SrColors.bgElevated],
              )
            : null,
        borderRadius: BorderRadius.circular(SrRadius.lg),
        border: Border.all(
          color: accentBorder
              ? SrColors.accent.withValues(alpha: 0.35)
              : SrColors.lineSoft,
        ),
      ),
      child: child,
    );
  }
}

class SrSectionTitle extends StatelessWidget {
  const SrSectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: SrColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SrStatTile extends StatelessWidget {
  const SrStatTile({
    super.key,
    required this.label,
    required this.value,
    this.sub,
  });

  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return SrSurface(
      padding: const EdgeInsets.all(SrSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class SrKicker extends StatelessWidget {
  const SrKicker(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: SrColors.accent,
        letterSpacing: 1.4,
      ),
    );
  }
}

class SrModeBadge extends StatelessWidget {
  const SrModeBadge({super.key, required this.live});
  final bool live;

  @override
  Widget build(BuildContext context) {
    final color = live ? SrColors.bull : SrColors.warn;
    final label = live ? 'LIVE DATA' : 'WEB RELAY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class SrEmptyState extends StatelessWidget {
  const SrEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SrSurface(
      gradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SrColors.accentSoft,
              borderRadius: BorderRadius.circular(SrRadius.md),
              border: Border.all(color: SrColors.lineSoft),
            ),
            child: Icon(icon, color: SrColors.accent, size: 22),
          ),
          const SizedBox(height: SrSpace.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class SrSkeleton extends StatelessWidget {
  const SrSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget bar(double w) => Container(
      width: w,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: const LinearGradient(
          colors: [SrColors.surface2, SrColors.surface3, SrColors.surface2],
        ),
      ),
    );

    return SrSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(120),
          const SizedBox(height: 14),
          bar(220),
          const SizedBox(height: 10),
          bar(180),
          const SizedBox(height: 18),
          bar(double.infinity),
        ],
      ),
    );
  }
}
