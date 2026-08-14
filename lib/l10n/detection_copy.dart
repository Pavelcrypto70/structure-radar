import '../domain/models.dart';
import 'app_lang.dart';

class DetectionCopy {
  static String title(Detection d, AppLang lang) {
    switch (d.kind) {
      case DetectorKind.structureShift:
        if (d.bias == StructureBias.bearish) {
          return srLocalized(
            lang,
            'Bull → Bear structure shift',
            es: 'Estructura: alcista → bajista',
            pt: 'Estrutura: altista → baixista',
            ru: 'Структура: бычий → медвежий',
          );
        }
        return srLocalized(
          lang,
          'Bear → Bull structure shift',
          es: 'Estructura: bajista → alcista',
          pt: 'Estrutura: baixista → altista',
          ru: 'Структура: медвежий → бычий',
        );
      case DetectorKind.maRegime:
        if (d.bias == StructureBias.bullish) {
          return srLocalized(
            lang,
            'MA regime → Bullish',
            es: 'Régimen MA → alcista',
            pt: 'Regime MA → altista',
            ru: 'Режим MA → бычий',
          );
        }
        return srLocalized(
          lang,
          'MA regime → Bearish',
          es: 'Régimen MA → bajista',
          pt: 'Regime MA → baixista',
          ru: 'Режим MA → медвежий',
        );
      case DetectorKind.levels:
        return _levelsTitle(d, lang);
    }
  }

  static String summary(Detection d, AppLang lang) {
    switch (d.kind) {
      case DetectorKind.structureShift:
        if (d.bias == StructureBias.bearish) {
          return srLocalized(
            lang,
            'After clean HH/HL, price closed below the higher-low with ATR pad (2 closes) — quality BOS, not a range poke.',
            es:
                'Tras HH/HL limpios, el precio cerró bajo el higher-low con colchón ATR (2 cierres) — BOS de calidad, no pinchazo en rango.',
            pt:
                'Após HH/HL limpos, o preço fechou abaixo do higher-low com colchão ATR (2 closes) — BOS de qualidade, não poke em range.',
            ru:
                'После чистого HH/HL цена закрылась ниже higher-low с запасом по ATR (2 закрытия) — качественный BOS, не укол во флэте.',
          );
        }
        return srLocalized(
          lang,
          'After clean LH/LL, price closed above the lower-high with ATR pad (2 closes) — quality BOS, not a range poke.',
          es:
              'Tras LH/LL limpios, el precio cerró sobre el lower-high con colchón ATR (2 cierres) — BOS de calidad, no pinchazo en rango.',
          pt:
              'Após LH/LL limpos, o preço fechou acima do lower-high com colchão ATR (2 closes) — BOS de qualidade, não poke em range.',
          ru:
              'После чистого LH/LL цена закрылась выше lower-high с запасом по ATR (2 закрытия) — качественный BOS, не укол во флэте.',
        );
      case DetectorKind.maRegime:
        if (d.bias == StructureBias.bullish) {
          return srLocalized(
            lang,
            'Slow EMA stack confirmed bullish (3 bars) after cooldown — not a scalp cross.',
            es: 'Stack EMA lento confirmó alcista (3 barras) tras cooldown — no es cruce de scalping.',
            pt: 'Stack EMA lento confirmou altista (3 barras) após cooldown — não é cruzamento de scalp.',
            ru: 'Медленный стек EMA подтвердил бычий режим (3 бара) после cooldown — не скальп-кросс.',
          );
        }
        return srLocalized(
          lang,
          'Slow EMA stack confirmed bearish (3 bars) after cooldown — not a scalp cross.',
          es: 'Stack EMA lento confirmó bajista (3 barras) tras cooldown — no es cruce de scalping.',
          pt: 'Stack EMA lento confirmou baixista (3 barras) após cooldown — não é cruzamento de scalp.',
          ru: 'Медленный стек EMA подтвердил медвежий режим (3 бара) после cooldown — не скальп-кросс.',
        );
      case DetectorKind.levels:
        return _levelsSummary(d, lang);
    }
  }

