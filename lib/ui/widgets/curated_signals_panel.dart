import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_lang.dart';
import '../../services/curated_signals_store.dart';
import '../../state/locale_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';

/// Shared 90+ setups — hosted feed + local scan merge.
class CuratedSignalsPanel extends StatelessWidget {
  const CuratedSignalsPanel({super.key, required this.onOpen});

  final void Function(CuratedInboxItem item) onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final t = context.watch<LocaleController>().t;
    final items = c.curatedInbox;
    final unread = c.curatedUnreadCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTokens.bgElevated,
        borderRadius: BorderRadius.circular(AppTokens.radius20),
        border: Border.all(
          color: unread > 0
              ? AppTokens.accent.withValues(alpha: 0.45)
              : AppTokens.strokeSoft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 18,
                color: unread > 0 ? AppTokens.accent : AppTokens.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.curatedSignalsTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.accentSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    t.curatedUnreadBadge(unread),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTokens.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.curatedSignalsBody,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (items.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              t.curatedSignalsEmpty,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTokens.textMuted,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            for (final item in items.take(5)) ...[
              _CuratedRow(
                item: item,
                lang: context.watch<LocaleController>().lang,
                onTap: () => onOpen(item),
              ),
              if (item != items.take(5).last)
                Divider(height: 16, color: AppTokens.strokeSoft),
            ],
            if (items.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                t.curatedSignalsMore(items.length - 5),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
            if (unread > 0) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => c.markAllCuratedRead(),
                  child: Text(t.curatedMarkAllRead),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CuratedRow extends StatelessWidget {
  const _CuratedRow({
    required this.item,
    required this.lang,
    required this.onTap,
  });

  final CuratedInboxItem item;
  final AppLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final snap = item.snapshot;
    final t = L10n(lang);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!item.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: AppTokens.accent,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${snap.symbolDisplay}/USDT · ${snap.score.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    snap.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.curatedRowMeta(
                      snap.exchange.label,
                      snap.timeframe.label,
                    ),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppTokens.textMuted),
          ],
        ),
      ),
    );
  }
}
