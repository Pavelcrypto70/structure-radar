// ignore_for_file: avoid_print
/// Rolling live density sweep for Structure Radar detectors.
/// Run: dart run tool/detector_live_sweep.dart
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:structure_radar/detectors/detector.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/detectors/ma_regime_detector.dart';
import 'package:structure_radar/detectors/structure_detector.dart';
import 'package:structure_radar/domain/models.dart';

const symbols = [
  ('BTCUSDT', 'BTC'),
  ('ETHUSDT', 'ETH'),
  ('SOLUSDT', 'SOL'),
];

Future<List<Candle>> fetchKlines(String symbol, String interval) async {
  final uri = Uri.parse(
    'https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=240',
  );
  final res = await HttpClient().getUrl(uri).then((r) => r.close());
  final body = await res.transform(utf8.decoder).join();
  final list = jsonDecode(body) as List<dynamic>;
  return list.map((row) {
    final r = row as List<dynamic>;
    return Candle(
      openTime: DateTime.fromMillisecondsSinceEpoch((r[0] as num).toInt(), isUtc: true),
      open: double.parse(r[1] as String),
      high: double.parse(r[2] as String),
      low: double.parse(r[3] as String),
      close: double.parse(r[4] as String),
      volume: double.parse(r[5] as String),
    );
  }).toList();
}

class Density {
  Density(this.label);
  final String label;
  int fires = 0;
  int pass65 = 0;
  int pass70 = 0;
  int pass75 = 0;
  final scores = <double>[];
  int windows = 0;

  double get fireRate => windows == 0 ? 0 : fires / windows;
  double get rate65 => windows == 0 ? 0 : pass65 / windows;
  double get rate70 => windows == 0 ? 0 : pass70 / windows;
  double get avgScore =>
      scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;

  /// Scanner objective: useful but not spammy.
  /// Target ~2–8% of bars @65 for structure on H4; lower on H1 harder.
  double objective({required double targetRate65}) {
    if (windows == 0) return 0;
    final r = rate65;
    // Gaussian-ish score around target.
    final dist = (r - targetRate65).abs();
    final densityScore = max(0.0, 1.0 - dist / max(targetRate65, 0.02));
    // Prefer higher avg score among fires (cleaner).
    final quality = scores.isEmpty ? 0.0 : (avgScore / 100).clamp(0.0, 1.0);
    return densityScore * 0.7 + quality * 0.3;
  }
}

void rollStructure({
  required List<Candle> candles,
  required int lookback,
  required int recent,
  required AppTimeframe tf,
  required MarketSymbol symbol,
  required Density d,
  required int minBars,
}) {
  final det = StructureShiftDetector(lookback: lookback, recentBars: recent);
  for (var i = minBars; i < candles.length; i++) {
    d.windows++;
    final slice = candles.sublist(0, i + 1);
    final hits = det.detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: tf,
      candles: slice,
    );
    // Count only hits "about this bar" (detectedAt == last open).
    final fresh = hits.where((h) => h.detectedAt == slice.last.openTime).toList();
    if (fresh.isEmpty) continue;
    d.fires++;
    final best = fresh.map((h) => h.score).reduce(max);
    d.scores.add(best);
    if (best >= 65) d.pass65++;
    if (best >= 70) d.pass70++;
    if (best >= 75) d.pass75++;
  }
}

void rollMa({
  required List<Candle> candles,
  required AppTimeframe tf,
  required MarketSymbol symbol,
  required Density d,
}) {
  final det = MaRegimeDetector();
  for (var i = 210; i < candles.length; i++) {
    d.windows++;
    final slice = candles.sublist(0, i + 1);
    final hits = det.detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: tf,
      candles: slice,
    );
    final fresh = hits.where((h) => h.detectedAt == slice.last.openTime).toList();
    if (fresh.isEmpty) continue;
    d.fires++;
    final best = fresh.first.score;
    d.scores.add(best);
    if (best >= 65) d.pass65++;
    if (best >= 70) d.pass70++;
    if (best >= 75) d.pass75++;
  }
}

void rollLevels({
  required List<Candle> candles,
  required AppTimeframe tf,
  required MarketSymbol symbol,
  required Density d,
  int minTouches = 2,
  double interact = 0.55,
  double tol = 0.35,
  int pivotLb = 3,
}) {
  for (var i = 80; i < candles.length; i++) {
    d.windows++;
    final slice = candles.sublist(0, i + 1);
    final hits = _levelsVariant(
      candles: slice,
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: tf,
      minTouches: minTouches,
      interact: interact,
      tol: tol,
      pivotLb: pivotLb,
    );
    final fresh = hits.where((h) => h.detectedAt == slice.last.openTime).toList();
    if (fresh.isEmpty) continue;
    d.fires++;
    final best = fresh.map((h) => h.score).reduce(max);
    d.scores.add(best);
    if (best >= 65) d.pass65++;
    if (best >= 70) d.pass70++;
    if (best >= 75) d.pass75++;
  }
}

