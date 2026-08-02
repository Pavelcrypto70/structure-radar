import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models.dart';
import '../../state/locale_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/detection_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final locale = context.watch<LocaleController>();
    final t = locale.t;
    final visible = c.visibleResults;

    if (c.results.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.resultsTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                c.scanning ? t.scanInProgress : t.noDetectionsYet,
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
        itemCount: visible.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.resultsTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${visible.length} ${t.setups} · ${t.sortedByScore}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.heuristicsOnly,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTokens.warn,
                        ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChipToggle(
                          label: t.filterAll,
                          selected: c.resultFilterKind == null,
                          onTap: () => c.setResultFilter(null),
                        ),
                        ...DetectorKind.values.map(
                          (k) => FilterChipToggle(
                            label: t.detectorLabel(k.name),
                            selected: c.resultFilterKind == k,
                            onTap: () => c.setResultFilter(k),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      FilterChipToggle(
                        label: t.sortScore,
                        selected: c.resultSort == ResultSort.score,
                        onTap: () => c.setResultSort(ResultSort.score),
                      ),
                      FilterChipToggle(
                        label: t.sortTime,
                        selected: c.resultSort == ResultSort.time,
                        onTap: () => c.setResultSort(ResultSort.time),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          final d = visible[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DetectionCard(
              detection: d,
              lang: locale.lang,
              onTap: () => c.selectDetection(d),
            ),
          );
        },
      ),
    );
  }
}
