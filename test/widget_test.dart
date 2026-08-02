import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_radar/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app boots to disclaimer gate', (tester) async {
    await tester.pumpWidget(const StructureRadarApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('Structure Radar'), findsWidgets);
    expect(find.textContaining('Educational'), findsWidgets);
  });
}
