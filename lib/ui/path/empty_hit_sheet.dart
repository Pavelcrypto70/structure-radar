import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/path_l10n.dart';
import '../../services/telegram_bridge.dart';
import '../../theme/tokens.dart';

/// Full-screen teach page when a mission scan returns 0 hits.
/// Funnel beat: empty → Desk Club (see live reads / ask about the setup).
Future<void> showEmptyHitSheet(
  BuildContext context, {
  required PathL10n pl,
  required VoidCallback onContinue,
  VoidCallback? onRetry,
}) async {
  if (!context.mounted) return;
  // Don't await haptics — on some web/test hosts the future never completes.
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

  Future<void> _openClub() async {
    debugPrint(
      'tg_cta_tap source=${TelegramBridge.communitySource}_empty_scan',
    );
    await launchUrl(
      TelegramBridge.communityHubUri(),
      mode: LaunchMode.externalApplication,
    );
  }

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
            const SizedBox(height: 18),
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
                    Expanded(child: Text(point, style: _pointStyle)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _DeskClubCard(pl: pl, onOpen: _openClub),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: SrColors.accent,
                  foregroundColor: SrColors.onAccent,
                ),
                onPressed: () async {
                  await _openClub();
                  // Stay on page — user can come back and continue the path.
                },
                icon: const Icon(Icons.forum_outlined, size: 20),
                label: Text(pl.emptyClubOpen),
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
                  onContinue();
                },
                child: Text(pl.emptyContinue),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry?.call();
                },
                child: Text(
                  pl.emptyRetry,
                  style: const TextStyle(color: SrColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeskClubCard extends StatelessWidget {
  const _DeskClubCard({required this.pl, required this.onOpen});

  final PathL10n pl;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(SrRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SrColors.accentSoft, SrColors.accentDim],
            ),
            borderRadius: BorderRadius.circular(SrRadius.lg),
            border: Border.all(color: SrColors.accent.withValues(alpha: 0.55)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: SrColors.bg.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(SrRadius.md),
                      border: Border.all(
                        color: SrColors.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      color: SrColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pl.emptyClubKicker, style: const TextStyle(
                          color: SrColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        )),
                        const SizedBox(height: 2),
                        Text(
                          pl.emptyClubTitle,
                          style: const TextStyle(
                            color: SrColors.text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: SrColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                pl.emptyClubBody,
                style: const TextStyle(
                  color: SrColors.muted,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                TelegramBridge.communityHubHandle,
                style: const TextStyle(
                  color: SrColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
