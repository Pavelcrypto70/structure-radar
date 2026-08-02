import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_lang.dart';
import '../../theme/tokens.dart';
import '../format.dart';
import 'sr_chrome.dart';

Future<void> showScanRecapSheet(
  BuildContext context, {
  required L10n t,
  required int hits,
  required double minScore,
  required int universeSize,
  required int rawPairCount,
  required VoidCallback onOpenResults,
}) {
  HapticFeedback.heavyImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: SrColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(SrRadius.sheet)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
            SrKicker(t.recapKicker),
            const SizedBox(height: 10),
            Text(t.recapTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SrStatTile(
                    label: t.isRu ? 'ХИТЫ' : 'HITS',
                    value: SrFormat.score(hits),
                    sub: t.recapHits(hits),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SrStatTile(
                    label: t.minScore,
                    value: SrFormat.score(minScore),
                  ),
                ),
              ],
            ),
            if (universeSize > 0) ...[
              const SizedBox(height: 10),
              Text(
                t.universeRecap(universeSize, rawPairCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onOpenResults();
                },
                child: Text(t.recapOpenResults),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SrColors.text,
                  side: const BorderSide(color: SrColors.line),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(t.recapClose),
              ),
            ),
          ],
        ),
      );
    },
  );
}
