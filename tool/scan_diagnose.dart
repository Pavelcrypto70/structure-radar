// ignore_for_file: avoid_print
/// Diagnose empty scan. Run: dart run tool/scan_diagnose.dart
import 'dart:convert';
import 'dart:io';

import 'package:structure_radar/data/exchanges/binance_client.dart';
import 'package:structure_radar/data/exchanges/bybit_client.dart';
import 'package:structure_radar/data/exchanges/gate_client.dart';
import 'package:structure_radar/data/market_repository.dart';
import 'package:structure_radar/data/universe_service.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/detectors/ma_regime_detector.dart';
import 'package:structure_radar/detectors/structure_detector.dart';
import 'package:structure_radar/domain/models.dart';

Future<void> main() async {
  final clients = {
    ExchangeId.binance: BinanceClient(),
    ExchangeId.bybit: BybitClient(),
    ExchangeId.gate: GateClient(),
  };
  final uni = UniverseService();

  stderr.writeln('Building universe…');
  final u = await uni.build(
    exchanges: ExchangeId.values.toSet(),
    clients: clients,
    forceRefresh: true,
  );
  stderr.writeln(
    'Universe unique=${u.symbols.length} raw=${u.rawPairCount} excluded=${u.excludedTopBases.join(",")}',
  );
  if (u.symbols.isEmpty) {
    stderr.writeln('EMPTY UNIVERSE — listing APIs failed');
    for (final e in ExchangeId.values) {
      try {
        final list = await clients[e]!.listUsdtSpotPairs();
        stderr.writeln('${e.label}: ${list.length} pairs');
      } catch (err) {
        stderr.writeln('${e.label} FAIL: $err');
      }
    }
    exit(1);
  }

  // Sample top midcaps by volume + a few lower ones.
  final sample = [
    ...u.symbols.take(40),
    if (u.symbols.length > 80) ...u.symbols.skip(80).take(10),
  ];

  final dets = [
    StructureShiftDetector(lookback: 5, recentBars: 3),
    StructureShiftDetector(lookback: 3, recentBars: 5), // old
    MaRegimeDetector(),
    LevelsDetector(),
  ];

  var fetchOk = 0;
  var fetchFail = 0;
  final hitsBy = <String, int>{};
  final rawHits = <Map<String, dynamic>>[];

  for (final entry in sample) {
    final client = clients[entry.primaryExchange]!;
    for (final tf in [AppTimeframe.h4, AppTimeframe.h1]) {
      try {
        final candles = await client.fetchCandles(
          symbol: entry.symbol,
          timeframe: tf,
          limit: 220,
        );
        fetchOk++;
        for (final d in dets) {
          final key = d is StructureShiftDetector
              ? 'struct_lb${d.lookback}'
              : d.kind.name;
          final hits = d.detect(
            exchange: entry.primaryExchange,
            symbol: entry.symbol,
            timeframe: tf,
            candles: candles,
          );
          hitsBy[key] = (hitsBy[key] ?? 0) + hits.length;
          for (final h in hits) {
            rawHits.add({
              'sym': entry.symbol.display,
              'ex': entry.primaryExchange.short,
              'tf': tf.label,
              'kind': key,
              'score': h.score,
              'title': h.title,
            });
          }
        }
      } catch (e) {
        fetchFail++;
        if (fetchFail <= 5) {
          stderr.writeln('fetch fail ${entry.symbol.display}: $e');
        }
      }
    }
  }

  rawHits.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
  final pass50 = rawHits.where((h) => (h['score'] as double) >= 50).length;

  // Mini repo scan on first 25 symbols × 1 TF
  final repo = MarketRepository(concurrency: 10);
  final mini = await repo.scan(
    ScanRequest(
      exchanges: {ExchangeId.binance},
      timeframes: {AppTimeframe.h4},
      detectors: DetectorKind.values.toSet(),
      minScore: 50,
    ),
  );

  final report = {
    'universeSize': u.symbols.length,
    'rawListings': u.rawPairCount,
    'excluded': u.excludedTopBases.toList(),
    'sampleSize': sample.length,
    'fetchOk': fetchOk,
    'fetchFail': fetchFail,
    'hitsByDetector': hitsBy,
    'rawHitCount': rawHits.length,
    'passScore50': pass50,
    'topHits': rawHits.take(15).toList(),
    'repoScanHits': mini.length,
    'repoUniverse': repo.lastUniverseSize,
  };
  print(const JsonEncoder.withIndent('  ').convert(report));
  await File('tool/scan_diagnose_report.json').writeAsString(
    const JsonEncoder.withIndent('  ').convert(report),
  );
}
