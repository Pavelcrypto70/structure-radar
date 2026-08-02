import 'package:flutter/material.dart';

import '../../domain/glossary.dart';
import '../../theme/app_theme.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text('Glossary & mechanics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Full description of each detector, timeframe, scoring, and the Telegram alert profile.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ...AppGlossary.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTokens.bgElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTokens.strokeSoft),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      e.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTokens.accent,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(e.body, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    Text('How it works', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(e.mechanica, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 14),
                    Text('Limitations', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(e.limitations, style: Theme.of(context).textTheme.bodyMedium),
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
