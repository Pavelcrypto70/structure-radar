import 'package:flutter/foundation.dart';

import '../data/market_repository.dart';
import '../domain/models.dart';
import '../services/alert_profile_store.dart';
import '../services/telegram_bridge.dart';

class ScanController extends ChangeNotifier {
  ScanController({
    MarketRepository? repository,
    AlertProfileStore? store,
    TelegramBridge? bridge,
  })  : _repository = repository ?? MarketRepository(),
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

  TelegramBridge get bridge => _bridge;
  AlertProfileStore get store => _store;

  Future<void> bootstrap() async {
    loadingProfile = true;
    notifyListeners();
    disclaimerAccepted = await _store.disclaimerAccepted();
    profile = await _store.loadOrCreate();
    selectedExchanges = {...profile!.exchanges};
    selectedTimeframes = {...profile!.timeframes};
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

  Future<void> saveProfile(AlertProfile next) async {
    profile = next;
    await _store.save(next);
    notifyListeners();
  }

  void selectDetection(Detection? d) {
    selected = d;
    notifyListeners();
  }

  Future<void> runScan() async {
    if (scanning) return;
    if (selectedExchanges.isEmpty ||
        selectedTimeframes.isEmpty ||
        selectedDetectors.isEmpty) {
      error = 'Select at least one exchange, timeframe, and detector.';
      notifyListeners();
      return;
    }

    scanning = true;
    cancelRequested = false;
    error = null;
    results = [];
    progress = const ScanProgress(done: 0, total: 1, label: 'Starting…');
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
          progress = p;
          notifyListeners();
        },
        isCancelled: () => cancelRequested,
      );

      results = hits;
      final p = profile;
      if (p != null) {
        for (final d in hits) {
          await _bridge.queueIfArmed(d, p);
        }
      }
    } catch (e) {
      error = '$e';
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
}
