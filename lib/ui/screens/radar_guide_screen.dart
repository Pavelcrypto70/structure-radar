import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../theme/tokens.dart';
import '../widgets/sr_chrome.dart';

class RadarGuideScreen extends StatelessWidget {
  const RadarGuideScreen({super.key, required this.t});
  final L10n t;

  @override
  Widget build(BuildContext context) {
    final slides = t.isRu
        ? const [
            ('01 · ПРОДУКТ', 'Structure Radar', 'Бесплатный образовательный сканер структуры рынка по USDT на Binance, Bybit и Gate.io.'),
            ('02 · ДЕТЕКТОРЫ', 'Три линзы', 'Смена структуры · режим MA · поддержка/сопротивление. Каждая — эвристика со score.'),
            ('03 · СКАН', 'Параллельный проход', 'Радар обходит пары пачками. Смотри прогресс: биржа · символ · TF.'),
            ('04 · КАРТОЧКА', 'График решает', 'Открой хит: свечи, EMA, зона уровня. Score — не ордер и не совет.'),
            ('05 · ПРОФИЛЬ', 'Telegram позже', 'Профиль алертов уже готов. Бот ещё не подключён — очередь локальная.'),
            ('06 · ДИСКЛЕЙМЕР', 'Честно', 'Не брокер. Без исполнения. Рынок может сразу отменить паттерн.'),
          ]
        : const [
            ('01 · PRODUCT', 'Structure Radar', 'Free educational market-structure scanner for USDT on Binance, Bybit and Gate.io.'),
            ('02 · DETECTORS', 'Three lenses', 'Structure shift · MA regime · support/resistance. Each is a scored heuristic.'),
            ('03 · SCAN', 'Parallel pass', 'Radar walks pairs in batches. Watch progress: venue · symbol · TF.'),
            ('04 · CARD', 'Chart decides', 'Open a hit: candles, EMAs, level zone. Score is not an order or advice.'),
            ('05 · PROFILE', 'Telegram later', 'Alert profile is ready. Bot is not live yet — queue stays on-device.'),
            ('06 · DISCLAIMER', 'Be honest', 'Not a broker. No execution. Markets can invalidate patterns immediately.'),
          ];

    return Scaffold(
      backgroundColor: SrColors.bg,
      appBar: AppBar(title: Text(t.guideTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        itemCount: slides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = slides[i];
          return SrSurface(
            gradient: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SrKicker(s.$1),
                const SizedBox(height: 10),
                Text(s.$2, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(s.$3, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          );
        },
      ),
    );
  }
}
