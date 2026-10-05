import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:structure_radar/l10n/app_lang.dart';
import 'package:structure_radar/l10n/path_l10n.dart';
import 'package:structure_radar/state/locale_controller.dart';
import 'package:structure_radar/state/path_controller.dart';
import 'package:structure_radar/state/scan_controller.dart';
import 'package:structure_radar/theme/app_theme.dart';
import 'package:structure_radar/ui/path/empty_hit_sheet.dart';
import 'package:structure_radar/ui/path/mission_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('empty hit sheet opens and continue works', (tester) async {
    var continued = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FilledButton(
                onPressed: () {
                  showEmptyHitSheet(
                    context,
                    pl: PathL10n(AppLang.ru),
                    onContinue: () => continued = true,
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Пустой скан — не ошибка'), findsOneWidget);
    expect(find.textContaining('DESK CLUB'), findsWidgets);
    expect(find.text('ПРОДОЛЖИТЬ ПУТЬ'), findsOneWidget);
    expect(find.text('ОТКРЫТЬ DESK CLUB'), findsOneWidget);

    await tester.tap(find.text('ПРОДОЛЖИТЬ ПУТЬ'));
    await tester.pumpAndSettle();

    expect(continued, isTrue);
    expect(find.text('Пустой скан — не ошибка'), findsNothing);
  });

  testWidgets('empty sheet from nested shell-like scaffold (useRootNavigator)',
      (tester) async {
    final pl = PathL10n(AppLang.ru);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const Text('header'),
                Expanded(
                  child: ListView(
                    children: [
                      Builder(
                        builder: (context) {
                          return FilledButton(
                            onPressed: () => showEmptyHitSheet(
                              context,
                              pl: pl,
                              onContinue: () {},
                            ),
                            child: Text(pl.bannerWhyEmpty),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text(pl.bannerWhyEmpty));
    expect(tester.takeException(), isNull);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('Пустой скан — не ошибка'), findsOneWidget);
  });

  testWidgets('mission banner why-empty opens sheet after empty scan',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'lang_chosen_v1': true,
      'app_lang_v1': 'ru',
    });
    final locale = LocaleController();
    await locale.load();
    final path = PathController();
    await path.applyQaPreset('m1');

    late ScanController scan;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: locale),
          ChangeNotifierProvider.value(value: path),
          ChangeNotifierProvider(
            create: (_) {
              scan = ScanController()
                ..attachPath(path)
                ..bootstrap();
              return scan;
            },
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: const [MissionBanner()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    scan.lensScanDone = true;
    scan.results = [];
    scan.scanning = false;
    scan.notifyListeners();
    await tester.pump();

    final pl = PathL10n(AppLang.ru);
    expect(find.text(pl.bannerWhyEmpty), findsOneWidget);

    await tester.tap(find.text(pl.bannerWhyEmpty));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Пустой скан — не ошибка'), findsOneWidget);
  });
}
