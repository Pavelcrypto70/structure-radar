import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/models.dart';
import '../../l10n/app_lang.dart';
import '../../l10n/detection_copy.dart';
import '../../l10n/glossary_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/candle_chart.dart';
import '../widgets/detection_card.dart';

class DetectionDetailScreen extends StatefulWidget {
  const DetectionDetailScreen({super.key, required this.detection});

  final Detection detection;

  @override
  State<DetectionDetailScreen> createState() => _DetectionDetailScreenState();
}

class _DetectionDetailScreenState extends State<DetectionDetailScreen> {
  late AppTimeframe _chartTf;
  late List<Candle> _candles;
  final Map<AppTimeframe, List<Candle>> _cache = {};
  bool _loading = false;
  String? _loadError;
  int _fetchGen = 0;

  Detection get d => widget.detection;

  @override
  void initState() {
    super.initState();
    _chartTf = d.timeframe;
    _candles = d.candles;
    _cache[d.timeframe] = d.candles;
  }

  Future<void> _selectTf(AppTimeframe tf) async {
    if (tf == _chartTf && !_loading) return;
    final cached = _cache[tf];
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _chartTf = tf;
        _candles = cached;
        _loadError = null;
        _loading = false;
      });
      return;
    }

    final gen = ++_fetchGen;
    setState(() {
      _chartTf = tf;
      _loading = true;
      _loadError = null;
    });

    try {
      final repo = context.read<ScanController>();
      final candles = await repo.fetchCandlesFor(
        exchange: d.exchange,
        symbol: d.symbol,
        timeframe: tf,
      );
      if (!mounted || gen != _fetchGen) return;
      if (candles.isEmpty) {
        setState(() {
          _loading = false;
          _loadError = context.read<LocaleController>().t.chartLoadFailed;
        });
        return;
      }
      _cache[tf] = candles;
      setState(() {
        _candles = candles;
        _loading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted || gen != _fetchGen) return;
      setState(() {
        _loading = false;
        _loadError = context.read<LocaleController>().t.chartLoadFailed;
      });
    }
  }

  LevelZone? get _chartLevel {
    final level = d.level;
    if (level == null) return null;
    if (_chartTf == d.timeframe) return level;
    return level.priceBandOnly;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final t = locale.t;
    final title = DetectionCopy.title(d, locale.lang);
    final summary = DetectionCopy.summary(d, locale.lang);
    final df = DateFormat('yyyy-MM-dd HH:mm');
    final glossaryList = GlossaryLocalized.entries(locale.lang);
    Map<String, String>? glossary;
    for (final e in glossaryList) {
      if (e['id'] == d.kind.glossaryKey) {
        glossary = e;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(title: Text(d.symbol.display)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${d.exchange.label} · ${d.timeframe.label} · score ${d.score.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (d.symbol.alsoListedOn.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              d.symbol.alsoOnLabel(ru: locale.lang == AppLang.ru),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${t.detectedBar}: ${df.format(d.detectedAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Text(t.chartTf, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            children: AppTimeframe.values.map((tf) {
              final isSignal = tf == d.timeframe;
              return FilterChipToggle(
                label: isSignal ? '${tf.label} ★' : tf.label,
                selected: tf == _chartTf,
                onTap: () => _selectTf(tf),
              );
            }).toList(),
          ),
          Text(
            t.chartSignalOn(d.timeframe.label),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              CandleChart(
                candles: _candles,
                level: _chartLevel,
                bias: d.bias,
                showMa: d.level == null,
              ),
              if (_loading)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTokens.bg.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppTokens.radius20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTokens.accent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.chartLoading,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_loadError != null) ...[
            const SizedBox(height: 8),
            Text(
              _loadError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTokens.bear,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          Text(summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          ...d.detailBullets.map(
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
