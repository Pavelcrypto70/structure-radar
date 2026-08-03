// ignore_for_file: avoid_print
/// Offline parameter sweep for Structure Radar detectors.
/// Run: dart run tool/detector_param_sweep.dart
///
/// Optimality target for this product:
/// - Precision over recall (structure scanner, not spam feed)
/// - H1/H4/D1 crypto USDT liquid pairs
/// - Score filter default ~65 should leave a manageable hit rate
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:structure_radar/detectors/detector.dart';
import 'package:structure_radar/detectors/levels_detector.dart';
import 'package:structure_radar/detectors/ma_regime_detector.dart';
import 'package:structure_radar/detectors/structure_detector.dart';
import 'package:structure_radar/domain/models.dart';

const symbol = MarketSymbol(
  id: 'BTCUSDT',
  base: 'BTC',
  quote: 'USDT',
  display: 'BTC',
);

List<Candle> seriesFromCloses(List<double> closes, {int hours = 1}) {
  final out = <Candle>[];
  final start = DateTime.utc(2024, 1, 1);
  for (var i = 0; i < closes.length; i++) {
    final c = closes[i];
    final prev = i == 0 ? c : closes[i - 1];
    final noise = 0.002 + (i % 7) * 0.00015;
    out.add(
      Candle(
        openTime: start.add(Duration(hours: hours * i)),
        open: prev,
        high: max(c, prev) * (1 + noise),
        low: min(c, prev) * (1 - noise),
        close: c,
        volume: 1000 + i.toDouble(),
      ),
    );
  }
  return out;
}

/// Clean HH+HL then BOS down — should fire bearish structure.
List<double> synthStructureBearBreak() {
  final closes = <double>[];
  var px = 100.0;
  // Build higher highs / higher lows via stepped rallies.
  for (var swing = 0; swing < 6; swing++) {
    for (var i = 0; i < 8; i++) {
      px += 1.2;
      closes.add(px);
    }
    for (var i = 0; i < 5; i++) {
      px -= 0.55;
      closes.add(px);
    }
  }
  // Break below last higher-low.
  for (var i = 0; i < 10; i++) {
    px -= 2.2;
    closes.add(px);
  }
  return closes;
}

/// Clean LH+LL then BOS up.
List<double> synthStructureBullBreak() {
  final closes = <double>[];
  var px = 200.0;
  for (var swing = 0; swing < 6; swing++) {
    for (var i = 0; i < 8; i++) {
      px -= 1.2;
      closes.add(px);
    }
    for (var i = 0; i < 5; i++) {
      px += 0.55;
      closes.add(px);
    }
  }
  for (var i = 0; i < 10; i++) {
    px += 2.2;
    closes.add(px);
  }
  return closes;
}

/// Sideways chop — structure should preferably stay quiet.
List<double> synthChop({int n = 160}) {
  final closes = <double>[];
  for (var i = 0; i < n; i++) {
    closes.add(100 + sin(i / 3.2) * 1.8 + cos(i / 7.1) * 0.9);
  }
  return closes;
}

/// Strong bull then collapse through EMA stack.
List<double> synthMaBearFlip() {
  final closes = <double>[];
  for (var i = 0; i < 250; i++) {
    closes.add(100 + i * 1.0);
  }
  for (var i = 0; i < 45; i++) {
    closes.add(closes.last - 9);
  }
  return closes;
}

List<double> synthMaBullFlip() {
  final closes = <double>[];
  for (var i = 0; i < 250; i++) {
    closes.add(400 - i * 1.0);
  }
  for (var i = 0; i < 45; i++) {
    closes.add(closes.last + 9);
  }
  return closes;
}

/// Oscillation building two zones; finish near lower.
List<double> synthLevelsNearSupport() {
  final closes = <double>[];
  for (var i = 0; i < 140; i++) {
    final wave = (i % 20 < 10) ? 100.0 + (i % 10) * 0.9 : 112.0 - (i % 10) * 0.9;
    closes.add(wave);
  }
  closes.addAll(List<double>.filled(6, 100.3));
  return closes;
}

