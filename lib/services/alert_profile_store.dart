import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';

class AlertProfileStore {
  static const _key = 'alert_profile_v1';
  static const _queueKey = 'outbound_alert_queue_v1';
  static const _broadcastQueueKey = 'outbound_broadcast_queue_v1';
  static const _disclaimerKey = 'disclaimer_accepted_v1';
  static const _gateKey = 'alert_gate_v1';
  static const _broadcastGateKey = 'broadcast_gate_v1';

  Future<AlertProfile> loadOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      return AlertProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    final profile = AlertProfile.defaults(_newLinkCode());
    await save(profile);
    return profile;
  }

  Future<void> save(AlertProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<bool> disclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerKey) ?? false;
  }

  Future<void> setDisclaimerAccepted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerKey, value);
  }

  Future<List<OutboundAlertEvent>> loadQueue() async {
    return _readQueue(await _rawQueue(_queueKey));
  }

  Future<void> enqueue(OutboundAlertEvent event) async {
    await _writeQueue(_queueKey, await loadQueue()..insert(0, event));
  }

  Future<List<OutboundAlertEvent>> loadBroadcastQueue() async {
    return _readQueue(await _rawQueue(_broadcastQueueKey));
  }

  Future<void> enqueueBroadcast(OutboundAlertEvent event) async {
    final current = await loadBroadcastQueue();
    current.insert(0, event);
    await _writeQueue(_broadcastQueueKey, current);
  }

  Future<String?> _rawQueue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  List<OutboundAlertEvent> _readQueue(String? raw) {
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return OutboundAlertEvent(
        id: m['id'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        detectionId: m['detectionId'] as String,
        profileLinkCode: m['profileLinkCode'] as String,
        message: m['message'] as String,
        payload: Map<String, dynamic>.from(m['payload'] as Map),
      );
    }).toList();
  }

  Future<void> _writeQueue(String key, List<OutboundAlertEvent> current) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = current.take(100).toList();
    await prefs.setString(
      key,
      jsonEncode(
        trimmed
            .map(
              (e) => {
                'id': e.id,
                'createdAt': e.createdAt.toIso8601String(),
                'detectionId': e.detectionId,
                'profileLinkCode': e.profileLinkCode,
                'message': e.message,
                'payload': e.payload,
              },
            )
            .toList(),
      ),
    );
  }

  Future<AlertGateState> loadAlertGate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_gateKey);
    if (raw == null) return AlertGateState.empty();
    try {
      return AlertGateState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return AlertGateState.empty();
    }
  }

  Future<void> saveAlertGate(AlertGateState gate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gateKey, jsonEncode(gate.toJson()));
  }

  Future<AlertGateState> loadBroadcastGate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_broadcastGateKey);
    if (raw == null) return AlertGateState.empty();
    try {
      return AlertGateState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return AlertGateState.empty();
    }
  }

  Future<void> saveBroadcastGate(AlertGateState gate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_broadcastGateKey, jsonEncode(gate.toJson()));
  }

  String _newLinkCode() {
    final id = const Uuid().v4().replaceAll('-', '');
    return 'SR${id.substring(0, 10).toUpperCase()}';
  }
}

/// Client-side anti-spam memory for the outbound alert queue.
class AlertGateState {
  AlertGateState({
    required this.dayStamp,
    required this.dayCount,
    required this.lastByKey,
  });

  final String dayStamp;
  final int dayCount;
  final Map<String, DateTime> lastByKey;

  factory AlertGateState.empty() => AlertGateState(
        dayStamp: _utcDay(DateTime.now().toUtc()),
        dayCount: 0,
        lastByKey: {},
      );

  factory AlertGateState.fromJson(Map<String, dynamic> json) {
    final raw = json['lastByKey'] as Map<String, dynamic>? ?? {};
    return AlertGateState(
      dayStamp: json['dayStamp'] as String? ?? '',
      dayCount: json['dayCount'] as int? ?? 0,
      lastByKey: {
        for (final e in raw.entries)
          e.key: DateTime.tryParse('${e.value}')?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'dayStamp': dayStamp,
        'dayCount': dayCount,
        'lastByKey': {
          for (final e in lastByKey.entries) e.key: e.value.toIso8601String(),
        },
      };

  int sentToday(DateTime nowUtc) {
    final day = _utcDay(nowUtc);
    if (day != dayStamp) return 0;
    return dayCount;
  }

  bool isDuplicate(String key, DateTime nowUtc, Duration cooldown) {
    final last = lastByKey[key];
    if (last == null) return false;
    return nowUtc.difference(last) < cooldown;
  }

  AlertGateState record(String key, DateTime nowUtc) {
    final day = _utcDay(nowUtc);
    final count = day == dayStamp ? dayCount + 1 : 1;
    final nextKeys = Map<String, DateTime>.from(lastByKey)..[key] = nowUtc;
    // Bound map size.
    if (nextKeys.length > 200) {
      final sorted = nextKeys.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      for (final e in sorted.take(nextKeys.length - 200)) {
        nextKeys.remove(e.key);
      }
    }
    return AlertGateState(
      dayStamp: day,
      dayCount: count,
      lastByKey: nextKeys,
    );
  }

  static String _utcDay(DateTime utc) =>
      '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';
}
