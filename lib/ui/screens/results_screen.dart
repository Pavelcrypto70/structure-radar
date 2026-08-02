import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/detection_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();

    if (c.results.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Results', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                c.scanning
                    ? 'Scan in progress…'
                    : 'No detections yet. Run a scan from the Radar tab.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        itemCount: c.results.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Results',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${c.results.length} setups · sorted by score',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Educational heuristics only — not trade signals.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTokens.warn,
                        ),
                  ),
                ],
              ),
            );
          }
          final d = c.results[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DetectionCard(
              detection: d,
              onTap: () => c.selectDetection(d),
            ),
          );
        },
      ),
    );
  }
}
