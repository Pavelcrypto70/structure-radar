import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'state/locale_controller.dart';
import 'state/scan_controller.dart';
import 'theme/app_theme.dart';
import 'ui/shell.dart';

Future<void> _wipeFirstGestureIfNeeded() async {
  const stamp = 'structure_radar_fresh_20260910';
  final p = await SharedPreferences.getInstance();
  if (p.getBool(stamp) ?? false) return;
  await p.remove('first_gesture_v1');
  await p.remove('first_run_done_v1');
  await p.setBool(stamp, true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _wipeFirstGestureIfNeeded();
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
