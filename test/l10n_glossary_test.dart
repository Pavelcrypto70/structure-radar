import 'package:flutter_test/flutter_test.dart';
import 'package:structure_radar/l10n/app_lang.dart';
import 'package:structure_radar/l10n/detection_copy.dart';
import 'package:structure_radar/l10n/glossary_l10n.dart';
import 'package:structure_radar/domain/models.dart';

void main() {
  test('glossary has ES/PT titles distinct from EN', () {
    final en = GlossaryLocalized.entries(AppLang.en).first;
    final es = GlossaryLocalized.entries(AppLang.es).first;
    final pt = GlossaryLocalized.entries(AppLang.pt).first;
    expect(en['title'], 'Structure Shift');
    expect(es['title'], 'Cambio de estructura');
    expect(pt['title'], 'Mudança de estrutura');
  });

  test('detection copy ES/PT for MA regime bullish', () {
    final d = Detection(
      id: 'test-ma',
      kind: DetectorKind.maRegime,
      exchange: ExchangeId.binance,
      symbol: MarketSymbol(
        id: 'binance:BTCUSDT',
        base: 'BTC',
        quote: 'USDT',
        display: 'BTC/USDT',
      ),
      timeframe: AppTimeframe.h4,
      title: 'MA regime',
      summary: 'summary',
      score: 72,
      detectedAt: DateTime.utc(2026, 1, 1),
      bias: StructureBias.bullish,
      candles: [],
    );
    expect(DetectionCopy.title(d, AppLang.es), 'Régimen MA → alcista');
    expect(DetectionCopy.title(d, AppLang.pt), 'Regime MA → altista');
  });

  test('native fetch error strings localized', () {
    final t = L10n(AppLang.es);
    expect(t.allFetchesFailedNative, contains('velas'));
    expect(t.scanErrorGeneric.toLowerCase(), contains('escaneo'));
  });
}
