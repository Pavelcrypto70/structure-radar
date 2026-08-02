import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/disclaimers.dart';
import '../l10n/app_lang.dart';
import '../state/locale_controller.dart';
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
    final locale = context.watch<LocaleController>();
    final t = locale.t;

    if (c.loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTokens.accent)),
      );
    }

    if (!c.disclaimerAccepted) {
      return const _DisclaimerGate();
    }

    final selected = c.selected;
    if (selected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final d = c.selected;
        if (d == null) return;
        c.selectDetection(null);
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 280),
            pageBuilder: (_, anim, __) => DetectionDetailScreen(detection: d),
            transitionsBuilder: (_, anim, __, child) {
              final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0.02),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          ),
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
      extendBody: true,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.radar_outlined),
            selectedIcon: const Icon(Icons.radar),
            label: t.tabRadar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.view_list_outlined),
            selectedIcon: const Icon(Icons.view_list),
            label: t.tabResults,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_outlined),
            selectedIcon: const Icon(Icons.tune),
            label: t.tabProfile,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: t.tabGlossary,
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
                        label: Text(t.cancel),
                      ),
                    ),
                  if (c.scanning) const SizedBox(width: 12),
                  Expanded(
                    flex: c.scanning ? 2 : 1,
                    child: FloatingActionButton.extended(
                      heroTag: 'scan',
                      onPressed: c.scanning ? null : () => c.runScan(t),
                      backgroundColor: AppTokens.accent,
                      foregroundColor: const Color(0xFF1A140C),
                      icon: Icon(
                        c.scanning ? Icons.hourglass_top : Icons.play_arrow_rounded,
                      ),
                      label: Text(c.scanning ? t.scanning : t.runScan),
                    ),
                  ),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(
          t.appName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              locale.setLang(
                locale.lang == AppLang.ru ? AppLang.en : AppLang.ru,
              );
            },
            child: Text(
              locale.lang == AppLang.ru ? 'EN' : 'RU',
              style: const TextStyle(
                color: AppTokens.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: t.disclaimers,
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
    final locale = context.watch<LocaleController>();
    final t = locale.t;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.appName,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      locale.setLang(
                        locale.lang == AppLang.ru ? AppLang.en : AppLang.ru,
                      );
                    },
                    child: Text(
                      locale.lang == AppLang.ru ? 'EN' : 'RU',
                      style: const TextStyle(
                        color: AppTokens.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.beforeContinue,
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTokens.strokeSoft),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      AppDisclaimers.full(locale.lang),
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
                  t.acceptDisclaimer,
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
                  child: Text(t.enterRadar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
