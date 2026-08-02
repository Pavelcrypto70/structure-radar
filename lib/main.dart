import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/scan_controller.dart';
import 'theme/app_theme.dart';
import 'ui/shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StructureRadarApp());
}

class StructureRadarApp extends StatelessWidget {
  const StructureRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanController()..bootstrap(),
      child: MaterialApp(
        title: 'Structure Radar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const AppShell(),
      ),
    );
  }
}
