import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models.dart';
import '../../services/telegram_bridge.dart';
import '../../state/scan_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/detection_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ScanController>();
    final p = c.profile;
    if (p == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          Text('Alert profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Configure which detections should fan out to Telegram later. '
            'Delivery is prepared on-device; the bot is not connected yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Telegram bridge', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Arm Telegram delivery'),
                  subtitle: const Text(
                    'When enabled, matching detections are queued locally for the future bot worker.',
                  ),
                  value: p.telegramOptIn,
                  activeColor: AppTokens.accent,
                  onChanged: (v) async {
                    await c.saveProfile(p.copyWith(telegramOptIn: v));
                  },
                ),
                const SizedBox(height: 8),
                Text('Link code', style: Theme.of(context).textTheme.bodySmall),
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
                            const SnackBar(content: Text('Link code copied')),
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
                    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open $uri')),
                      );
                    }
                  },
                  icon: const Icon(Icons.telegram, color: AppTokens.accent),
                  label: const Text('Open bot deep link (prep)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.textPrimary,
                    side: const BorderSide(color: AppTokens.stroke),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bot username placeholder: @${TelegramBridge.botUsername}. '
                  'Deep link opens Telegram; linking will activate after backend wiring.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Detectors for alerts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            children: DetectorKind.values.map((e) {
              final on = p.enabledDetectors.contains(e);
              return FilterChipToggle(
                label: e.label,
                selected: on,
                onTap: () async {
                  final next = {...p.enabledDetectors};
                  on ? next.remove(e) : next.add(e);
                  await c.saveProfile(p.copyWith(enabledDetectors: next));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text('Timeframes for alerts', style: Theme.of(context).textTheme.titleMedium),
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
          const SizedBox(height: 8),
          Text('Exchanges for alerts', style: Theme.of(context).textTheme.titleMedium),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Alert min score', style: Theme.of(context).textTheme.titleMedium),
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
            activeColor: AppTokens.accent,
            onChanged: (v) async {
              await c.saveProfile(p.copyWith(minScore: v));
            },
          ),
          const SizedBox(height: 8),
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bridge payload preview', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  p.toTelegramBridgePayload().toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: AppTokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder(
            future: c.store.loadQueue(),
            builder: (context, snap) {
              final n = snap.data?.length ?? 0;
              return Text(
                'Outbound queue (local): $n event(s) waiting for bot worker.',
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTokens.strokeSoft),
      ),
      child: child,
    );
  }
}
