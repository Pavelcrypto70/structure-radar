import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_radar/main.dart';
import 'package:structure_radar/state/locale_controller.dart';
import 'package:structure_radar/state/path_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('language gate first, then Russian splash', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final locale = LocaleController();
    await locale.load();
    final path = PathController();
    await path.load();
    await tester.pumpWidget(StructureRadarApp(locale: locale, path: path));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('STRUCTURE RADAR'), findsWidgets);
  });

  Future<void> boot(WidgetTester tester, String qa) async {
    SharedPreferences.setMockInitialValues({
      'lang_chosen_v1': true,
      'app_lang_v1': 'ru',
    });
    final locale = LocaleController();
    await locale.load();
    final path = PathController();
    await path.applyQaPreset(qa);
    await tester.pumpWidget(StructureRadarApp(locale: locale, path: path));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  final cases = <String, String>{
    'fresh': 'читать структуру',
    'orient': 'ОРИЕНТАЦИЯ · 1 / 3',
    'home': 'НАЧАТЬ МИССИЮ 1',
    'm1': 'МИССИЯ 1 / 4',
    'm4': 'МИССИЯ 4 / 4',
    'habit': 'Ежедневный скан',
    'glossary': 'ТУР ПО ГЛОССАРИЮ',
    'club': 'ОТКРЫТЬ СООБЩЕСТВО',
    'academy': 'УЗНАТЬ БОЛЬШЕ',
    'terminal': 'День закрыт',
  };
  cases.forEach((qa, text) {
    testWidgets('qa=$qa renders its phase', (tester) async {
      await boot(tester, qa);
      expect(find.textContaining(text, skipOffstage: false), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('language chosen → splash with literacy promise', (tester) async {
    SharedPreferences.setMockInitialValues({
      'lang_chosen_v1': true,
      'app_lang_v1': 'ru',
    });
    final locale = LocaleController();
    await locale.load();
    final path = PathController();
    await path.load();
    await tester.pumpWidget(StructureRadarApp(locale: locale, path: path));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('читать структуру'), findsWidgets);
  });
}

