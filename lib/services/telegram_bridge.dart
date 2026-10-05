import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import 'alert_profile_store.dart';
import 'curated_broadcast.dart';

/// Telegram delivery is not live yet — this bridge prepares deep links,
/// message templates, and an on-device outbound queue for a future bot worker.
///
/// Anti-churn gates (client-side, before queue):
/// - profile filters + quiet hours
/// - dedupe same setup for [dedupeCooldown]
/// - daily cap [maxAlertsPerDay]
class TelegramBridge {
  TelegramBridge(this._store);

  final AlertProfileStore _store;
  final _uuid = const Uuid();

  /// Placeholder bot username until production bot is provisioned.
  static const botUsername = 'StructureRadarBot';

  /// EN portfolio community (separate from alert bot).
  static const communityHubUrl = 'https://t.me/Desk_Club';
  static const communityHubHandle = '@Desk_Club';
  static const communitySource = 'structure-radar';
  static const privacyUrl =
      'https://pavelcrypto70.github.io/structure-radar-privacy.html';
  static const termsUrl =
      'https://pavelcrypto70.github.io/structure-radar-terms.html';

  /// Same fingerprint cannot re-queue within this window.
  static const dedupeCooldown = Duration(hours: 6);

  /// Hard daily cap per device (UTC day) — spam kills opt-in retention.
  static const maxAlertsPerDay = 8;

  /// Public channel / «for everyone» curated queue (see [CuratedBroadcast]).
  static const maxBroadcastAlertsPerDay = CuratedBroadcast.maxBroadcastPerDay;

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

  Map<String, dynamic> detectionPayload(
    Detection d,
    AlertProfile profile, {
    String schema = 'structure_radar.detection_alert.v1',
    String deliveryChannel = 'telegram',
    String deliveryStatus = 'queued_local',
  }) {
    return {
      'schema': schema,
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
                'pattern': d.level!.pattern.name,
              },
        'detectedAt': d.detectedAt.toIso8601String(),
      },
      'message': formatDetectionMessage(d),
      'delivery': {
        'channel': deliveryChannel,
        'status': deliveryStatus,
      },
      'dedupeKey': dedupeKey(d),
      if (schema == 'structure_radar.broadcast_alert.v1')
        'broadcastMinScore': CuratedBroadcast.minScore,
    };
  }

  /// Fingerprint for cooldown: symbol · tf · kind · level bucket (or bias).
  String dedupeKey(Detection d) {
    final levelBucket = d.level == null
        ? d.bias.name
        : (d.level!.price).toStringAsFixed(d.level!.price >= 1 ? 2 : 5);
    return [
      d.symbol.id,
      d.exchange.name,
      d.timeframe.name,
      d.kind.name,
      levelBucket,
      if (d.level != null) d.level!.pattern.name,
    ].join('|');
  }

  bool matchesProfile(Detection d, AlertProfile profile) {
    if (!profile.enabledDetectors.contains(d.kind)) return false;
    if (!profile.timeframes.contains(d.timeframe)) return false;
    if (!profile.exchanges.contains(d.exchange)) return false;
    if (d.score < profile.minScore) return false;
    if (_inQuietHours(profile)) return false;
    return true;
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

  /// Enqueue locally after anti-spam gates. A future worker drains to Bot API.
  Future<OutboundAlertEvent?> queueIfArmed(
    Detection detection,
    AlertProfile profile,
  ) async {
    if (!profile.telegramOptIn) return null;
    if (!matchesProfile(detection, profile)) return null;

    final key = dedupeKey(detection);
    final now = DateTime.now().toUtc();
    final gate = await _store.loadAlertGate();
    if (gate.sentToday(now) >= maxAlertsPerDay) return null;
    if (gate.isDuplicate(key, now, dedupeCooldown)) return null;

    final event = OutboundAlertEvent(
      id: _uuid.v4(),
      createdAt: now,
      detectionId: detection.id,
      profileLinkCode: profile.linkCode,
      message: formatDetectionMessage(detection),
      payload: detectionPayload(detection, profile),
    );
    await _store.enqueue(event);
    await _store.saveAlertGate(gate.record(key, now));
    return event;
  }

  /// Curated 90+ for the shared bot — no personal opt-in; separate queue + caps.
  Future<OutboundAlertEvent?> queueCuratedBroadcast(Detection detection) async {
    if (!CuratedBroadcast.matches(detection)) return null;

    final key = dedupeKey(detection);
    final now = DateTime.now().toUtc();
    final gate = await _store.loadBroadcastGate();
    if (gate.sentToday(now) >= maxBroadcastAlertsPerDay) return null;
    if (gate.isDuplicate(key, now, CuratedBroadcast.dedupeCooldown)) {
      return null;
    }

    final stubProfile = AlertProfile.defaults(CuratedBroadcast.linkCode);
    final event = OutboundAlertEvent(
      id: _uuid.v4(),
      createdAt: now,
      detectionId: detection.id,
      profileLinkCode: CuratedBroadcast.linkCode,
      message: formatDetectionMessage(detection),
      payload: detectionPayload(
        detection,
        stubProfile,
        schema: 'structure_radar.broadcast_alert.v1',
        deliveryChannel: 'telegram_broadcast',
        deliveryStatus: 'queued_local',
      ),
    );
    await _store.enqueueBroadcast(event);
    await _store.saveBroadcastGate(gate.record(key, now));
    return event;
  }
}
