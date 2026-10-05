import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

/// Guided literacy path: orientation → 4 missions → habit → bridges.
///
/// Pure progress state (SharedPreferences). The scan layer is attached through
/// callbacks so this file has no dependency on ScanController.
class PathController extends ChangeNotifier {
  static const wipeStamp = 'structure_radar_path_20261005';

  static const kSplashSeen = 'splash_seen_v1';
  static const kOrientStep = 'sr_orient_step_v1';
  static const kLiteracyStep = 'sr_literacy_step_v1';
  static const kActiveMission = 'sr_active_mission_v1';
  static const kHitsOpened = 'sr_hits_opened_v1';
  static const kScans = 'sr_scans_v1';
  static const kHabitDays = 'sr_habit_days_v1';
  static const kHabitDay = 'sr_habit_day_v1';
  static const kScanDay = 'sr_scan_day_v1';
  static const kSeenKinds = 'sr_seen_kinds_v1';
  static const kP2 = 'sr_p2_bridge_seen_v1';
  static const kGlossary = 'sr_glossary_tour_seen_v1';
  static const kClub = 'sr_club_bridge_seen_v1';
  static const kAcademy = 'sr_academy_bridge_seen_v1';

  static const allKeys = <String>[
    kSplashSeen,
    kOrientStep,
    kLiteracyStep,
    kActiveMission,
    kHitsOpened,
    kScans,
    kHabitDays,
    kHabitDay,
    kScanDay,
    kSeenKinds,
    kP2,
    kGlossary,
    kClub,
    kAcademy,
  ];

