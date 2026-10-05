import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_radar/domain/models.dart';
import 'package:structure_radar/state/path_controller.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PathController make() {
    final c = PathController();
    c.bindScan(
      applyLens: (_) {},
      firstGestureDone: () => false,
      markFirstGesture: () async {},
    );
    return c;
  }

  test('cold state: splash then orientation then literacy home', () async {
    final c = make();
    await c.load();
    expect(c.showSplash, isTrue);
    c.markSplashSeen();
    expect(c.showOrientation, isTrue);
    c.advanceOrient();
    c.advanceOrient();
    c.advanceOrient();
    expect(c.showOrientation, isFalse);
    expect(c.showLiteracyHome, isTrue);
    expect(c.tabsUnlocked, isFalse);
  });

  test('missions unlock sequentially and need a matching hit', () async {
    final c = make();
    await c.load();
    expect(c.missionUnlocked(1), isTrue);
    expect(c.missionUnlocked(2), isFalse);

    c.startMission(2); // locked → ignored
    expect(c.inMission, isFalse);

    c.startMission(1);
    expect(c.inMission, isTrue);
    expect(c.showLiteracyHome, isFalse);

    c.recordHitOpen(DetectorKind.levels); // wrong kind
    expect(c.missionHitReady, isFalse);
    await c.completeMission();
    expect(c.inMission, isTrue);

    c.recordHitOpen(DetectorKind.structureShift);
    expect(c.missionHitReady, isTrue);
    await c.completeMission();
    expect(c.literacyStep, 1);
    expect(c.inMission, isFalse);
    expect(c.missionUnlocked(2), isTrue);
  });

  test('empty scan can complete a mission', () async {
    final c = make();
    await c.load();
    c.startMission(1);
    await c.completeMission(emptyOk: true);
    expect(c.literacyStep, 1);
  });

  test('mission 4 → phase 2 bridge → habit', () async {
    final c = make();
    await c.load();
    for (var n = 1; n <= 4; n++) {
      c.startMission(n);
      c.recordHitOpen(DetectorKind.structureShift);
      if (n == 4 || n == 1) {
        await c.completeMission();
      } else {
        await c.completeMission(emptyOk: true);
      }
    }
    expect(c.literacyStep, 4);
    expect(c.tabsUnlocked, isTrue);
    expect(c.showPhase2Bridge, isTrue);
    c.dismissPhase2Bridge();
    expect(c.showPhase2Bridge, isFalse);
    expect(c.literacyStep, 5);
  });

  test('habit day counts once per day; glossary at 3 hits', () async {
    final c = make();
    await c.load();
    c.literacyStep = 5;
    c.p2BridgeSeen = true;
    c.recordScan();
    c.recordHitOpen(DetectorKind.maRegime);
    c.recordHitOpen(DetectorKind.levels);
    expect(c.habitDays, 1);
    expect(c.showGlossaryTour, isFalse);
    c.recordHitOpen(DetectorKind.structureShift);
    expect(c.showGlossaryTour, isTrue);
    c.dismissGlossaryTour();
    expect(c.showGlossaryTour, isFalse);
  });

  test('qa presets land on the right phase', () async {
    final c = make();
    await c.applyQaPreset('m3');
    expect(c.activeMission, 3);
    expect(c.literacyStep, 2);

    await c.applyQaPreset('club');
    expect(c.showClubBridge, isTrue);

    await c.applyQaPreset('academy');
    expect(c.showAcademyBridge, isTrue);

    await c.applyQaPreset('glossary');
    expect(c.showGlossaryTour, isTrue);

    await c.applyQaPreset('terminal');
    expect(c.showGlossaryTour || c.showClubBridge || c.showAcademyBridge,
        isFalse);

    expect(await c.applyQaPreset('nope'), isFalse);
  });
}
