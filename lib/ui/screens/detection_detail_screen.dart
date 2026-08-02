import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/models.dart';
import '../../l10n/app_lang.dart';
import '../../l10n/detection_copy.dart';
import '../../l10n/glossary_l10n.dart';
import '../../state/locale_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/candle_chart.dart';

class DetectionDetailScreen extends StatelessWidget {
  const DetectionDetailScreen({super.key, required this.detection});

  final Detection detection;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final t = locale.t;
    final title = DetectionCopy.title(detection, locale.lang);
    final summary = DetectionCopy.summary(detection, locale.lang);
    final df = DateFormat('yyyy-MM-dd HH:mm');
    final glossaryList = GlossaryLocalized.entries(locale.lang);
    Map<String, String>? glossary;
    for (final e in glossaryList) {
      if (e['id'] == detection.kind.glossaryKey) {
        glossary = e;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(title: Text(detection.symbol.display)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${detection.exchange.label} · ${detection.timeframe.label} · score ${detection.score.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (detection.symbol.alsoListedOn.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detection.symbol.alsoOnLabel(ru: locale.lang == AppLang.ru),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${t.detectedBar}: ${df.format(detection.detectedAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          CandleChart(
            candles: detection.candles,
            level: detection.level,
            bias: detection.bias,
            showMa: detection.level == null,
          ),
          const SizedBox(height: 16),
          Text(summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          ...detection.detailBullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('·  ', style: TextStyle(color: AppTokens.accent)),
                  Expanded(
                    child: Text(b, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
          if (glossary != null) ...[
            const SizedBox(height: 24),
            Text(t.mechanic, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(glossary['mechanica']!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(t.limitations, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(glossary['limitations']!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 24),
          Text(t.notAdviceFooter, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
