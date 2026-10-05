import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/path_l10n.dart';
import '../../services/telegram_bridge.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'path_kit.dart';

/// P4 — Desk Club (t.me/Desk_Club) after 3 habit days.
class ClubBridge extends StatelessWidget {
  const ClubBridge({super.key});

  @override
  Widget build(BuildContext context) {
    final path = context.read<PathController>();
    final pl = PathL10n(context.watch<LocaleController>().lang);
    final theme = Theme.of(context).textTheme;

    return PathPage(
      header: PathCap(pl.clubKicker),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SrColors.accentSoft,
              borderRadius: BorderRadius.circular(SrRadius.lg),
              border: Border.all(color: SrColors.accent.withValues(alpha: 0.4)),
            ),
            child: const Icon(
              Icons.forum_outlined,
              color: SrColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(pl.clubTitle, style: theme.headlineLarge),
          const SizedBox(height: 16),
          Text(pl.clubBody, style: theme.bodyMedium),
          const SizedBox(height: 24),
          PathPoints(pl.clubPoints),
          Text(
            TelegramBridge.communityHubHandle,
            style: theme.labelLarge?.copyWith(color: SrColors.accent),
          ),
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PathButton(
            label: pl.clubOpen,
            icon: Icons.open_in_new,
            onPressed: () async {
              debugPrint(
                'tg_cta_tap source=${TelegramBridge.communitySource}_path',
              );
              path.dismissClubBridge();
              await launchUrl(
                TelegramBridge.communityHubUri(),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const SizedBox(height: 10),
          PathButton(
            label: pl.later,
            secondary: true,
            compact: true,
            onPressed: path.dismissClubBridge,
          ),
        ],
      ),
    );
  }
}
