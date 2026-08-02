import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/disclaimers.dart';
import '../state/scan_controller.dart';
import '../theme/app_theme.dart';
import 'screens/detection_detail_screen.dart';
import 'screens/glossary_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/results_screen.dart';
import 'screens/scan_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();

    if (c.loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTokens.accent)),
      );
    }

    if (!c.disclaimerAccepted) {
      return const _DisclaimerGate();
    }

    // Push detail when selected
    final selected = c.selected;
    if (selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final d = c.selected;
        if (d == null) return;
        c.selectDetection(null);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetectionDetailScreen(detection: d)),
        );
      });
    }

    final pages = const [
      ScanScreen(),
      ResultsScreen(),
      ProfileScreen(),
      GlossaryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: AppTokens.bgElevated,
        indicatorColor: AppTokens.accentSoft,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: 'Radar',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_list_outlined),
            selectedIcon: Icon(Icons.view_list),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Glossary',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: index == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (c.scanning)
                    Expanded(
                      child: FloatingActionButton.extended(
                        heroTag: 'cancel',
                        onPressed: c.cancelScan,
                        backgroundColor: AppTokens.bgSoft,
                        foregroundColor: AppTokens.textPrimary,
                        label: const Text('Cancel'),
                      ),
                    ),
                  if (c.scanning) const SizedBox(width: 12),
                  Expanded(
                    flex: c.scanning ? 2 : 1,
                    child: FloatingActionButton.extended(
                      heroTag: 'scan',
                      onPressed: c.scanning ? null : c.runScan,
                      backgroundColor: AppTokens.accent,
                      foregroundColor: const Color(0xFF1A140C),
                      icon: Icon(c.scanning ? Icons.hourglass_top : Icons.play_arrow_rounded),
                      label: Text(c.scanning ? 'Scanning…' : 'Run scan'),
                    ),
                  ),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Disclaimers',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LegalScreen()),
              );
            },
            icon: const Icon(Icons.gavel_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerGate extends StatefulWidget {
  const _DisclaimerGate();

  @override
  State<_DisclaimerGate> createState() => _DisclaimerGateState();
}

class _DisclaimerGateState extends State<_DisclaimerGate> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    final c = context.read<ScanController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Structure Radar', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Before you continue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTokens.accent,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTokens.bgElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTokens.strokeSoft),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      AppDisclaimers.full,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: checked,
                activeColor: AppTokens.accent,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppDisclaimers.acceptanceLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTokens.textPrimary,
                      ),
                ),
                onChanged: (v) => setState(() => checked = v ?? false),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: checked
                      ? () async {
                          await c.acceptDisclaimer();
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.accent,
                    foregroundColor: const Color(0xFF1A140C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enter Radar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
