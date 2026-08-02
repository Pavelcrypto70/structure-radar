import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../domain/disclaimers.dart';
import '../l10n/app_lang.dart';
import '../state/locale_controller.dart';
import '../state/scan_controller.dart';
import '../theme/tokens.dart';
import 'screens/detection_detail_screen.dart';
import 'screens/glossary_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/radar_guide_screen.dart';
import 'screens/results_screen.dart';
import 'screens/scan_screen.dart';
import 'widgets/first_run_coach.dart';
import 'widgets/scan_recap_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  bool _coachDismissed = false;
  bool _recapBusy = false;
  bool _firstRunScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstRunScheduled) return;
    _firstRunScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final t = context.read<LocaleController>().t;
      await FirstRunCoach.show(context, t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final locale = context.watch<LocaleController>();
    final t = locale.t;

    if (c.loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: SrColors.accent)),
      );
    }

    if (!c.disclaimerAccepted) {
      return const _DisclaimerGate();
    }

    // Scan ceremony
    if (!c.scanning && c.justFinishedScan && !_recapBusy) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || _recapBusy) return;
        _recapBusy = true;
        c.consumeScanFinished();
        await showScanRecapSheet(
          context,
          t: t,
          hits: c.results.length,
          minScore: c.minScore,
          universeSize: c.lastUniverseSize,
          rawPairCount: c.lastRawPairCount,
          onOpenResults: () => setState(() => index = 1),
        );
        _recapBusy = false;
      });
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
            transitionDuration: SrMotion.standard,
            pageBuilder: (_, anim, __) => DetectionDetailScreen(detection: d),
            transitionsBuilder: (_, anim, __, child) {
              final curved = CurvedAnimation(parent: anim, curve: SrMotion.curveIn);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0.02),
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

    final pages = [
      ScanScreen(
        showCoach: !_coachDismissed,
        onDismissCoach: () => setState(() => _coachDismissed = true),
      ),
      const ResultsScreen(),
      const ProfileScreen(),
      const GlossaryScreen(),
    ];

    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Text(t.appName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  SrModeChip(live: !kIsWeb, stamp: t.buildStamp),
                  const Spacer(),
                  IconButton(
                    tooltip: t.guideCta,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RadarGuideScreen(t: t),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_outlined, size: 20),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      locale.setLang(
                        locale.lang == AppLang.ru ? AppLang.en : AppLang.ru,
                      );
                    },
                    child: Text(
                      locale.lang == AppLang.ru ? 'EN' : 'RU',
                      style: const TextStyle(
                        color: SrColors.accent,
                        fontWeight: FontWeight.w800,
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
            ),
            Expanded(child: IndexedStack(index: index, children: pages)),
            if (index == 0)
              _ScanActionDock(
                scanning: c.scanning,
                cancelLabel: t.cancel,
                scanLabel: c.scanning ? t.scanning : t.runScan,
                onCancel: c.cancelScan,
                onScan: () {
                  HapticFeedback.mediumImpact();
                  c.runScan(t);
                },
              ),
            _TerminalNav(
              index: index,
              labels: [t.tabRadar, t.tabResults, t.tabProfile, t.tabGlossary],
              onSelect: (i) {
                HapticFeedback.selectionClick();
                setState(() => index = i);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanActionDock extends StatelessWidget {
  const _ScanActionDock({
    required this.scanning,
    required this.cancelLabel,
    required this.scanLabel,
    required this.onCancel,
    required this.onScan,
  });

  final bool scanning;
  final String cancelLabel;
  final String scanLabel;
  final VoidCallback onCancel;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SrColors.bg,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: const BoxDecoration(
          color: SrColors.bg,
          border: Border(top: BorderSide(color: SrColors.lineSoft)),
        ),
        child: Row(
          children: [
            if (scanning) ...[
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SrColors.text,
                      side: const BorderSide(color: SrColors.line),
                      backgroundColor: SrColors.surface2,
                      disabledBackgroundColor: SrColors.surface2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SrRadius.md),
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: scanning ? 2 : 1,
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: scanning ? null : onScan,
                  icon: Icon(
                    scanning ? Icons.hourglass_top : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  label: Text(scanLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: SrColors.accent,
                    foregroundColor: SrColors.onAccent,
                    disabledBackgroundColor: SrColors.accent.withValues(alpha: 0.55),
                    disabledForegroundColor: SrColors.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SrRadius.md),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SrModeChip extends StatelessWidget {
  const SrModeChip({super.key, required this.live, this.stamp});
  final bool live;
  final String? stamp;

  @override
  Widget build(BuildContext context) {
    final color = live ? SrColors.bull : SrColors.warn;
    final label = live
        ? 'LIVE'
        : (stamp == null || stamp!.isEmpty ? 'WEB' : 'WEB · $stamp');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _TerminalNav extends StatelessWidget {
  const _TerminalNav({
    required this.index,
    required this.labels,
    required this.onSelect,
  });

  final int index;
  final List<String> labels;
  final ValueChanged<int> onSelect;

  static const _icons = [
    Icons.radar_outlined,
    Icons.view_list_outlined,
    Icons.tune_outlined,
    Icons.menu_book_outlined,
  ];
  static const _iconsSelected = [
    Icons.radar,
    Icons.view_list,
    Icons.tune,
    Icons.menu_book,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: SrColors.bgElevated,
        border: Border(top: BorderSide(color: SrColors.lineSoft)),
      ),
      child: Row(
        children: List.generate(4, (i) {
          final selected = index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: SrMotion.micro,
                curve: SrMotion.curveToggle,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? SrColors.accentSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(SrRadius.md),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.08 : 1,
                      duration: SrMotion.micro,
                      child: Icon(
                        selected ? _iconsSelected[i] : _icons[i],
                        size: 20,
                        color: selected ? SrColors.accent : SrColors.faint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: selected ? SrColors.accent : SrColors.faint,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
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
                    onPressed: () => locale.setLang(
                      locale.lang == AppLang.ru ? AppLang.en : AppLang.ru,
                    ),
                    child: Text(
                      locale.lang == AppLang.ru ? 'EN' : 'RU',
                      style: const TextStyle(
                        color: SrColors.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.beforeContinue,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SrColors.accent,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SrColors.surface,
                    borderRadius: BorderRadius.circular(SrRadius.xl),
                    border: Border.all(color: SrColors.lineSoft),
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
                activeColor: SrColors.accent,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  t.acceptDisclaimer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SrColors.text,
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
                          HapticFeedback.mediumImpact();
                          await c.acceptDisclaimer();
                        }
                      : null,
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
