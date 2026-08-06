import 'package:flutter/foundation.dart';

import '../data/market_repository.dart';
import '../domain/models.dart';
import '../l10n/app_lang.dart';
import '../services/alert_profile_store.dart';
import '../services/telegram_bridge.dart';

enum ResultSort { score, time }

class ScanController extends ChangeNotifier {
  ScanController({
    MarketRepository? repository,
    AlertProfileStore? store,
    TelegramBridge? bridge,
  }) : _repository = repository ?? MarketRepository(),
       _store = store ?? AlertProfileStore() {
    _bridge = bridge ?? TelegramBridge(_store);
  }

  final MarketRepository _repository;
  final AlertProfileStore _store;
  late final TelegramBridge _bridge;

  AlertProfile? profile;
  bool disclaimerAccepted = false;
  bool loadingProfile = true;

  bool scanning = false;
  bool cancelRequested = false;
  ScanProgress? progress;
  List<Detection> results = [];
  String? error;
  Detection? selected;

  Set<ExchangeId> selectedExchanges = ExchangeId.values.toSet();
  Set<AppTimeframe> selectedTimeframes = AppTimeframe.values.toSet();
  Set<DetectorKind> selectedDetectors = DetectorKind.values.toSet();
  double minScore = 65;

  DetectorKind? resultFilterKind;
  ResultSort resultSort = ResultSort.score;
  bool justFinishedScan = false;
  int lastUniverseSize = 0;
  int lastRawPairCount = 0;

  TelegramBridge get bridge => _bridge;
  AlertProfileStore get store => _store;

  List<Detection> get visibleResults {
    var list = [...results];
    if (resultFilterKind != null) {
      list = list.where((d) => d.kind == resultFilterKind).toList();
    }
    switch (resultSort) {
      case ResultSort.score:
        list.sort((a, b) => b.score.compareTo(a.score));
      case ResultSort.time:
        list.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    }
    return list;
  }

  Future<void> bootstrap() async {
    loadingProfile = true;
    notifyListeners();
    disclaimerAccepted = await _store.disclaimerAccepted();
    profile = await _store.loadOrCreate();
    // Drop legacy non-USDT venues from older profiles.
    selectedExchanges = profile!.exchanges
        .where((e) => ExchangeId.values.contains(e))
        .toSet();
    if (selectedExchanges.isEmpty) {
      selectedExchanges = ExchangeId.values.toSet();
    }
    selectedTimeframes = {...profile!.timeframes};
    // Ensure 15m/30m are armed after upgrade (Levels short-TF search).
    selectedTimeframes = {
      ...selectedTimeframes,
      AppTimeframe.m15,
      AppTimeframe.m30,
    };
    selectedDetectors = {...profile!.enabledDetectors};
    minScore = profile!.minScore;
    loadingProfile = false;
    notifyListeners();
  }

  Future<void> acceptDisclaimer() async {
    await _store.setDisclaimerAccepted(true);
    disclaimerAccepted = true;
    notifyListeners();
  }

  Future<void> clearDisclaimerAccepted() async {
    await _store.setDisclaimerAccepted(false);
    disclaimerAccepted = false;
    notifyListeners();
  }

  Future<void> saveProfile(AlertProfile next) async {
    profile = next;
    await _store.save(next);
    notifyListeners();
  }

  void consumeScanFinished() {
    justFinishedScan = false;
  }

  void selectDetection(Detection? d) {
    selected = d;
    notifyListeners();
  }

  void setResultFilter(DetectorKind? kind) {
    resultFilterKind = kind;
    notifyListeners();
  }

  void setResultSort(ResultSort sort) {
    resultSort = sort;
    notifyListeners();
  }

  void toggleExchange(ExchangeId e) {
    final next = {...selectedExchanges};
    next.contains(e) ? next.remove(e) : next.add(e);
    selectedExchanges = next;
    notifyListeners();
  }

  void toggleTimeframe(AppTimeframe e) {
    final next = {...selectedTimeframes};
    next.contains(e) ? next.remove(e) : next.add(e);
    selectedTimeframes = next;
    notifyListeners();
  }

  void toggleDetector(DetectorKind e) {
    final next = {...selectedDetectors};
    next.contains(e) ? next.remove(e) : next.add(e);
    selectedDetectors = next;
    notifyListeners();
  }

  void setMinScore(double v) {
    minScore = v;
    notifyListeners();
  }

  Future<void> runScan(L10n t) async {
    if (scanning) return;
    if (selectedExchanges.isEmpty ||
        selectedTimeframes.isEmpty ||
        selectedDetectors.isEmpty) {
      error = t.selectAtLeast;
      notifyListeners();
      return;
    }

    scanning = true;
    cancelRequested = false;
    error = null;
    results = [];
    resultFilterKind = null;
    progress = ScanProgress(done: 0, total: 1, label: t.starting);
    notifyListeners();

    try {
      final hits = await _repository.scan(
        ScanRequest(
          exchanges: selectedExchanges,
          timeframes: selectedTimeframes,
          detectors: selectedDetectors,
          minScore: minScore,
        ),
        onProgress: (p) {
          progress = ScanProgress(
            done: p.done,
            total: p.total,
            label: p.label == 'Done'
                ? t.done
                : p.label.startsWith('Universe')
                ? t.buildingUniverse
                : p.label,
          );
          notifyListeners();
        },
        onPartial: (partial) {
          results = partial;
          notifyListeners();
        },
        isCancelled: () => cancelRequested,
      );

      results = hits;
      lastUniverseSize = _repository.lastUniverseSize;
      lastRawPairCount = _repository.lastRawPairCount;
      if (hits.isEmpty && _repository.lastFetchOk > 0) {
        // Completed but quiet market / strict filters — not an error.
        justFinishedScan = true;
      } else {
        justFinishedScan = true;
      }
      final p = profile;
      if (p != null) {
        for (final d in hits) {
          await _bridge.queueIfArmed(d, p);
        }
      }
    } catch (e) {
      final msg = '$e';
      if (msg.contains('EMPTY_UNIVERSE')) {
        error = t.emptyUniverse;
      } else if (msg.contains('ALL_FETCHES_FAILED')) {
        error = t.allFetchesFailed;
      } else {
        error = msg;
      }
    } finally {
      scanning = false;
      progress = null;
      notifyListeners();
    }
  }

  void cancelScan() {
    cancelRequested = true;
    notifyListeners();
  }

  Future<List<Candle>> fetchCandlesFor({
    required ExchangeId exchange,
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
  }) {
    return _repository.fetchCandles(
      exchange: exchange,
      symbol: symbol,
      timeframe: timeframe,
    );
  }
}
