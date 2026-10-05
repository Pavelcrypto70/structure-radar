import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models.dart';
import '../../l10n/app_lang.dart';
import '../../l10n/path_l10n.dart';
import '../../services/telegram_bridge.dart';
import '../../state/locale_controller.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../path/journey_map.dart';
import '../path/path_kit.dart';
import '../widgets/detection_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final locale = context.watch<LocaleController>();
    final t = locale.t;
    final pl = PathL10n(locale.lang);
    final p = c.profile;
    if (p == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Text(
            t.alertProfile,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            t.alertProfileBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  children: AppLang.values
                      .map(
                        (lang) => FilterChipToggle(
                          label: lang.nativeLabel,
                          selected: locale.lang == lang,
                          onTap: () => locale.setLang(lang),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await locale.resetLanguageChoice();
                    await c.clearDisclaimerAccepted();
                  },
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: Text(
                    t.t(
                      'Choose language from start',
                      es: 'Elegir idioma desde el inicio',
                      pt: 'Escolher idioma desde o início',
                      ru: 'Выбрать язык с начала',
                    ),
                  ),
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
                Text(
                  pl.profileMapTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  pl.profileMapBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                PathButton(
                  label: pl.profileMapCta,
                  icon: Icons.map_outlined,
                  secondary: true,
                  onPressed: () => JourneyMapScreen.open(context),
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
                Text(
                  t.joinCommunity,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  t.joinCommunityBody,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    debugPrint(
                      'tg_cta_tap source=${TelegramBridge.communitySource}',
                    );
                    final uri = TelegramBridge.communityHubUri();
                    final ok = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open $uri')),
                      );
                    }
                  },
                  icon: const Icon(Icons.forum_outlined),
                  label: Text(t.openCommunity),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.accent,
                    foregroundColor: AppTokens.bg,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  TelegramBridge.communityHubHandle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTokens.accent),
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
                Text(
                  t.telegramBridge,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTokens.accent,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: p.linkCode),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(t.copied)));
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
                    final ok = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
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
          Text(
            t.detectorsForAlerts,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
          Text(
            t.timeframesForAlerts,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
          Text(
            t.exchangesForAlerts,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
              Text(
                t.alertMinScore,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                p.minScore.toStringAsFixed(0),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTokens.accent),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(t.alertMinScoreHint, style: Theme.of(context).textTheme.bodySmall),
          Slider(
            value: p.minScore.clamp(65, 90),
            min: 65,
            max: 90,
            divisions: 5,
            onChanged: (v) async {
              await c.saveProfile(p.copyWith(minScore: v));
            },
          ),
          const SizedBox(height: 12),
          Text(t.quietHours, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(t.quietHoursSub, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChipToggle(
                label: t.quietHoursOff,
                selected: p.quietHoursStart == null || p.quietHoursEnd == null,
                onTap: () async {
                  await c.saveProfile(p.copyWith(clearQuietHours: true));
                },
              ),
              FilterChipToggle(
                label: t.quietHoursRange(23, 8),
                selected: p.quietHoursStart == 23 && p.quietHoursEnd == 8,
                onTap: () async {
                  await c.saveProfile(
                    p.copyWith(quietHoursStart: 23, quietHoursEnd: 8),
                  );
                },
              ),
              FilterChipToggle(
                label: t.quietHoursRange(22, 7),
                selected: p.quietHoursStart == 22 && p.quietHoursEnd == 7,
                onTap: () async {
                  await c.saveProfile(
                    p.copyWith(quietHoursStart: 22, quietHoursEnd: 7),
                  );
                },
              ),
              FilterChipToggle(
                label: t.quietHoursRange(0, 6),
                selected: p.quietHoursStart == 0 && p.quietHoursEnd == 6,
                onTap: () async {
                  await c.saveProfile(
                    p.copyWith(quietHoursStart: 0, quietHoursEnd: 6),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(t.alertAntiSpam, style: Theme.of(context).textTheme.bodySmall),
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
