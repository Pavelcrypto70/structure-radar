import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/glossary.dart';
import '../../domain/models.dart';
import '../../theme/app_theme.dart';
import '../widgets/candle_chart.dart';

class DetectionDetailScreen extends StatelessWidget {
  const DetectionDetailScreen({super.key, required this.detection});

  final Detection detection;

  @override
  Widget build(BuildContext context) {
    final g = AppGlossary.byId(detection.kind.glossaryKey);
    final df = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(
        title: Text(detection.symbol.display),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            detection.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '${detection.exchange.label} · ${detection.timeframe.label} · score ${detection.score.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Detected bar: ${df.format(detection.detectedAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          CandleChart(
            candles: detection.candles,
            level: detection.level,
            bias: detection.bias,
          ),
          const SizedBox(height: 16),
          Text(detection.summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          ...detection.detailBullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('·  ', style: TextStyle(color: AppTokens.accent)),
                  Expanded(child: Text(b, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detection.tags
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTokens.bgSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTokens.stroke),
                    ),
                    child: Text(
                      t,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 11,
                            color: AppTokens.textSecondary,
                          ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (g != null) ...[
            const SizedBox(height: 28),
            Text('Mechanic', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(g.mechanica, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text('Limitations', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(g.limitations, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Text(
            'Not financial advice. Pattern heuristics can fail. Do your own research.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
