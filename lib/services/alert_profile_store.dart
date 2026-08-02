import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';

class AlertProfileStore {
  static const _key = 'alert_profile_v1';
  static const _queueKey = 'outbound_alert_queue_v1';
  static const _disclaimerKey = 'disclaimer_accepted_v1';

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
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
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

  Future<void> enqueue(OutboundAlertEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadQueue();
    current.insert(0, event);
    final trimmed = current.take(100).toList();
    await prefs.setString(
      _queueKey,
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

  String _newLinkCode() {
    final id = const Uuid().v4().replaceAll('-', '');
    return 'SR${id.substring(0, 10).toUpperCase()}';
  }
}
