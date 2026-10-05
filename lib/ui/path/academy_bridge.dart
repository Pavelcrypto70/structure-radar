import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'path_kit.dart';

/// P5 — soft Trade Master / academy bridge after 7 habit days.
/// Educational and optional: no paywall, "Later" is always one tap.
class AcademyBridge extends StatelessWidget {
  const AcademyBridge({super.key});

  static final academyUri = Uri.parse('https://pavelcrypto70.github.io/trade-master/');

  @override
  Widget build(BuildContext context) {
    final path = context.read<PathController>();
    final pl = PathL10n(context.watch<LocaleController>().lang);
    final theme = Theme.of(context).textTheme;

    return PathPage(
      header: PathCap(pl.acKicker),
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
              Icons.school_outlined,
              color: SrColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(pl.acTitle, style: theme.headlineLarge),
          const SizedBox(height: 16),
          Text(pl.acBody, style: theme.bodyMedium),
          const SizedBox(height: 24),
          PathPoints(pl.acPoints),
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PathButton(
            label: pl.acLearn,
            icon: Icons.open_in_new,
            onPressed: () async {
              path.dismissAcademyBridge();
              await launchUrl(academyUri, mode: LaunchMode.externalApplication);
            },
          ),
          const SizedBox(height: 10),
          PathButton(
            label: pl.later,
            secondary: true,
            compact: true,
            onPressed: path.dismissAcademyBridge,
          ),
        ],
      ),
    );
  }
}
