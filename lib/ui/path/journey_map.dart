import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/path_l10n.dart';
import '../../state/locale_controller.dart';
import '../../state/path_controller.dart';
import '../../theme/tokens.dart';
import 'path_kit.dart';

/// Visual journey: Start → Orientation → Missions → Habit → Glossary → Club → Academy.
class JourneyMapScreen extends StatelessWidget {
  const JourneyMapScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const JourneyMapScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<PathController>();
    final pl = PathL10n(context.watch<LocaleController>().lang);
    final theme = Theme.of(context).textTheme;

    final phases = <_Phase>[
      _Phase('gate', Icons.flag_outlined, done: true, unlocked: true),
      _Phase(
        'orient',
        Icons.visibility_outlined,
        done: path.orientStep >= 3,
        unlocked: true,
      ),
      _Phase(
        'missions',
        Icons.explore_outlined,
        done: path.missionsDone,
        unlocked: path.orientStep >= 3,
        metric: pl.jmMetric(
          'missions',
          a: path.literacyStep.clamp(0, 4),
          b: 4,
        ),
      ),
      _Phase(
        'p2',
        Icons.local_fire_department_outlined,
        done: path.p2BridgeSeen,
        unlocked: path.missionsDone,
      ),
      _Phase(
        'glossary',
        Icons.menu_book_outlined,
        done: path.glossaryTourSeen,
        unlocked: path.p2BridgeSeen,
        metric: pl.jmMetric('glossary', a: path.hitsOpened.clamp(0, 3), b: 3),
      ),
      _Phase(
        'club',
        Icons.forum_outlined,
        done: path.clubBridgeSeen,
        unlocked: path.p2BridgeSeen,
        metric: pl.jmMetric('club', a: path.habitDays.clamp(0, 3), b: 3),
      ),
      _Phase(
        'academy',
        Icons.school_outlined,
        done: path.academyBridgeSeen,
        unlocked: path.p2BridgeSeen,
        metric: pl.jmMetric('academy', a: path.habitDays.clamp(0, 7), b: 7),
      ),
    ];

    return Scaffold(
      backgroundColor: SrColors.bg,
      appBar: AppBar(title: Text(pl.jmTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(pl.jmSub, style: theme.bodyMedium),
          const SizedBox(height: 20),
          for (var i = 0; i < phases.length; i++)
            _PhaseRow(
              phase: phases[i],
              pl: pl,
              isLast: i == phases.length - 1,
              // First not-done phase among the sequential ones is "now".
              status: _statusFor(phases, i),
            ),
          const SizedBox(height: 8),
          Text(pl.eduFooter, style: theme.bodySmall),
        ],
      ),
    );
  }

  static _Status _statusFor(List<_Phase> phases, int i) {
    final p = phases[i];
    if (p.done) return _Status.done;
    if (!p.unlocked) return _Status.next;
    return _Status.now;
  }
}

enum _Status { done, now, next }

class _Phase {
  const _Phase(
    this.id,
    this.icon, {
    required this.done,
    required this.unlocked,
    this.metric,
  });
  final String id;
  final IconData icon;
  final bool done;
  final bool unlocked;
  final String? metric;
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({
    required this.phase,
    required this.pl,
    required this.isLast,
    required this.status,
  });

  final _Phase phase;
  final PathL10n pl;
  final bool isLast;
  final _Status status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final color = switch (status) {
      _Status.done => SrColors.bull,
      _Status.now => SrColors.accent,
      _Status.next => SrColors.faint,
    };
    final label = switch (status) {
      _Status.done => pl.jmDone,
      _Status.now => pl.jmNow,
      _Status.next => pl.jmNext,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(
                      alpha: status == _Status.now ? 0.2 : 0.1,
                    ),
                    border: Border.all(color: color.withValues(alpha: 0.7)),
                  ),
                  child: Icon(
                    status == _Status.done ? Icons.check : phase.icon,
                    size: 20,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: status == _Status.done
                          ? SrColors.bull.withValues(alpha: 0.5)
                          : SrColors.line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pl.jmPhaseTitle(phase.id),
                          style: theme.titleMedium?.copyWith(
                            color: status == _Status.next
                                ? SrColors.muted
                                : SrColors.text,
                          ),
                        ),
                      ),
                      PathChip(label: label, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(pl.jmPhaseBody(phase.id), style: theme.bodyMedium),
                  if (phase.metric != null && status != _Status.done) ...[
                    const SizedBox(height: 6),
                    Text(
                      phase.metric!,
                      style: theme.labelMedium?.copyWith(color: color),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
