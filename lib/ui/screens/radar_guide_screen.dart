import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../theme/tokens.dart';
import '../widgets/sr_chrome.dart';

class RadarGuideScreen extends StatelessWidget {
  const RadarGuideScreen({super.key, required this.t});
  final L10n t;

  @override
  Widget build(BuildContext context) {
    final slides = switch (t.lang) {
      AppLang.ru => const [
        (
          '01 · ПРОДУКТ',
          'Structure Radar',
          'Бесплатный образовательный сканер структуры рынка по USDT на Binance, Bybit и Gate.io.',
        ),
        (
          '02 · ДЕТЕКТОРЫ',
          'Три линзы',
          'Смена структуры · режим MA · поддержка/сопротивление. Каждая — эвристика со score.',
        ),
        (
          '03 · СКАН',
          'Параллельный проход',
          'Радар обходит пары пачками. Смотри прогресс: биржа · символ · TF.',
        ),
        (
          '04 · КАРТОЧКА',
          'График решает',
          'Открой хит: свечи, EMA, зона уровня. Score — не ордер и не совет.',
        ),
        (
          '05 · ПРОФИЛЬ',
          'Telegram позже',
          'Профиль алертов уже готов. Бот ещё не подключён — очередь локальная.',
        ),
        (
          '06 · ДИСКЛЕЙМЕР',
          'Честно',
          'Не брокер. Без исполнения. Рынок может сразу отменить паттерн.',
        ),
      ],
      AppLang.es => const [
        (
          '01 · PRODUCTO',
          'Structure Radar',
          'Escáner educativo gratuito de estructura de mercado USDT en Binance, Bybit y Gate.io.',
        ),
        (
          '02 · DETECTORES',
          'Tres lentes',
          'Cambio de estructura · régimen MA · soporte/resistencia. Cada uno es una heurística con score.',
        ),
        (
          '03 · ESCANEO',
          'Recorrido paralelo',
          'Radar recorre pares por lotes. Sigue el progreso: exchange · símbolo · TF.',
        ),
        (
          '04 · TARJETA',
          'El gráfico decide',
          'Abre un hallazgo: velas, EMA y zona de nivel. Score no es una orden ni un consejo.',
        ),
        (
          '05 · PERFIL',
          'Telegram después',
          'El perfil de alertas está listo. El bot no está activo: la cola queda en el dispositivo.',
        ),
        (
          '06 · AVISO',
          'Con honestidad',
          'No es un bróker. Sin ejecución. El mercado puede invalidar patrones de inmediato.',
        ),
      ],
      AppLang.pt => const [
        (
          '01 · PRODUTO',
          'Structure Radar',
          'Scanner educacional gratuito de estrutura de mercado USDT na Binance, Bybit e Gate.io.',
        ),
        (
          '02 · DETECTORES',
          'Três lentes',
          'Mudança de estrutura · regime MA · suporte/resistência. Cada um é uma heurística com score.',
        ),
        (
          '03 · VARREDURA',
          'Passagem paralela',
          'O Radar percorre pares em lotes. Veja o progresso: corretora · símbolo · TF.',
        ),
        (
          '04 · CARTÃO',
          'O gráfico decide',
          'Abra uma detecção: candles, EMAs e zona de nível. Score não é ordem nem recomendação.',
        ),
        (
          '05 · PERFIL',
          'Telegram depois',
          'O perfil de alertas está pronto. O bot ainda não está ativo: a fila fica no dispositivo.',
        ),
        (
          '06 · AVISO',
          'Com honestidade',
          'Não é corretora. Sem execução. O mercado pode invalidar padrões imediatamente.',
        ),
      ],
      AppLang.en => const [
        (
          '01 · PRODUCT',
          'Structure Radar',
          'Free educational market-structure scanner for USDT on Binance, Bybit and Gate.io.',
        ),
        (
          '02 · DETECTORS',
          'Three lenses',
          'Structure shift · MA regime · support/resistance. Each is a scored heuristic.',
        ),
        (
          '03 · SCAN',
          'Parallel pass',
          'Radar walks pairs in batches. Watch progress: venue · symbol · TF.',
        ),
        (
          '04 · CARD',
          'Chart decides',
          'Open a hit: candles, EMAs, level zone. Score is not an order or advice.',
        ),
        (
          '05 · PROFILE',
          'Telegram later',
          'Alert profile is ready. Bot is not live yet — queue stays on-device.',
        ),
        (
          '06 · DISCLAIMER',
          'Be honest',
          'Not a broker. No execution. Markets can invalidate patterns immediately.',
        ),
      ],
    };

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
