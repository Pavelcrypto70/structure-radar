import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/disclaimers.dart';
import '../../domain/models.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/detection_card.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Text(
            'Structure Radar',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan Binance, Bybit and Gate.io USDT pairs for structure shifts, MA regime flips, and S/R interactions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.bgSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTokens.strokeSoft),
            ),
            child: Text(
              AppDisclaimers.shortBanner,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, 'Exchanges'),
          Wrap(
            children: ExchangeId.values.map((e) {
              final on = c.selectedExchanges.contains(e);
              return FilterChipToggle(
                label: e.label,
                selected: on,
                onTap: () {
                  final next = {...c.selectedExchanges};
                  on ? next.remove(e) : next.add(e);
                  c.selectedExchanges = next;
                  c.notifyListeners();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _sectionTitle(context, 'Timeframes'),
          Wrap(
            children: AppTimeframe.values.map((e) {
              final on = c.selectedTimeframes.contains(e);
              return FilterChipToggle(
                label: e.label,
                selected: on,
                onTap: () {
                  final next = {...c.selectedTimeframes};
                  on ? next.remove(e) : next.add(e);
                  c.selectedTimeframes = next;
                  c.notifyListeners();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _sectionTitle(context, 'Detectors'),
          Wrap(
            children: DetectorKind.values.map((e) {
              final on = c.selectedDetectors.contains(e);
              return FilterChipToggle(
                label: e.label,
                selected: on,
                onTap: () {
                  final next = {...c.selectedDetectors};
                  on ? next.remove(e) : next.add(e);
                  c.selectedDetectors = next;
                  c.notifyListeners();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Min score', style: Theme.of(context).textTheme.titleMedium),
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
            activeColor: AppTokens.accent,
            onChanged: (v) {
              c.minScore = v;
              c.notifyListeners();
            },
          ),
          const SizedBox(height: 8),
          if (c.scanning && c.progress != null) ...[
            LinearProgressIndicator(
              value: c.progress!.fraction == 0 ? null : c.progress!.fraction,
              color: AppTokens.accent,
              backgroundColor: AppTokens.bgSoft,
            ),
            const SizedBox(height: 8),
            Text(
              c.progress!.label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
          if (c.error != null) ...[
            Text(c.error!, style: const TextStyle(color: AppTokens.bear)),
            const SizedBox(height: 12),
          ],
          if (c.results.isNotEmpty) ...[
            _sectionTitle(context, 'Latest results (${c.results.length})'),
            const SizedBox(height: 8),
            ...c.results.take(8).map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DetectionCard(
                      detection: d,
                      onTap: () => c.selectDetection(d),
                    ),
                  ),
                ),
            if (c.results.length > 8)
              Text(
                'Open Results for the full list.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