  /// One-time wipe of path keys (call before [load]).
  static Future<void> wipeIfNeeded() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool(wipeStamp) ?? false) return;
    for (final k in allKeys) {
      await p.remove(k);
    }
    await p.setBool(wipeStamp, true);
  }

  // --- persisted state ---
  bool loaded = false;
  bool splashSeen = false;
  int orientStep = 0; // 0..3
  int literacyStep = 0; // 0..3 pending, 4 missions done, 5 habit mode
  int? activeMission; // 1..4
  int hitsOpened = 0;
  int scansCompleted = 0;
  int habitDays = 0;
  String habitDayStamp = '';
  String scanDayStamp = '';
  int seenKinds = 0; // bit0 structure, bit1 ma, bit2 levels
  bool p2BridgeSeen = false;
  bool glossaryTourSeen = false;
  bool clubBridgeSeen = false;
  bool academyBridgeSeen = false;

  // --- transient ---
  /// A hit matching the active mission was opened this session.
  bool missionHitReady = false;

  /// Last mission finished (for celebratory copy); cleared on read.
  int? lastCompletedMission;

  // --- scan wiring ---
  void Function(DetectorKind? kind)? _applyLens;
  bool Function()? _firstGestureDone;
  Future<void> Function()? _markFirstGesture;

  void bindScan({
    required void Function(DetectorKind? kind) applyLens,
    required bool Function() firstGestureDone,
    required Future<void> Function() markFirstGesture,
  }) {
    _applyLens = applyLens;
    _firstGestureDone = firstGestureDone;
    _markFirstGesture = markFirstGesture;
  }

  // --- derived ---
  static const missionCount = 4;

  static DetectorKind? kindForMission(int n) => switch (n) {
    1 => DetectorKind.structureShift,
    2 => DetectorKind.maRegime,
    3 => DetectorKind.levels,
    _ => null,
  };

  static int kindBit(DetectorKind k) => switch (k) {
    DetectorKind.structureShift => 1,
    DetectorKind.maRegime => 2,
    DetectorKind.levels => 4,
  };

  bool hasSeenKind(DetectorKind k) => seenKinds & kindBit(k) != 0;

  DetectorKind? get activeMissionKind =>
      activeMission == null ? null : kindForMission(activeMission!);

  bool get inMission => activeMission != null;
  bool get missionsDone => literacyStep >= 4;
  bool get firstGestureDone => _firstGestureDone?.call() ?? false;

  bool get tabsUnlocked => literacyStep >= 4 || firstGestureDone;

  bool get showSplash => !splashSeen;
  bool get showOrientation => orientStep < 3;
  bool get showLiteracyHome => literacyStep < 4 && activeMission == null;
  bool get showPhase2Bridge =>
      literacyStep >= 4 && activeMission == null && !p2BridgeSeen;
  bool get showGlossaryTour =>
      p2BridgeSeen && hitsOpened >= 3 && !glossaryTourSeen;
  bool get showClubBridge => p2BridgeSeen && habitDays >= 3 && !clubBridgeSeen;
  bool get showAcademyBridge =>
      p2BridgeSeen && habitDays >= 7 && !academyBridgeSeen;

  /// Mission n can be started once all previous ones are done.
  bool missionUnlocked(int n) => n >= 1 && n <= 4 && n - 1 <= literacyStep;
  bool missionDone(int n) => literacyStep >= n;

  String get today {
    final d = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  bool get scannedToday => scanDayStamp == today;
  bool get habitCountedToday => habitDayStamp == today;

  /// Scan done today but the day is not yet counted (no hit opened).
  bool get canCheckInToday =>
      missionsDone && scannedToday && !habitCountedToday;

  // --- persistence ---
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    splashSeen = p.getBool(kSplashSeen) ?? false;
    orientStep = (p.getInt(kOrientStep) ?? 0).clamp(0, 3);
    literacyStep = (p.getInt(kLiteracyStep) ?? 0).clamp(0, 5);
    final m = p.getInt(kActiveMission) ?? 0;
    activeMission = (m >= 1 && m <= 4) ? m : null;
    hitsOpened = p.getInt(kHitsOpened) ?? 0;
    scansCompleted = p.getInt(kScans) ?? 0;
    habitDays = p.getInt(kHabitDays) ?? 0;
    habitDayStamp = p.getString(kHabitDay) ?? '';
    scanDayStamp = p.getString(kScanDay) ?? '';
    seenKinds = p.getInt(kSeenKinds) ?? 0;
    p2BridgeSeen = p.getBool(kP2) ?? false;
    glossaryTourSeen = p.getBool(kGlossary) ?? false;
    clubBridgeSeen = p.getBool(kClub) ?? false;
    academyBridgeSeen = p.getBool(kAcademy) ?? false;
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(kSplashSeen, splashSeen);
    await p.setInt(kOrientStep, orientStep);
    await p.setInt(kLiteracyStep, literacyStep);
    if (activeMission == null) {
      await p.remove(kActiveMission);
    } else {
      await p.setInt(kActiveMission, activeMission!);
    }
    await p.setInt(kHitsOpened, hitsOpened);
    await p.setInt(kScans, scansCompleted);
    await p.setInt(kHabitDays, habitDays);
    await p.setString(kHabitDay, habitDayStamp);
    await p.setString(kScanDay, scanDayStamp);
    await p.setInt(kSeenKinds, seenKinds);
    await p.setBool(kP2, p2BridgeSeen);
    await p.setBool(kGlossary, glossaryTourSeen);
    await p.setBool(kClub, clubBridgeSeen);
    await p.setBool(kAcademy, academyBridgeSeen);
  }

  void _commit() {
    notifyListeners();
    _save();
  }

  // --- gate / orientation ---
  void markSplashSeen() {
    if (splashSeen) return;
    splashSeen = true;
    _commit();
  }

  void advanceOrient() {
    if (orientStep >= 3) return;
    orientStep++;
    _commit();
  }

  // --- missions ---
  void startMission(int n) {
    if (!missionUnlocked(n)) return;
    activeMission = n;
    missionHitReady = false;
    _applyLens?.call(kindForMission(n));
    _commit();
  }

  /// Leave the mission overlay without finishing (back to mission rail).
  void leaveMission() {
    if (activeMission == null) return;
    activeMission = null;
    missionHitReady = false;
    _applyLens?.call(null);
    _commit();
  }

  /// Finish the active mission. [emptyOk] = scan returned 0 hits and the user
  /// went through the "understand empty" teach sheet.
  Future<void> completeMission({bool emptyOk = false}) async {
    final n = activeMission;
    if (n == null) return;
    if (!missionHitReady && !emptyOk) return;
    final hadHit = missionHitReady;
    if (literacyStep < n) literacyStep = n; // n-1 pending → n done
    activeMission = null;
    missionHitReady = false;
    lastCompletedMission = n;
    _applyLens?.call(null);
    if (n == 4) {
      await _markFirstGesture?.call();
      if (hadHit) _countHabitDay();
    }
    _commit();
  }

  int? takeLastCompletedMission() {
    final v = lastCompletedMission;
    lastCompletedMission = null;
    return v;
  }

  // --- scan hooks ---
  void recordScan() {
    scansCompleted++;
    scanDayStamp = today;
    _commit();
  }

  void recordHitOpen(DetectorKind kind) {
    hitsOpened++;
    seenKinds |= kindBit(kind);
    final n = activeMission;
    if (n != null) {
      final want = kindForMission(n);
      if (want == null || want == kind) missionHitReady = true;
    } else if (missionsDone && scannedToday) {
      _countHabitDay();
    }
    _commit();
  }

  // --- habit ---
  void _countHabitDay() {
    if (habitDayStamp == today) return;
    habitDayStamp = today;
    habitDays++;
  }

  /// Explicit daily check-in after a completed scan.
  void markHabitDay() {
    if (!missionsDone || !scannedToday) return;
    _countHabitDay();
    _commit();
  }

  // --- bridges ---
  void dismissPhase2Bridge() {
    p2BridgeSeen = true;
    if (literacyStep < 5) literacyStep = 5;
    _commit();
  }

  void dismissGlossaryTour() {
    glossaryTourSeen = true;
    _commit();
  }

  void dismissClubBridge() {
    clubBridgeSeen = true;
    _commit();
  }

  void dismissAcademyBridge() {
    academyBridgeSeen = true;
    _commit();
  }

  // --- QA presets (web ?qa=) ---
  static const qaPresets = [
    'fresh',
    'orient',
    'home',
    'm1',
    'm2',
    'm3',
    'm4',
    'habit',
    'glossary',
    'club',
    'academy',
    'terminal',
  ];

  /// Writes a complete path state to prefs and reloads. Also forces the
  /// non-path gates (disclaimer / first gesture) so the preset lands exactly.
  /// Returns false when [qa] is null/unknown.
  Future<bool> applyQaPreset(String? qa) async {
    final key = qa?.trim().toLowerCase();
    if (key == null || !qaPresets.contains(key)) return false;

    final p = await SharedPreferences.getInstance();
    for (final k in allKeys) {
      await p.remove(k);
    }
    await p.setBool(wipeStamp, true);
    await p.remove('first_gesture_v1');
    await p.remove('first_run_done_v1');
    await p.setBool('disclaimer_accepted_v1', key != 'fresh');

    final mMatch = RegExp(r'^m([1-4])$').firstMatch(key);
    final today = this.today;

    Future<void> setInt(String k, int v) => p.setInt(k, v);

    if (key == 'fresh') {
      // Language chosen (by main), but splash + disclaimer + path all cold.
      await p.setBool(kSplashSeen, false);
    } else {
      await p.setBool(kSplashSeen, true);
    }

    if (key == 'orient') {
      await setInt(kOrientStep, 0);
    } else if (key != 'fresh') {
      await setInt(kOrientStep, 3);
    }

    if (key == 'home') {
      await setInt(kLiteracyStep, 0);
    } else if (mMatch != null) {
      final n = int.parse(mMatch.group(1)!);
      await setInt(kLiteracyStep, n - 1);
      await setInt(kActiveMission, n);
      var mask = 0;
      if (n > 1) mask |= 1;
      if (n > 2) mask |= 2;
      if (n > 3) mask |= 4;
      await setInt(kSeenKinds, mask);
      await setInt(kHitsOpened, n - 1);
      await setInt(kScans, n - 1);
    } else if (const {
      'habit',
      'glossary',
      'club',
      'academy',
      'terminal',
    }.contains(key)) {
      await p.setBool('first_gesture_v1', true);
      await p.setBool('first_run_done_v1', true);
      await setInt(kLiteracyStep, 5);
      await setInt(kSeenKinds, 7);
      await p.setBool(kP2, true);
      switch (key) {
        case 'habit':
          await setInt(kHitsOpened, 1);
          await setInt(kScans, 5);
          await setInt(kHabitDays, 1);
          await p.setString(kHabitDay, '2000-01-01');
        case 'glossary':
          await setInt(kHitsOpened, 3);
          await setInt(kScans, 6);
          await setInt(kHabitDays, 1);
          await p.setString(kHabitDay, '2000-01-01');
        case 'club':
          await setInt(kHitsOpened, 5);
          await setInt(kScans, 9);
          await setInt(kHabitDays, 3);
          await p.setString(kHabitDay, '2000-01-01');
          await p.setBool(kGlossary, true);
        case 'academy':
          await setInt(kHitsOpened, 12);
          await setInt(kScans, 20);
          await setInt(kHabitDays, 7);
          await p.setString(kHabitDay, '2000-01-01');
          await p.setBool(kGlossary, true);
          await p.setBool(kClub, true);
        case 'terminal':
          await setInt(kHitsOpened, 14);
          await setInt(kScans, 24);
          await setInt(kHabitDays, 2);
          await p.setString(kHabitDay, today);
          await p.setString(kScanDay, today);
          await p.setBool(kGlossary, true);
          await p.setBool(kClub, true);
          await p.setBool(kAcademy, true);
      }
    }

    await load();
    return true;
  }
}
