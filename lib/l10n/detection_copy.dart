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
        if (d.level?.side == LevelSide.support ||
            d.bias == StructureBias.bullish) {
          return ru ? 'Взаимодействие с поддержкой' : 'Support interaction';
        }
        return ru ? 'Взаимодействие с сопротивлением' : 'Resistance interaction';
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
        if (d.level?.side == LevelSide.support ||
            d.bias == StructureBias.bullish) {
          return ru
              ? 'Цена взаимодействует с зоной поддержки, собранной из повторяющихся свинговых пивотов.'
              : 'Price is interacting with a clustered support zone built from repeated swing pivots.';
        }
        return ru
            ? 'Цена взаимодействует с зоной сопротивления, собранной из повторяющихся свинговых пивотов.'
            : 'Price is interacting with a clustered resistance zone built from repeated swing pivots.';
    }
  }
}
