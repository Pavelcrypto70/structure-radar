import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_lang.dart';
import '../../theme/tokens.dart';
import 'sr_chrome.dart';

class FirstRunCoach {
  static const _key = 'first_run_done_v1';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> show(BuildContext context, L10n t) async {
    if (!await shouldShow()) return;
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: SrColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SrRadius.sheet)),
      ),
      builder: (_) => _FirstRunBody(t: t),
    );
    await markDone();
  }
}

class _FirstRunBody extends StatefulWidget {
  const _FirstRunBody({required this.t});
  final L10n t;

  @override
  State<_FirstRunBody> createState() => _FirstRunBodyState();
}

class _FirstRunBodyState extends State<_FirstRunBody> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final titles = [t.firstRunTitle1, t.firstRunTitle2, t.firstRunTitle3];
    final bodies = [t.firstRunBody1, t.firstRunBody2, t.firstRunBody3];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SrColors.line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SrKicker('${t.firstRunKicker} · ${step + 1}/3'),
          const SizedBox(height: 10),
          Text(titles[step], style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(bodies[step], style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: i <= step ? SrColors.accent : SrColors.lineSoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                if (step < 2) {
                  setState(() => step++);
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(step < 2 ? t.firstRunNext : t.firstRunDone),
            ),
          ),
        ],
      ),
    );
  }
}
