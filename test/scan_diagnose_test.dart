import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:structure_radar/data/exchanges/binance_client.dart';
import 'package:structure_radar/data/exchanges/bybit_client.dart';
import 'package:structure_radar/data/exchanges/gate_client.dart';
import 'package:structure_radar/data/universe_service.dart';
import 'package:structure_radar/detectors/detector.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/detectors/ma_regime_detector.dart';
import 'package:structure_radar/detectors/structure_detector.dart';
import 'package:structure_radar/domain/models.dart';

/// Live diagnose — run: flutter test test/scan_diagnose_test.dart
void main() {
  test(
    'live scan diagnose midcap sample',
    () async {
    final clients = {
      ExchangeId.binance: BinanceClient(),
      ExchangeId.bybit: BybitClient(),
      ExchangeId.gate: GateClient(),
    };
    final uni = UniverseService();
    final u = await uni.build(
      exchanges: {ExchangeId.binance},
      clients: clients,
      forceRefresh: true,
    );

    expect(u.symbols, isNotEmpty, reason: 'universe must not be empty');

    final sample = u.symbols.take(50).toList();
    final dets = <DetectorSpec>[
      DetectorSpec('struct5', StructureShiftDetector(lookback: 5, recentBars: 3)),
      DetectorSpec('struct3', StructureShiftDetector(lookback: 3, recentBars: 5)),
      DetectorSpec('ma', MaRegimeDetector()),
      DetectorSpec('levels', LevelsDetector()),
      DetectorSpec('levels_loose', LevelsDetector(
        minTouches: 2,
        minTouchGapBars: 3,
        minTouchSpanBars: 8,
        clusterTolAtr: 0.35,
        approachAtr: 1.4,
        tightApproachAtr: 0.85,
        breakToleranceAtr: 0.4,
      )),
    ];

    var fetchOk = 0;
    var fetchFail = 0;
    final hitsBy = <String, int>{};
    final rawHits = <Map<String, dynamic>>[];

    for (final entry in sample) {
      final client = clients[entry.primaryExchange]!;
      for (final tf in [AppTimeframe.h4, AppTimeframe.d1]) {
        try {
          final candles = await client.fetchCandles(
            symbol: entry.symbol,
            timeframe: tf,
            limit: 220,
          );
          fetchOk++;
          for (final d in dets) {
            final hits = d.det.detect(
              exchange: entry.primaryExchange,
              symbol: entry.symbol,
              timeframe: tf,
              candles: candles,
            );
            hitsBy[d.name] = (hitsBy[d.name] ?? 0) + hits.length;
            for (final h in hits) {
              rawHits.add({
                'sym': entry.symbol.display,
                'tf': tf.label,
                'kind': d.name,
                'score': double.parse(h.score.toStringAsFixed(1)),
                'title': h.title,
              });
            }
          }
        } catch (_) {
          fetchFail++;
        }
      }
    }

    rawHits.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    final report = {
      'universeSize': u.symbols.length,
      'excluded': u.excludedTopBases.toList(),
      'sample': sample.length,
      'fetchOk': fetchOk,
      'fetchFail': fetchFail,
      'hitsBy': hitsBy,
      'rawHits': rawHits.length,
      'pass50': rawHits.where((h) => (h['score'] as double) >= 50).length,
      'top': rawHits.take(20).toList(),
    };

    // ignore: avoid_print
    print(const JsonEncoder.withIndent('  ').convert(report));
    await File('tool/scan_diagnose_report.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
    );

    // Soft: we expect at least some fetch success.
    expect(fetchOk, greaterThan(0));
    },
    timeout: const Timeout(Duration(minutes: 4)),
    skip: 'Manual live network diagnose',
  );
}

class DetectorSpec {
  DetectorSpec(this.name, this.det);
  final String name;
  final Detector det;
}
