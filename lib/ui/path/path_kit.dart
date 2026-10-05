import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens.dart';

/// Brass primary / ghost button used across the literacy path.
class PathButton extends StatelessWidget {
  const PathButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.icon,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final h = compact ? 44.0 : 52.0;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SrRadius.md),
    );
    void tap() {
      HapticFeedback.selectionClick();
      onPressed?.call();
    }

    final text = Text(label, textAlign: TextAlign.center);
    if (secondary) {
      final style = OutlinedButton.styleFrom(
        foregroundColor: SrColors.text,
        side: const BorderSide(color: SrColors.line),
        backgroundColor: SrColors.surface2,
        minimumSize: Size.fromHeight(h),
        shape: shape,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      );
      return icon == null
          ? OutlinedButton(
              onPressed: onPressed == null ? null : tap,
              style: style,
              child: text,
            )
          : OutlinedButton.icon(
              onPressed: onPressed == null ? null : tap,
              style: style,
              icon: Icon(icon, size: 18),
              label: text,
            );
    }
    final style = FilledButton.styleFrom(
      backgroundColor: SrColors.accent,
      foregroundColor: SrColors.onAccent,
      minimumSize: Size.fromHeight(h),
      shape: shape,
    );
    return icon == null
        ? FilledButton(
            onPressed: onPressed == null ? null : tap,
            style: style,
            child: text,
          )
        : FilledButton.icon(
            onPressed: onPressed == null ? null : tap,
            style: style,
            icon: Icon(icon, size: 18),
            label: text,
          );
  }
}

/// Small status pill (mission lens, DONE / NOW / NEXT, counters).
class PathChip extends StatelessWidget {
  const PathChip({
    super.key,
    required this.label,
    this.color = SrColors.accent,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.22 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mono caption with a brass tick — section/step kicker.
class PathCap extends StatelessWidget {
  const PathCap(this.text, {super.key, this.color = SrColors.accent});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3,
          height: 12,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color, letterSpacing: 1.4),
          ),
        ),
      ],
    );
  }
}

/// Teaching callout: kicker + body on an accent-tinted surface.
class CoachBubble extends StatelessWidget {
  const CoachBubble({
    super.key,
    required this.text,
    this.kicker,
    this.icon = Icons.lightbulb_outline,
    this.trailing,
  });

  final String text;
  final String? kicker;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SrSpace.md),
      decoration: BoxDecoration(
        color: SrColors.accentDim,
        borderRadius: BorderRadius.circular(SrRadius.lg),
        border: Border.all(color: SrColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SrColors.accentSoft,
              borderRadius: BorderRadius.circular(SrRadius.sm),
            ),
            child: Icon(icon, size: 18, color: SrColors.accent),
          ),
          const SizedBox(width: SrSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kicker != null) ...[
                  PathCap(kicker!),
                  const SizedBox(height: 6),
                ],
                Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: SrColors.text),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Segmented progress bars (orientation steps).
class PathProgressBars extends StatelessWidget {
  const PathProgressBars({super.key, required this.total, required this.done});
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final on = i < done;
        return Expanded(
          child: AnimatedContainer(
            duration: SrMotion.standard,
            curve: SrMotion.curveToggle,
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: on ? SrColors.accent : SrColors.line,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

/// Full-screen path page: dark bg, SafeArea, scrollable body + pinned footer.
class PathPage extends StatelessWidget {
  const PathPage({
    super.key,
    required this.body,
    this.footer,
    this.header,
  });

  final Widget body;
  final Widget? footer;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            if (header != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: header,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: body,
              ),
            ),
            if (footer != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                decoration: const BoxDecoration(
                  color: SrColors.bg,
                  border: Border(top: BorderSide(color: SrColors.lineSoft)),
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// Bulleted list with brass tick icons.
class PathPoints extends StatelessWidget {
  const PathPoints(this.points, {super.key});
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: points
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3, right: 10),
                    child: Icon(
                      Icons.arrow_right_alt_rounded,
                      size: 18,
                      color: SrColors.accent,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      p,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
