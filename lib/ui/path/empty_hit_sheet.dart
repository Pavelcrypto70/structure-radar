import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/path_l10n.dart';
import '../../theme/tokens.dart';

/// Full-screen teach page when a mission scan returns 0 hits.
///
/// Intentionally NOT a [showModalBottomSheet] — Flutter web has repeated
/// null-check crashes in modal sheet layout for some viewport/browser combos.
Future<void> showEmptyHitSheet(
  BuildContext context, {
  required PathL10n pl,
  required VoidCallback onContinue,
  VoidCallback? onRetry,
}) async {
  if (!context.mounted) return;
  // Don't await haptics — on some web/test hosts the future never completes
  // and the teach page never opens.
  // ignore: unawaited_futures
  HapticFeedback.selectionClick().ignore();

  await Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _EmptyHitPage(
        pl: pl,
        onContinue: onContinue,
        onRetry: onRetry,
      ),
    ),
  );
}

class _EmptyHitPage extends StatelessWidget {
  const _EmptyHitPage({
    required this.pl,
    required this.onContinue,
    this.onRetry,
  });

  final PathL10n pl;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  static const _titleStyle = TextStyle(
    color: SrColors.text,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const _bodyStyle = TextStyle(
    color: SrColors.muted,
    fontSize: 15,
    height: 1.45,
  );
  static const _pointStyle = TextStyle(
    color: SrColors.text,
    fontSize: 15,
    height: 1.4,
  );
  static const _kickerStyle = TextStyle(
    color: SrColors.accent,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SrColors.bg,
      appBar: AppBar(
        backgroundColor: SrColors.bg,
        foregroundColor: SrColors.text,
        elevation: 0,
        title: Text(pl.emptyKicker, style: _kickerStyle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text(pl.emptyTitle, style: _titleStyle),
            const SizedBox(height: 12),
            Text(pl.emptyBody, style: _bodyStyle),
            const SizedBox(height: 20),
            for (final point in pl.emptyPoints)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                    Expanded(child: Text(point, style: _pointStyle)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: SrColors.accent,
                  foregroundColor: SrColors.onAccent,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onContinue();
                },
                child: Text(pl.emptyContinue),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: SrColors.text,
                  side: const BorderSide(color: SrColors.line),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry?.call();
                },
                child: Text(pl.emptyRetry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
