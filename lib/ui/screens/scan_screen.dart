import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/disclaimers.dart';
import '../../domain/models.dart';
import '../../l10n/app_lang.dart';
import '../../state/locale_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/detection_card.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final locale = context.watch<LocaleController>();
    final t = locale.t;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          AmbientPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.scanTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  t.scanSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  t.etaHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTokens.accent,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.bgSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTokens.strokeSoft),
            ),
            child: Text(
              AppDisclaimers.shortBanner(locale.lang),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 22),
          _section(context, t.exchanges),
          Wrap(
            children: ExchangeId.values
                .map(
                  (e) => FilterChipToggle(
                    label: e.label,
                    selected: c.selectedExchanges.contains(e),
                    onTap: () => c.toggleExchange(e),
                  ),
                )
                .toList(),
          ),
          _section(context, t.timeframes),
          Wrap(
            children: AppTimeframe.values
                .map(
                  (e) => FilterChipToggle(
                    label: e.label,
                    selected: c.selectedTimeframes.contains(e),
                    onTap: () => c.toggleTimeframe(e),
                  ),
                )
                .toList(),
          ),
          _section(context, t.detectors),
          Wrap(
            children: DetectorKind.values
                .map(
                  (e) => FilterChipToggle(
                    label: t.detectorLabel(e.name),
                    selected: c.selectedDetectors.contains(e),
                    onTap: () => c.toggleDetector(e),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(t.minScore, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                c.minScore.toStringAsFixed(0),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTokens.accent,
                    ),
              ),
            ],
          ),
          Slider(
            value: c.minScore,
            min: 50,
            max: 90,
            divisions: 8,
            onChanged: c.setMinScore,
          ),
          if (c.scanning && c.progress != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: c.progress!.fraction == 0 ? null : c.progress!.fraction,
                color: AppTokens.accent,
                backgroundColor: AppTokens.bgSoft,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.progressOf(
                c.progress!.done,
                c.progress!.total,
                c.progress!.label,
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (c.error != null) ...[
            const SizedBox(height: 10),
            Text(c.error!, style: const TextStyle(color: AppTokens.bear)),
          ],
          if (c.results.isNotEmpty) ...[
            const SizedBox(height: 18),
            _section(
              context,
              '${t.latestResults} (${c.results.length})',
            ),
            ...c.results.take(6).map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DetectionCard(
                      detection: d,
                      lang: locale.lang,
                      onTap: () => c.selectDetection(d),
                    ),
                  ),
                ),
            if (c.results.length > 6)
              Text(t.openResultsHint, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
