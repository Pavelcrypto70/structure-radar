import 'dart:convert';

import 'package:http/http.dart' as http;

import 'curated_signals_store.dart';

/// Public curated feed (server scanner writes here; app merges on open + after scan).
class CuratedFeedClient {
  CuratedFeedClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const feedUrl =
      'https://pavelcrypto70.github.io/structure-radar/data/curated-signals.json';

  Future<List<DetectionSnapshot>> fetchSnapshots() async {
    try {
      final res = await _client
          .get(Uri.parse(feedUrl))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return [];
      final root = jsonDecode(res.body) as Map<String, dynamic>;
      final items = root['items'] as List? ?? [];
      return items
          .map(
            (e) => DetectionSnapshot.fromFeedItem(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
