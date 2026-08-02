import '../domain/models.dart';
import 'app_lang.dart';

class DetectionCopy {
  static String title(Detection d, AppLang lang) {
    final ru = lang == AppLang.ru;
    switch (d.kind) {
      case DetectorKind.structureShift:
        if (d.bias == StructureBias.bearish) {
          return ru
              ? 'Структура: бычий → медвежий'
              : 'Bull → Bear structure shift';
        }
        return ru
            ? 'Структура: медвежий → бычий'
            : 'Bear → Bull structure shift';
      case DetectorKind.maRegime:
        if (d.bias == StructureBias.bullish) {
          return ru ? 'Режим MA → бычий' : 'MA regime → Bullish';
        }
        return ru ? 'Режим MA → медвежий' : 'MA regime → Bearish';
      case DetectorKind.levels:
        return _levelsTitle(d, ru);
    }
  }

  static String summary(Detection d, AppLang lang) {
    final ru = lang == AppLang.ru;
    switch (d.kind) {
      case DetectorKind.structureShift:
        if (d.bias == StructureBias.bearish) {
          return ru
              ? 'Цена пробила предыдущий higher-low. Геометрия свингов уходит из аптренда к lower highs / lower lows.'
              : 'Price broke below a prior higher-low. Swing structure is flipping from uptrend geometry toward lower highs / lower lows.';
        }
        return ru
            ? 'Цена пробила предыдущий lower-high. Геометрия свингов уходит из даунтренда к higher highs / higher lows.'
            : 'Price broke above a prior lower-high. Swing structure is flipping from downtrend geometry toward higher highs / higher lows.';
      case DetectorKind.maRegime:
        if (d.bias == StructureBias.bullish) {
          return ru
              ? 'Цена и стек EMA20/EMA50 перешли в бычий режим на последнем баре.'
              : 'Price and EMA20/EMA50 stack flipped into a bullish regime on the latest bar.';
        }
        return ru
            ? 'Цена и стек EMA20/EMA50 перешли в медвежий режим на последнем баре.'
            : 'Price and EMA20/EMA50 stack flipped into a bearish regime on the latest bar.';
      case DetectorKind.levels:
        return _levelsSummary(d, ru);
    }
  }

  static String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    return v.toStringAsFixed(6);
  }

  static String _levelsTitle(Detection d, bool ru) {
    final z = d.level;
    if (z == null) {
      return ru ? 'Уровень' : 'Level';
    }
    final px = _fmt(z.price);
    final n = z.touches;
    switch (z.pattern) {
      case LevelPattern.ascendingTriangle:
        return ru
            ? 'Восходящий треугольник · сопротивление $px ($n касаний)'
            : 'Ascending triangle · resistance $px ($n touches)';
      case LevelPattern.descendingTriangle:
        return ru
            ? 'Нисходящий треугольник · поддержка $px ($n касаний)'
            : 'Descending triangle · support $px ($n touches)';
      case LevelPattern.horizontal:
        if (z.side == LevelSide.resistance) {
          return ru
              ? 'Приближение к сопротивлению: $px ($n касаний)'
              : 'Approaching resistance: $px ($n touches)';
        }
        return ru
            ? 'Приближение к поддержке: $px ($n касаний)'
            : 'Approaching support: $px ($n touches)';
    }
  }

  static String _levelsSummary(Detection d, bool ru) {
    final z = d.level;
    if (z == null) {
      return ru
          ? 'Чистый горизонтальный уровень с повторными касаниями.'
          : 'Clean horizontal level with repeated touches.';
    }
    final px = _fmt(z.price);
    final n = z.touches;
    switch (z.pattern) {
      case LevelPattern.ascendingTriangle:
        return ru
            ? 'Плоское сопротивление $px ($n касаний) и растущие лои — сжатие восходящего треугольника.'
            : 'Flat resistance at $px ($n touches) with rising lows — ascending-triangle squeeze.';
      case LevelPattern.descendingTriangle:
        return ru
            ? 'Плоская поддержка $px ($n касаний) и понижающиеся хаи — нисходящий треугольник / сжатие после импульса.'
            : 'Flat support at $px ($n touches) with lower highs — descending-triangle / post-impulse squeeze.';
      case LevelPattern.horizontal:
        if (z.side == LevelSide.resistance) {
          return ru
              ? 'Цена подходит к чистому горизонтальному сопротивлению $px, подтверждённому $n разнесёнными касаниями.'
              : 'Price is approaching a clean horizontal resistance at $px confirmed by $n separated swing touches.';
        }
        return ru
            ? 'Цена подходит к чистой горизонтальной поддержке $px, подтверждённой $n разнесёнными касаниями.'
            : 'Price is approaching a clean horizontal support at $px confirmed by $n separated swing touches.';
    }
  }
}
