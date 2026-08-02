import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../theme/tokens.dart';
import 'sr_chrome.dart';

class CoachBanner extends StatelessWidget {
  const CoachBanner({
    super.key,
    required this.t,
    required this.onDismiss,
  });

  final L10n t;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SrSurface(
      accentBorder: true,
      padding: const EdgeInsets.all(SrSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SrKicker(t.coachTitle),
                const SizedBox(height: 6),
                Text(t.coachBody, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            child: Text(
              t.coachDismiss,
              style: const TextStyle(color: SrColors.accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