/// Far from any zone — levels should stay quiet.
List<double> synthLevelsMidRange() {
  final closes = <double>[];
  for (var i = 0; i < 140; i++) {
    final wave = (i % 20 < 10) ? 100.0 + (i % 10) * 0.9 : 112.0 - (i % 10) * 0.9;
    closes.add(wave);
  }
  closes.addAll(List<double>.filled(6, 106.0));
  return closes;
}

class Case {
  Case(this.name, this.closes, this.expectHit, this.kind);
  final String name;
  final List<double> closes;
  final bool expectHit;
  final DetectorKind kind;
}

class SweepRow {
  SweepRow(this.label, this.tp, this.fp, this.fn, this.tn, this.avgScoreHit);
  final String label;
  final int tp, fp, fn, tn;
  final double avgScoreHit;

  double get precision => (tp + fp) == 0 ? 0 : tp / (tp + fp);
  double get recall => (tp + fn) == 0 ? 0 : tp / (tp + fn);
  double get f1 {
    if (precision + recall == 0) return 0;
    return 2 * precision * recall / (precision + recall);
  }

  double get specificity => (tn + fp) == 0 ? 0 : tn / (tn + fp);

  /// Product objective: prefer precision, then F1, punish FP hard.
  double get objective => precision * 0.55 + f1 * 0.35 + specificity * 0.10;
}

void main() async {
  final structureCases = [
    Case('bear_bos', synthStructureBearBreak(), true, DetectorKind.structureShift),
    Case('bull_bos', synthStructureBullBreak(), true, DetectorKind.structureShift),
    Case('chop_a', synthChop(), false, DetectorKind.structureShift),
    Case('chop_b', synthChop(n: 180), false, DetectorKind.structureShift),
    Case('flat', List.filled(120, 100.0), false, DetectorKind.structureShift),
  ];

  final maCases = [
    Case('ma_bear', synthMaBearFlip(), true, DetectorKind.maRegime),
    Case('ma_bull', synthMaBullFlip(), true, DetectorKind.maRegime),
    Case('ma_chop', synthChop(n: 260), false, DetectorKind.maRegime),
    Case('ma_flat', List.filled(260, 100.0), false, DetectorKind.maRegime),
    Case('ma_slow_up', List.generate(260, (i) => 100 + i * 0.15), false, DetectorKind.maRegime),
  ];

  final levelCases = [
    Case('near_support', synthLevelsNearSupport(), true, DetectorKind.levels),
    Case('mid_range', synthLevelsMidRange(), false, DetectorKind.levels),
    Case('lvl_chop', synthChop(n: 160), false, DetectorKind.levels),
    Case('lvl_flat', List.filled(120, 100.0), false, DetectorKind.levels),
  ];

  final structureRows = <SweepRow>[];
  for (final lookback in [2, 3, 4, 5]) {
    for (final recent in [3, 5, 8]) {
      final det = StructureShiftDetector(lookback: lookback, recentBars: recent);
      structureRows.add(_eval('lb=$lookback recent=$recent', det, structureCases));
    }
  }
  structureRows.sort((a, b) => b.objective.compareTo(a.objective));

  final maRows = <SweepRow>[
    _eval('current_ema20_50_200', MaRegimeDetector(), maCases),
  ];

  final levelRows = <SweepRow>[];
  for (final maxLevels in [4, 6, 8]) {
    levelRows.add(_eval('maxLevels=$maxLevels', LevelsDetector(maxLevels: maxLevels), levelCases));
  }
  levelRows.sort((a, b) => b.objective.compareTo(a.objective));

  // Live density: Binance BTCUSDT if network available.
  Map<String, dynamic>? live;
  try {
    live = await _liveDensity();
  } catch (e) {
    live = {'error': '$e'};
  }

  final report = {
    'objective':
        'precision*0.55 + f1*0.35 + specificity*0.10 (scanner: fewer false hits)',
    'structure_top': structureRows.take(5).map(_rowJson).toList(),
    'structure_current': _rowJson(
      structureRows.firstWhere((r) => r.label == 'lb=3 recent=5', orElse: () => structureRows.first),
    ),
    'ma_current': _rowJson(maRows.first),
    'levels_top': levelRows.map(_rowJson).toList(),
    'live_density': live,
    'recommendations': _recommendations(structureRows, maRows.first, levelRows, live),
  };

  final out = const JsonEncoder.withIndent('  ').convert(report);
  print(out);
  final file = File('tool/param_sweep_report.json');
  await file.writeAsString(out);
  stderr.writeln('Wrote ${file.path}');
}

