import 'package:flutter/material.dart';

import '../../l10n/app_lang.dart';
import '../../theme/tokens.dart';

/// First-run gate: no localized product UI is shown until a language is chosen.
class LanguageGateScreen extends StatelessWidget {
  const LanguageGateScreen({super.key, required this.onPick});

  final Future<void> Function(AppLang lang) onPick;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STRUCTURE RADAR · FREE #2',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: SrColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choose your language',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Elige tu idioma · Escolha seu idioma · Выберите язык',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: AppLang.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final lang = AppLang.values[index];
                    return _LanguageCard(lang: lang, onTap: () => onPick(lang));
                  },
                ),
              ),
              Text(
                'You can change language later in Profile.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.lang, required this.onTap});

  final AppLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (lang) {
      AppLang.en => 'English',
      AppLang.es => 'Latinoamérica · España',
      AppLang.pt => 'Brasil · Portugal',
      AppLang.ru => 'Русский',
    };
    return Material(
      color: SrColors.surface,
      borderRadius: BorderRadius.circular(SrRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SrRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SrRadius.lg),
            border: Border.all(color: SrColors.lineSoft),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.nativeLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: SrColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
