import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_radar/domain/models.dart';
import 'package:structure_radar/services/alert_profile_store.dart';
import 'package:structure_radar/services/curated_broadcast.dart';
import 'package:structure_radar/services/telegram_bridge.dart';

Detection _hit({
  double score = 91,
  AppTimeframe tf = AppTimeframe.h4,
  LevelPattern pattern = LevelPattern.horizontal,
}) {
  return Detection(
    id: 'c1',
    kind: DetectorKind.levels,
    exchange: ExchangeId.binance,
    symbol: const MarketSymbol(
      id: 'BTCUSDT',
      base: 'BTC',
      quote: 'USDT',
      display: 'BTC',
    ),
    timeframe: tf,
    title: 'Curated test',
    summary: 'Summary',
    score: score,
    detectedAt: DateTime.utc(2024, 6, 1, 12),
    bias: StructureBias.neutral,
    candles: const [],
    level: LevelZone(
      price: 100,
      side: LevelSide.resistance,
      touches: 3,
      strength: score,
      pattern: pattern,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CuratedBroadcast matches 90+ on 1H/4H/1D only', () {
    expect(CuratedBroadcast.matches(_hit(score: 89)), isFalse);
    expect(CuratedBroadcast.matches(_hit(score: 90)), isTrue);
    expect(CuratedBroadcast.matches(_hit(score: 92, tf: AppTimeframe.m15)), isFalse);
    expect(
      CuratedBroadcast.matches(
        _hit(score: 92, pattern: LevelPattern.ascendingTriangle),
      ),
      isFalse,
    );
  });

  test('queueCuratedBroadcast uses separate broadcast queue', () async {
    final store = AlertProfileStore();
    final bridge = TelegramBridge(store);
    final ev = await bridge.queueCuratedBroadcast(_hit());
    expect(ev, isNotNull);
    expect(ev!.profileLinkCode, CuratedBroadcast.linkCode);
    expect(
      ev.payload['schema'],
      'structure_radar.broadcast_alert.v1',
    );

    final q = await store.loadBroadcastQueue();
    expect(q.length, 1);

    final personal = await store.loadQueue();
    expect(personal, isEmpty);
  });

  test('broadcast dedupe within 12h', () async {
    final store = AlertProfileStore();
    final bridge = TelegramBridge(store);
    expect(await bridge.queueCuratedBroadcast(_hit()), isNotNull);
    expect(await bridge.queueCuratedBroadcast(_hit()), isNull);
  });
}
