import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/path_l10n.dart';
import '../../theme/tokens.dart';
import 'path_kit.dart';

/// Teach sheet when a mission scan returns 0 hits.
/// [onContinue] counts the mission as understood; [onRetry] just closes.
Future<void> showEmptyHitSheet(
  BuildContext context, {
  required PathL10n pl,
  required VoidCallback onContinue,
  VoidCallback? onRetry,
}) {
  if (!context.mounted) return Future.value();
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: SrColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(SrRadius.sheet)),
    ),
    builder: (ctx) {
      final theme = Theme.of(ctx).textTheme;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 20 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SrColors.line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PathCap(pl.emptyKicker),
                const SizedBox(height: 10),
                Text(
                  pl.emptyTitle,
                  style: theme.headlineSmall?.copyWith(color: SrColors.text),
                ),
                const SizedBox(height: 10),
                Text(
                  pl.emptyBody,
                  style: theme.bodyMedium?.copyWith(color: SrColors.muted),
                ),
                const SizedBox(height: 16),
                PathPoints(pl.emptyPoints),
                const SizedBox(height: 8),
                PathButton(
                  label: pl.emptyContinue,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onContinue();
                  },
                ),
                const SizedBox(height: 10),
                PathButton(
                  label: pl.emptyRetry,
                  secondary: true,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onRetry?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
