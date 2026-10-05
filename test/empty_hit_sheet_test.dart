import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:structure_radar/l10n/app_lang.dart';
import 'package:structure_radar/l10n/path_l10n.dart';
import 'package:structure_radar/theme/app_theme.dart';
import 'package:structure_radar/ui/path/empty_hit_sheet.dart';

void main() {
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
    expect(find.text('ПОНЯТНО — ДАЛЬШЕ'), findsOneWidget);

    await tester.tap(find.text('ПОНЯТНО — ДАЛЬШЕ'));
    await tester.pumpAndSettle();

    expect(continued, isTrue);
    expect(find.text('Пустой скан — не ошибка'), findsNothing);
  });
}