/// Parametrized levels (mirrors LevelsDetector with knobs).
List<Detection> _levelsVariant({
  required List<Candle> candles,
  required ExchangeId exchange,
  required MarketSymbol symbol,
  required AppTimeframe timeframe,
  required int minTouches,
  required double interact,
  required double tol,
  required int pivotLb,
}) {
  if (candles.length < 80) return const [];
  final atrVal = atr(candles);
  if (atrVal <= 0) return const [];
  final clusterTol = atrVal * tol;
  final highs = pivotHighIndexes(candles, left: pivotLb, right: pivotLb);
  final lows = pivotLowIndexes(candles, left: pivotLb, right: pivotLb);
  final pivots = <double>[
    ...highs.map((i) => candles[i].high),
    ...lows.map((i) => candles[i].low),
  ]..sort();
  if (pivots.isEmpty) return const [];

  final clusters = <List<double>>[];
  for (final p in pivots) {
    if (clusters.isEmpty) {
      clusters.add([p]);
      continue;
    }
    final last = clusters.last;
    final mean = last.reduce((a, b) => a + b) / last.length;
    if ((p - mean).abs() <= clusterTol) {
      last.add(p);
    } else {
      clusters.add([p]);
    }
  }
  clusters.sort((a, b) => b.length.compareTo(a.length));
  final close = candles.last.close;
  final out = <Detection>[];
  for (final c in clusters.take(6)) {
    if (c.length < minTouches) continue;
    final mean = c.reduce((a, b) => a + b) / c.length;
    final proximity = (close - mean).abs() / atrVal;
    if (proximity > interact) continue;
    final side = close >= mean ? LevelSide.support : LevelSide.resistance;
    final strength = (c.length * 12 + (1.2 - proximity) * 30).clamp(40, 96).toDouble();
    out.add(
      Detection(
        id: 'x',
        kind: DetectorKind.levels,
        exchange: exchange,
        symbol: symbol,
        timeframe: timeframe,
        title: 'lvl',
        summary: 'lvl',
        score: strength,
        detectedAt: candles.last.openTime,
        bias: StructureBias.neutral,
        candles: candles,
      ),
    );
  }
  out.sort((a, b) => b.score.compareTo(a.score));
  return out.take(2).toList();
}

Map<String, dynamic> densJson(Density d, {required double target}) => {
      'label': d.label,
      'windows': d.windows,
      'fires': d.fires,
      'fireRatePct': double.parse((d.fireRate * 100).toStringAsFixed(2)),
      'pass65Pct': double.parse((d.rate65 * 100).toStringAsFixed(2)),
      'pass70Pct': double.parse((d.rate70 * 100).toStringAsFixed(2)),
      'pass75Pct': double.parse(
        ((d.windows == 0 ? 0.0 : d.pass75 / d.windows) * 100).toStringAsFixed(2),
      ),
      'avgScore': double.parse(d.avgScore.toStringAsFixed(1)),
      'objective': double.parse(d.objective(targetRate65: target).toStringAsFixed(3)),
    };

