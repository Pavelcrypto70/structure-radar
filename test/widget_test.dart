import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_radar/main.dart';
import 'package:structure_radar/state/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app boots to Russian splash', (tester) async {
    final locale = LocaleController();
    await locale.load();
    await tester.pumpWidget(StructureRadarApp(locale: locale));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('STRUCTURE RADAR'), findsWidgets);
    expect(find.textContaining('Структура'), findsWidgets);
  });
}
