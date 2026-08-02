import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/glossary_l10n.dart';
import '../../state/locale_controller.dart';
import '../../theme/app_theme.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final t = locale.t;
    final entries = GlossaryLocalized.entries(locale.lang);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text(t.glossaryTitle, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(t.glossarySubtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          ...entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTokens.bgElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTokens.strokeSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e['title']!, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      e['subtitle']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTokens.accent,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(e['body']!, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    Text(t.howItWorks, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(e['mechanica']!, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    Text(t.limitations, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(e['limitations']!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
