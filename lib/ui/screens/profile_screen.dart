import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models.dart';
import '../../l10n/app_lang.dart';
import '../../services/telegram_bridge.dart';
import '../../state/locale_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/detection_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final locale = context.watch<LocaleController>();
    final t = locale.t;
    final p = c.profile;
    if (p == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Text(t.alertProfile, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(t.alertProfileBody, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.language, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    FilterChipToggle(
                      label: 'Русский',
                      selected: locale.lang == AppLang.ru,
                      onTap: () => locale.setLang(AppLang.ru),
                    ),
                    FilterChipToggle(
                      label: 'English',
                      selected: locale.lang == AppLang.en,
                      onTap: () => locale.setLang(AppLang.en),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.telegramBridge, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.armTelegram),
                  subtitle: Text(t.armTelegramSub),
                  value: p.telegramOptIn,
                  activeColor: AppTokens.accent,
                  onChanged: (v) async {
                    await c.saveProfile(p.copyWith(telegramOptIn: v));
                  },
                ),
                const SizedBox(height: 8),
                Text(t.linkCode, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        p.linkCode,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTokens.accent,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: p.linkCode));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.copied)),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final uri = c.bridge.deepLink(p);
                    final ok =
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open $uri')),
                      );
                    }
                  },
                  icon: const Icon(Icons.telegram, color: AppTokens.accent),
                  label: Text(t.openBotLink),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.textPrimary,
                    side: const BorderSide(color: AppTokens.stroke),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.botPlaceholder.replaceAll(
                    '@StructureRadarBot',
                    '@${TelegramBridge.botUsername}',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(t.detectorsForAlerts, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            children: DetectorKind.values.map((e) {
              final on = p.enabledDetectors.contains(e);
              return FilterChipToggle(
                label: t.detectorLabel(e.name),
                selected: on,
                onTap: () async {
                  final next = {...p.enabledDetectors};
                  on ? next.remove(e) : next.add(e);
                  await c.saveProfile(p.copyWith(enabledDetectors: next));
                },
              );
            }).toList(),
          ),
          Text(t.timeframesForAlerts, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            children: AppTimeframe.values.map((e) {
              final on = p.timeframes.contains(e);
              return FilterChipToggle(
                label: e.label,
                selected: on,
                onTap: () async {
                  final next = {...p.timeframes};
                  on ? next.remove(e) : next.add(e);
                  await c.saveProfile(p.copyWith(timeframes: next));
                },
              );
            }).toList(),
          ),
          Text(t.exchangesForAlerts, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            children: ExchangeId.values.map((e) {
              final on = p.exchanges.contains(e);
              return FilterChipToggle(
                label: e.label,
                selected: on,
                onTap: () async {
                  final next = {...p.exchanges};
                  on ? next.remove(e) : next.add(e);
                  await c.saveProfile(p.copyWith(exchanges: next));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(t.alertMinScore, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                p.minScore.toStringAsFixed(0),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTokens.accent,
                    ),
              ),
            ],
          ),
          Slider(
            value: p.minScore,
            min: 50,
            max: 90,
            divisions: 8,
            onChanged: (v) async {
              await c.saveProfile(p.copyWith(minScore: v));
            },
          ),
          const SizedBox(height: 8),
          FutureBuilder(
            future: c.store.loadQueue(),
            builder: (context, snap) {
              final n = snap.data?.length ?? 0;
              return Text(
                t.outboundQueue(n),
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.bgElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTokens.strokeSoft),
      ),
      child: child,
    );
  }
}