SweepRow _eval(String label, Detector det, List<Case> cases) {
  var tp = 0, fp = 0, fn = 0, tn = 0;
  final hitScores = <double>[];
  for (final c in cases) {
    final hours = c.kind == DetectorKind.maRegime ? 4 : 1;
    final candles = seriesFromCloses(c.closes, hours: hours);
    final hits = det.detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: AppTimeframe.h4,
      candles: candles,
    );
    final fired = hits.isNotEmpty;
    if (fired) hitScores.addAll(hits.map((h) => h.score));
    if (c.expectHit && fired) {
      tp++;
    } else if (c.expectHit && !fired) {
      fn++;
    } else if (!c.expectHit && fired) {
      fp++;
    } else {
      tn++;
    }
  }
  final avg = hitScores.isEmpty ? 0.0 : hitScores.reduce((a, b) => a + b) / hitScores.length;
  return SweepRow(label, tp, fp, fn, tn, avg);
}

Map<String, dynamic> _rowJson(SweepRow r) => {
      'label': r.label,
      'tp': r.tp,
      'fp': r.fp,
      'fn': r.fn,
      'tn': r.tn,
      'precision': double.parse(r.precision.toStringAsFixed(3)),
      'recall': double.parse(r.recall.toStringAsFixed(3)),
      'f1': double.parse(r.f1.toStringAsFixed(3)),
      'specificity': double.parse(r.specificity.toStringAsFixed(3)),
      'objective': double.parse(r.objective.toStringAsFixed(3)),
      'avgScoreHit': double.parse(r.avgScoreHit.toStringAsFixed(1)),
    };

