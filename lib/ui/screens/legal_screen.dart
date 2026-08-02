import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/disclaimers.dart';
import '../../state/locale_controller.dart';
import '../../theme/app_theme.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final t = locale.t;

    return Scaffold(
      backgroundColor: AppTokens.bg,
      appBar: AppBar(title: Text(t.legalTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text(t.legalHeading, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(
            AppDisclaimers.full(locale.lang),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
