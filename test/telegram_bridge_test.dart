import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_radar/domain/models.dart';
import 'package:structure_radar/services/alert_profile_store.dart';
import 'package:structure_radar/services/telegram_bridge.dart';

Detection _hit({
  String id = 'd1',
  double score = 80,
  String symbol = 'AAAUSDT',
  AppTimeframe tf = AppTimeframe.h4,
}) {
  final now = DateTime.utc(2024, 6, 1, 12);
  return Detection(
    id: id,
    kind: DetectorKind.structureShift,
    exchange: ExchangeId.binance,
    symbol: MarketSymbol(
      id: symbol,
      base: 'AAA',
      quote: 'USDT',
      display: 'AAA',
    ),
    timeframe: tf,
    title: 'Test',
    summary: 'Test summary',
    score: score,
    detectedAt: now,
    bias: StructureBias.bullish,
    candles: const [],
    price: 100,
    tags: const ['TEST'],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults prefer higher TFs and alert minScore 75', () {
    final p = AlertProfile.defaults('SRTEST');
    expect(p.minScore, 75);
    expect(p.timeframes.contains(AppTimeframe.m15), isFalse);
    expect(p.quietHoursStart, 23);
    expect(p.quietHoursEnd, 8);
  });

  test('dedupe blocks same setup within cooldown', () async {
    final store = AlertProfileStore();
    final bridge = TelegramBridge(store);
    final profile = AlertProfile.defaults('SRTEST').copyWith(
      telegramOptIn: true,
      quietHoursStart: null,
      quietHoursEnd: null,
      clearQuietHours: true,
    );

    final a = await bridge.queueIfArmed(_hit(id: '1'), profile);
    final b = await bridge.queueIfArmed(_hit(id: '2'), profile);
    expect(a, isNotNull);
    expect(b, isNull); // same dedupe key within 6h

    final q = await store.loadQueue();
    expect(q.length, 1);
  });

  test('daily cap stops after maxAlertsPerDay', () async {
    final store = AlertProfileStore();
    final bridge = TelegramBridge(store);
    final profile = AlertProfile.defaults('SRTEST').copyWith(
      telegramOptIn: true,
      clearQuietHours: true,
    );

    var queued = 0;
    for (var i = 0; i < TelegramBridge.maxAlertsPerDay + 3; i++) {
      final ev = await bridge.queueIfArmed(
        _hit(id: 'id$i', symbol: 'S${i}USDT'),
        profile,
      );
      if (ev != null) queued++;
    }
    expect(queued, TelegramBridge.maxAlertsPerDay);
  });

  test('score below profile minScore is not queued', () async {
    final store = AlertProfileStore();
    final bridge = TelegramBridge(store);
    final profile = AlertProfile.defaults('SRTEST').copyWith(
      telegramOptIn: true,
      clearQuietHours: true,
      minScore: 75,
    );
    final ev = await bridge.queueIfArmed(_hit(score: 70), profile);
    expect(ev, isNull);
  });
}
