import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/locale_controller.dart';
import 'state/scan_controller.dart';
import 'theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locale = LocaleController();
  await locale.load();
  runApp(StructureRadarApp(locale: locale));
}

class StructureRadarApp extends StatefulWidget {
  const StructureRadarApp({super.key, required this.locale});

  final LocaleController locale;

  @override
  State<StructureRadarApp> createState() => _StructureRadarAppState();
}

class _StructureRadarAppState extends State<StructureRadarApp> {
  bool showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.locale),
        ChangeNotifierProvider(create: (_) => ScanController()..bootstrap()),
      ],
      child: MaterialApp(
        title: 'Structure Radar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: showSplash
            ? SplashScreen(onDone: () => setState(() => showSplash = false))
            : const AppShell(),
      ),
    );
  }
}
