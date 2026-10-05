import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/path_l10n.dart';
import '../../theme/tokens.dart';
import '../widgets/sr_chrome.dart';

/// Teach sheet when a mission scan returns 0 hits.
/// Plain Material only (same pattern as [showScanRecapSheet]) — Path* widgets
/// previously crashed Flutter web sheets via flex null-checks.
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
      final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 28 + bottomInset),
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
              SrKicker(pl.emptyKicker),
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
              const SizedBox(height: 14),
              for (final point in pl.emptyPoints)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2, right: 10),
                        child: Icon(
                          Icons.arrow_right_alt_rounded,
                          size: 18,
                          color: SrColors.accent,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style:
                              theme.bodyMedium?.copyWith(color: SrColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onContinue();
                  },
                  child: Text(pl.emptyContinue),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onRetry?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SrColors.text,
                    side: const BorderSide(color: SrColors.line),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(pl.emptyRetry),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
