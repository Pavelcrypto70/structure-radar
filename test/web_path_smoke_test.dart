import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:structure_radar/data/universe_service.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/detectors/ma_regime_detector.dart';
import 'package:structure_radar/detectors/structure_detector.dart';
import 'package:structure_radar/domain/models.dart';

/// Simulates the web path: lightweight universe + candle fetch + detectors.
void main() {
  test('lightweight universe produces hits at score 50', () async {
    final uni = UniverseService();
    final u = await uni.build(
      exchanges: {ExchangeId.binance},
      clients: const {},
      forceRefresh: true,
      lightweight: true,
    );
    expect(u.symbols, isNotEmpty);
    // ignore: avoid_print
    print('universe=${u.symbols.length} source=${u.source}');

    final dets = [
      StructureShiftDetector(lookback: 4, recentBars: 5),
      MaRegimeDetector(),
      LevelsDetector(
        minTouches: 3,
        minTouchGapBars: 4,
        minTouchSpanBars: 10,
        clusterTolAtr: 0.28,
        approachAtr: 1.25,
        tightApproachAtr: 0.7,
        breakToleranceAtr: 0.35,
      ),
    ];

    var ok = 0;
    var fail = 0;
    var hits = 0;
    final sample = u.symbols.take(60).toList();
    final client = http.Client();

    for (final entry in sample) {
      for (final tf in ['4h', '1d']) {
        final direct = Uri.https('data-api.binance.vision', '/api/v3/klines', {
          'symbol': entry.symbol.id,
          'interval': tf,
          'limit': '220',
        });
        try {
          final res = await client.get(direct).timeout(const Duration(seconds: 20));
          if (res.statusCode != 200) {
            fail++;
            continue;
          }
          final raw = jsonDecode(res.body);
          if (raw is! List) {
            fail++;
            if (fail <= 3) print('bad body type ${raw.runtimeType} for ${entry.symbol.id}');
            continue;
          }
          final candles = raw.map((row) {
            final r = row as List<dynamic>;
            return Candle(
              openTime: DateTime.fromMillisecondsSinceEpoch((r[0] as num).toInt()),
              open: double.parse('${r[1]}'),
              high: double.parse('${r[2]}'),
              low: double.parse('${r[3]}'),
              close: double.parse('${r[4]}'),
              volume: double.parse('${r[5]}'),
            );
          }).toList();
          ok++;
          for (final d in dets) {
            hits += d
                .detect(
                  exchange: ExchangeId.binance,
                  symbol: entry.symbol,
                  timeframe: tf == '4h' ? AppTimeframe.h4 : AppTimeframe.d1,
                  candles: candles,
                )
                .where((h) => h.score >= 50)
                .length;
          }
        } catch (e) {
          fail++;
          if (fail <= 3) print('fail ${entry.symbol.id}: $e');
        }
      }
    }

    // ignore: avoid_print
    print(jsonEncode({'ok': ok, 'fail': fail, 'hits': hits, 'sample': sample.length}));
    await File('tool/web_path_report.json').writeAsString(
      jsonEncode({'ok': ok, 'fail': fail, 'hits': hits, 'universe': u.symbols.length}),
    );

    expect(ok, greaterThan(0), reason: 'proxy candle fetches must work');
    expect(hits, greaterThan(0), reason: 'should find setups at score 50');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