  static String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }

  static String _levelsTitle(Detection d, AppLang lang) {
    final z = d.level;
    if (z == null) {
      return srLocalized(lang, 'Level', es: 'Nivel', pt: 'Nível', ru: 'Уровень');
    }
    final px = _fmt(z.price);
    final n = z.touches;
    switch (z.pattern) {
      case LevelPattern.ascendingTriangle:
        return srLocalized(
          lang,
          'Ascending triangle · resistance $px ($n touches)',
          es: 'Triángulo ascendente · resistencia $px ($n toques)',
          pt: 'Triângulo ascendente · resistência $px ($n toques)',
          ru: 'Восходящий треугольник · сопротивление $px ($n касаний)',
        );
      case LevelPattern.descendingTriangle:
        return srLocalized(
          lang,
          'Descending triangle · support $px ($n touches)',
          es: 'Triángulo descendente · soporte $px ($n toques)',
          pt: 'Triângulo descendente · suporte $px ($n toques)',
          ru: 'Нисходящий треугольник · поддержка $px ($n касаний)',
        );
      case LevelPattern.horizontal:
        if (z.side == LevelSide.resistance) {
          return srLocalized(
            lang,
            'Approaching resistance: $px ($n touches)',
            es: 'Acercándose a resistencia: $px ($n toques)',
            pt: 'Aproximando resistência: $px ($n toques)',
            ru: 'Приближение к сопротивлению: $px ($n касаний)',
          );
        }
        return srLocalized(
          lang,
          'Approaching support: $px ($n touches)',
          es: 'Acercándose a soporte: $px ($n toques)',
          pt: 'Aproximando suporte: $px ($n toques)',
          ru: 'Приближение к поддержке: $px ($n касаний)',
        );
    }
  }

  static String _levelsSummary(Detection d, AppLang lang) {
    final z = d.level;
    if (z == null) {
      return srLocalized(
        lang,
        'Clean horizontal level with repeated touches.',
        es: 'Nivel horizontal limpio con toques repetidos.',
        pt: 'Nível horizontal limpo com toques repetidos.',
        ru: 'Чистый горизонтальный уровень с повторными касаниями.',
      );
    }
    final px = _fmt(z.price);
    final n = z.touches;
    switch (z.pattern) {
      case LevelPattern.ascendingTriangle:
        return srLocalized(
          lang,
          'Flat resistance at $px ($n touches) with rising lows — ascending-triangle squeeze.',
          es:
              'Resistencia plana en $px ($n toques) con mínimos ascendentes — compresión de triángulo ascendente.',
          pt:
              'Resistência plana em $px ($n toques) com fundos ascendentes — compressão de triângulo ascendente.',
          ru:
              'Плоское сопротивление $px ($n касаний) и растущие лои — сжатие восходящего треугольника.',
        );
      case LevelPattern.descendingTriangle:
        return srLocalized(
          lang,
          'Flat support at $px ($n touches) with lower highs — descending-triangle / post-impulse squeeze.',
          es:
              'Soporte plano en $px ($n toques) con máximos descendentes — triángulo descendente / compresión tras impulso.',
          pt:
              'Suporte plano em $px ($n toques) com topos descendentes — triângulo descendente / compressão pós-impulso.',
          ru:
              'Плоская поддержка $px ($n касаний) и понижающиеся хаи — нисходящий треугольник / сжатие после импульса.',
        );
      case LevelPattern.horizontal:
        if (z.side == LevelSide.resistance) {
          return srLocalized(
            lang,
            'Price is approaching a clean horizontal resistance at $px confirmed by $n separated swing touches.',
            es:
                'El precio se acerca a resistencia horizontal limpia en $px, confirmada por $n toques de swing separados.',
            pt:
                'O preço aproxima-se de resistência horizontal limpa em $px, confirmada por $n toques de swing separados.',
            ru:
                'Цена подходит к чистому горизонтальному сопротивлению $px, подтверждённому $n разнесёнными касаниями.',
          );
        }
        return srLocalized(
          lang,
          'Price is approaching a clean horizontal support at $px confirmed by $n separated swing touches.',
          es:
              'El precio se acerca a soporte horizontal limpio en $px, confirmado por $n toques de swing separados.',
          pt:
              'O preço aproxima-se de suporte horizontal limpo em $px, confirmado por $n toques de swing separados.',
          ru:
              'Цена подходит к чистой горизонтальной поддержке $px, подтверждённой $n разнесёнными касаниями.',
        );
    }
  }
}
