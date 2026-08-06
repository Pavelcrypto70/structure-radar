import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/locale_controller.dart';
import 'state/scan_controller.dart';
import 'theme/app_theme.dart';
import 'ui/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locale = LocaleController();
  await locale.load();
  runApp(StructureRadarApp(locale: locale));
}

class StructureRadarApp extends StatelessWidget {
  const StructureRadarApp({super.key, required this.locale});

  final LocaleController locale;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locale),
        ChangeNotifierProvider(create: (_) => ScanController()..bootstrap()),
      ],
      child: MaterialApp(
        title: 'Structure Radar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('pt'),
          Locale('ru'),
        ],
        home: const AppShell(),
      ),
    );
  }
}