Future<void> main() async {
  final tfs = {
    '1h': (AppTimeframe.h1, '1h', 0.04), // structure target ~4% bars @65
    '4h': (AppTimeframe.h4, '4h', 0.05),
    '1d': (AppTimeframe.d1, '1d', 0.06),
  };

  final structureAgg = <String, Density>{};
  final maAgg = <String, Density>{};
  final levelsAgg = <String, Density>{};

  for (final (symId, base) in symbols) {
    final symbol = MarketSymbol(id: symId, base: base, quote: 'USDT', display: base);
    for (final tfEntry in tfs.entries) {
      final tf = tfEntry.value.$1;
      final interval = tfEntry.value.$2;
      final candles = await fetchKlines(symId, interval);
      stderr.writeln('Fetched $symId $interval n=${candles.length}');

      for (final lb in [2, 3, 4, 5]) {
        for (final recent in [3, 5, 8]) {
          final key = 'lb=$lb recent=$recent · ${tfEntry.key}';
          final d = structureAgg.putIfAbsent(key, () => Density(key));
          rollStructure(
            candles: candles,
            lookback: lb,
            recent: recent,
            tf: tf,
            symbol: symbol,
            d: d,
            minBars: 60,
          );
        }
      }

      final maKey = 'ma · ${tfEntry.key}';
      final md = maAgg.putIfAbsent(maKey, () => Density(maKey));
      rollMa(candles: candles, tf: tf, symbol: symbol, d: md);

      // Levels variants
      final levelVariants = [
        ('cur touches2 tol0.35 int0.55 piv3', 2, 0.35, 0.55, 3),
        ('opt touches3 tol0.40 int0.45 piv4', 3, 0.40, 0.45, 4),
        ('strict touches3 tol0.35 int0.40 piv5', 3, 0.35, 0.40, 5),
        ('loose touches2 tol0.45 int0.65 piv3', 2, 0.45, 0.65, 3),
      ];
      for (final v in levelVariants) {
        final key = '${v.$1} · ${tfEntry.key}';
        final d = levelsAgg.putIfAbsent(key, () => Density(key));
        rollLevels(
          candles: candles,
          tf: tf,
          symbol: symbol,
          d: d,
          minTouches: v.$2,
          tol: v.$3,
          interact: v.$4,
          pivotLb: v.$5,
        );
      }
    }
  }

  // Rank structure per TF
  final structureByTf = <String, List<Map<String, dynamic>>>{};
  for (final tfKey in tfs.keys) {
    final target = tfs[tfKey]!.$3;
    final rows = structureAgg.entries
        .where((e) => e.key.endsWith(tfKey))
        .map((e) => densJson(e.value, target: target))
        .toList()
      ..sort((a, b) => (b['objective'] as double).compareTo(a['objective'] as double));
    structureByTf[tfKey] = rows;
  }

  final maRows = maAgg.entries.map((e) {
    final tfKey = e.key.split(' · ').last;
    return densJson(e.value, target: 0.03);
  }).toList()
    ..sort((a, b) => (a['pass65Pct'] as double).compareTo(b['pass65Pct'] as double));

  final levelsByTf = <String, List<Map<String, dynamic>>>{};
  for (final tfKey in tfs.keys) {
    final rows = levelsAgg.entries
        .where((e) => e.key.endsWith(tfKey))
        .map((e) => densJson(e.value, target: 0.08))
        .toList()
      ..sort((a, b) => (b['objective'] as double).compareTo(a['objective'] as double));
    levelsByTf[tfKey] = rows;
  }

  // Also run current LevelsDetector for sanity
  final currentLevelsSanity = <String, dynamic>{};
  for (final tfEntry in tfs.entries) {
    final candles = await fetchKlines('BTCUSDT', tfEntry.value.$2);
    final symbol = const MarketSymbol(id: 'BTCUSDT', base: 'BTC', quote: 'USDT', display: 'BTC');
    final d = Density('stock LevelsDetector · ${tfEntry.key}');
    for (var i = 80; i < candles.length; i++) {
      d.windows++;
      final slice = candles.sublist(0, i + 1);
      final hits = LevelsDetector().detect(
        exchange: ExchangeId.binance,
        symbol: symbol,
        timeframe: tfEntry.value.$1,
        candles: slice,
      );
      final fresh = hits.where((h) => h.detectedAt == slice.last.openTime).toList();
      if (fresh.isEmpty) continue;
      d.fires++;
      final best = fresh.map((h) => h.score).reduce(max);
      d.scores.add(best);
      if (best >= 65) d.pass65++;
      if (best >= 70) d.pass70++;
      if (best >= 75) d.pass75++;
    }
    currentLevelsSanity[tfEntry.key] = densJson(d, target: 0.08);
  }

  final report = {
    'universe': 'Binance BTC/ETH/SOL · last 240 bars · rolling prefix detect',
    'objective_note':
        'Structure target rate@65 ≈ 4–6% of bars. Levels ≈ 8%. Prefer cleaner avgScore.',
    'structure_ranked': structureByTf,
    'structure_picks': {
      for (final tf in tfs.keys) tf: structureByTf[tf]!.first,
    },
    'structure_current_lb3_r5': {
      for (final tf in tfs.keys)
        tf: structureByTf[tf]!.firstWhere(
          (r) => (r['label'] as String).startsWith('lb=3 recent=5'),
          orElse: () => structureByTf[tf]!.first,
        ),
    },
    'ma_density': maRows,
    'levels_ranked': levelsByTf,
    'levels_picks': {
      for (final tf in tfs.keys) tf: levelsByTf[tf]!.first,
    },
    'levels_stock_btc_only': currentLevelsSanity,
    'recommended': {
      'structure': {
        'h1': _pickLbRecent(structureByTf['1h']!.first['label'] as String),
        'h4': _pickLbRecent(structureByTf['4h']!.first['label'] as String),
        'd1': _pickLbRecent(structureByTf['1d']!.first['label'] as String),
        'fallback_if_single_global': 'lookback=4, recentBars=5',
      },
      'ma': {
        'periods': [20, 50, 200],
        'keep': true,
        'changes': {
          'confirmBars': 2,
          'slopeLookback': 5,
          'oppositeLookback': 8,
          'sepBonusMax': 6,
        },
        'observed_pass65_pct': {
          for (final r in maRows) (r['label'] as String): r['pass65Pct'],
        },
      },
      'levels': {
        'minTouches': 3,
        'clusterTolAtr': 0.40,
        'interactProximityAtr': 0.45,
        'pivotLookback': 4,
        'maxEmit': 2,
      },
      'minScore': {
        'ui_default': 70,
        'relaxed': 60,
        'telegram': 75,
      },
    },
  };

  final out = const JsonEncoder.withIndent('  ').convert(report);
  print(out);
  await File('tool/live_sweep_report.json').writeAsString(out);
  stderr.writeln('Wrote tool/live_sweep_report.json');
}

Map<String, int> _pickLbRecent(String label) {
  // lb=4 recent=5 · 4h
  final m = RegExp(r'lb=(\d+) recent=(\d+)').firstMatch(label);
  return {
    'lookback': int.parse(m!.group(1)!),
    'recentBars': int.parse(m.group(2)!),
  };
}
