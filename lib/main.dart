import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_lang.dart';
import 'state/locale_controller.dart';
import 'state/path_controller.dart';
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

/// Web QA hook: `?qa=m1` (also accepts `#/?qa=m1`).
String? _qaParam() {
  if (!kIsWeb) return null;
  final uri = Uri.base;
  var qa = uri.queryParameters['qa'];
  if (qa == null && uri.fragment.contains('?')) {
    final frag = uri.fragment;
    qa = Uri.splitQueryString(frag.substring(frag.indexOf('?') + 1))['qa'];
  }
  return (qa == null || qa.isEmpty) ? null : qa;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _wipeFirstGestureIfNeeded();
  await PathController.wipeIfNeeded();
  final locale = LocaleController();
  await locale.load();
  final path = PathController();
  final qa = _qaParam();
  if (qa != null && PathController.qaPresets.contains(qa.toLowerCase())) {
    // Any ?qa= skips the language gate.
    await locale.setLang(AppLang.ru);
    await path.applyQaPreset(qa);
  } else {
    await path.load();
  }
  runApp(StructureRadarApp(locale: locale, path: path));
}

class StructureRadarApp extends StatelessWidget {
  const StructureRadarApp({super.key, required this.locale, required this.path});

  final LocaleController locale;
  final PathController path;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locale),
        ChangeNotifierProvider.value(value: path),
        ChangeNotifierProvider(
          create: (_) => ScanController()
            ..attachPath(path)
            ..bootstrap(),
        ),
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