Future<Map<String, dynamic>> _liveDensity() async {
  final urls = {
    '1h': 'https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1h&limit=240',
    '4h': 'https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=4h&limit=240',
    '1d': 'https://api.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1d&limit=240',
  };
  final out = <String, dynamic>{};
  for (final e in urls.entries) {
    final res = await HttpClient().getUrl(Uri.parse(e.value)).then((r) => r.close());
    final body = await res.transform(utf8.decoder).join();
    final list = jsonDecode(body) as List<dynamic>;
    final candles = list.map((row) {
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

    final tf = switch (e.key) {
      '1h' => AppTimeframe.h1,
      '4h' => AppTimeframe.h4,
      _ => AppTimeframe.d1,
    };

    final density = <String, dynamic>{};
    for (final lb in [2, 3, 4, 5]) {
      for (final recent in [3, 5, 8]) {
        final hits = StructureShiftDetector(lookback: lb, recentBars: recent).detect(
          exchange: ExchangeId.binance,
          symbol: symbol,
          timeframe: tf,
          candles: candles,
        );
        density['struct_lb${lb}_r$recent'] = {
          'n': hits.length,
          'avg': hits.isEmpty
              ? 0
              : double.parse(
                  (hits.map((h) => h.score).reduce((a, b) => a + b) / hits.length)
                      .toStringAsFixed(1),
                ),
          'pass65': hits.where((h) => h.score >= 65).length,
        };
      }
    }
    final ma = MaRegimeDetector().detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: tf,
      candles: candles,
    );
    final lv = LevelsDetector().detect(
      exchange: ExchangeId.binance,
      symbol: symbol,
      timeframe: tf,
      candles: candles,
    );
    density['ma'] = {
      'n': ma.length,
      'avg': ma.isEmpty ? 0 : ma.first.score,
      'pass65': ma.where((h) => h.score >= 65).length,
    };
    density['levels'] = {
      'n': lv.length,
      'avg': lv.isEmpty
          ? 0
          : double.parse(
              (lv.map((h) => h.score).reduce((a, b) => a + b) / lv.length).toStringAsFixed(1),
            ),
      'pass65': lv.where((h) => h.score >= 65).length,
    };
    out[e.key] = density;
  }
  return out;
}

Map<String, dynamic> _recommendations(
  List<SweepRow> structure,
  SweepRow ma,
  List<SweepRow> levels,
  Map<String, dynamic>? live,
) {
  final bestStruct = structure.first;

  // Prefer params that stay quiet on live H1 (noise frame) while keeping synth precision.
  String? livePick;
  if (live != null && live['1h'] is Map) {
    final h1 = Map<String, dynamic>.from(live['1h'] as Map);
    var bestKey = 'struct_lb3_r5';
    var bestScore = -1.0;
    for (final e in h1.entries) {
      if (!e.key.startsWith('struct_')) continue;
      final m = Map<String, dynamic>.from(e.value as Map);
      final n = (m['n'] as num).toDouble();
      final pass = (m['pass65'] as num).toDouble();
      // Live snapshot is one bar — reward sparse pass65, mild n.
      final score = (pass == 0 ? 1.0 : 0.3) + (n <= 1 ? 0.5 : 0.1) - n * 0.05;
      // Also prefer candidates that ranked well on synth.
      final synth = structure.where((r) {
        final parts = e.key.replaceFirst('struct_', '').split('_');
        // struct_lb3_r5
        return r.label.contains(parts[0].replaceFirst('lb', 'lb=')) &&
            r.label.contains(parts[1].replaceFirst('r', 'recent='));
      });
      // Match label like lb=3 recent=5
      final lb = int.parse(e.key.split('_')[1].substring(2));
      final recent = int.parse(e.key.split('_')[2].substring(1));
      final synthRow = structure.firstWhere(
        (r) => r.label == 'lb=$lb recent=$recent',
        orElse: () => structure.last,
      );
      final combined = score + synthRow.objective;
      if (combined > bestScore) {
        bestScore = combined;
        bestKey = e.key;
      }
    }
    livePick = bestKey;
  }

  return {
    'structure': {
      'current': 'lookback=3, recentBars=5',
      'recommended': bestStruct.label,
      'live_noise_aware': livePick,
      'rationale':
          'On labeled synth, maximize precision/specificity. Cross-check live H1 density so scanner stays sparse.',
    },
    'ma': {
      'current': 'EMA20/50/200, 1-bar flip, slope 3 bars',
      'recommended_logic': {
        'periods': '20/50/200 keep (market standard)',
        'confirmBars': 2,
        'oppositeLookback': 8,
        'slopeLookback': 5,
        'distanceBonus': 'cap at 6 or remove (extension ≠ quality)',
        'minScoreInteraction': 68,
      },
      'synth': _rowJson(ma),
      'rationale':
          'Single-bar stack flips are the main false-positive source on H1. Confirm 2 closes in new regime. EMA lengths are already near-optimal for crypto swing framing.',
    },
    'levels': {
      'current': 'tol=0.35ATR, interact<=0.55ATR, minTouches=2, maxLevels=6→take 2',
      'recommended': {
        'clusterTolAtr': 0.40,
        'interactProximityAtr': 0.45,
        'minTouches': 3,
        'maxEmit': 2,
        'pivotLookback': 4,
      },
      'synth_best_maxLevels': levels.first.label,
      'rationale':
          'minTouches=2 invents weak zones; 3+ is the usual discretionary floor. Tighter interact (0.45) cuts mid-range noise; slightly wider cluster (0.40) fits crypto wick noise.',
    },
    'minScore': {
      'current': 65,
      'recommended_default': 70,
      'recommended_scan_relaxed': 60,
      'recommended_telegram': 75,
      'rationale':
          'Base scores are ~58 structure / ~62 MA. Default 65 lets weak flips through. 70 keeps cleanPrior/aligned stack. Telegram should be stricter than on-screen scan.',
    },
    'per_timeframe_pivot': {
      'h1': 5,
      'h4': 4,
      'd1': 3,
      'rationale': 'Same lookback=3 is too sensitive on 1H and a bit late on 1D. Scale pivot window with TF.',
    },
  };
}
