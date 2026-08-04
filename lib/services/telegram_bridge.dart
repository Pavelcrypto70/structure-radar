import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'alert_profile_store.dart';

/// Telegram delivery is not live yet — this bridge prepares deep links,
/// message templates, and an on-device outbound queue for a future bot worker.
class TelegramBridge {
  TelegramBridge(this._store);

  final AlertProfileStore _store;
  final _uuid = const Uuid();

  /// Placeholder bot username until production bot is provisioned.
  static const botUsername = 'StructureRadarBot';

  /// EN portfolio community (separate from alert bot).
  static const communityHubUrl = 'https://t.me/Desk_Club';
  static const communityHubHandle = '@Desk_Club';

  static Uri communityHubUri() => Uri.parse(communityHubUrl);

  Uri deepLink(AlertProfile profile) {
    return Uri.parse('https://t.me/$botUsername?start=${profile.linkCode}');
  }

  String formatDetectionMessage(Detection d) {
    final bias = switch (d.bias) {
      StructureBias.bullish => 'BULLISH',
      StructureBias.bearish => 'BEARISH',
      StructureBias.neutral => 'NEUTRAL',
    };
    return [
      'Structure Radar · ${d.kind.short}',
      '${d.symbol.display} · ${d.exchange.label} · ${d.timeframe.label}',
      d.title,
      'Bias: $bias · Score: ${d.score.toStringAsFixed(0)}',
      d.summary,
      '',
      'Educational heuristic only. Not financial advice.',
    ].join('\n');
  }

  Map<String, dynamic> detectionPayload(Detection d, AlertProfile profile) {
    return {
      'schema': 'structure_radar.detection_alert.v1',
      'linkCode': profile.linkCode,
      'detection': {
        'id': d.id,
        'kind': d.kind.name,
        'exchange': d.exchange.name,
        'symbol': d.symbol.id,
        'timeframe': d.timeframe.name,
        'title': d.title,
        'summary': d.summary,
        'score': d.score,
        'bias': d.bias.name,
        'tags': d.tags,
        'price': d.price,
        'level': d.level == null
            ? null
            : {
                'price': d.level!.price,
                'side': d.level!.side.name,
                'touches': d.level!.touches,
                'strength': d.level!.strength,
              },
        'detectedAt': d.detectedAt.toIso8601String(),
      },
      'message': formatDetectionMessage(d),
      'delivery': {
        'channel': 'telegram',
        'status': profile.telegramOptIn ? 'queued_local' : 'suppressed_opt_out',
      },
    };
  }

  bool matchesProfile(Detection d, AlertProfile profile) {
    if (!profile.enabledDetectors.contains(d.kind)) return false;
    if (!profile.timeframes.contains(d.timeframe)) return false;
    if (!profile.exchanges.contains(d.exchange)) return false;
    if (d.score < profile.minScore) return false;
    if (!_inQuietHours(profile)) return true;
    return false;
  }

  bool _inQuietHours(AlertProfile profile) {
    final start = profile.quietHoursStart;
    final end = profile.quietHoursEnd;
    if (start == null || end == null) return false;
    final hour = DateTime.now().hour;
    if (start == end) return false;
    if (start < end) return hour >= start && hour < end;
    return hour >= start || hour < end;
  }

  /// Enqueue locally. A future worker will drain this to Bot API.
  Future<OutboundAlertEvent?> queueIfArmed(
    Detection detection,
    AlertProfile profile,
  ) async {
    if (!profile.telegramOptIn) return null;
    if (!matchesProfile(detection, profile)) return null;

    final event = OutboundAlertEvent(
      id: _uuid.v4(),
      createdAt: DateTime.now().toUtc(),
      detectionId: detection.id,
      profileLinkCode: profile.linkCode,
      message: formatDetectionMessage(detection),
      payload: detectionPayload(detection, profile),
    );
    await _store.enqueue(event);
    return event;
  }
}
