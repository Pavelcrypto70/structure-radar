import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import 'curated_broadcast.dart';
import 'telegram_bridge.dart';

/// In-app inbox for curated 90+ setups (local scan + hosted feed merge).
class CuratedSignalsStore {
  static const _inboxKey = 'curated_inbox_v1';
  static const maxItems = 40;

  Future<List<CuratedInboxItem>> loadInbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_inboxKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CuratedInboxItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveInbox(List<CuratedInboxItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = items.take(maxItems).toList();
    await prefs.setString(
      _inboxKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  /// Merge [detections] from a finished scan; returns count of newly added rows.
  Future<int> mergeFromScan(
    List<Detection> detections,
    TelegramBridge bridge,
  ) async {
    final curated = detections.where(CuratedBroadcast.matches).toList();
    if (curated.isEmpty) return 0;

    var inbox = await loadInbox();
    var added = 0;
    for (final d in curated) {
      final key = bridge.dedupeKey(d);
      if (inbox.any((e) => e.dedupeKey == key)) continue;
      inbox.insert(
        0,
        CuratedInboxItem(
          dedupeKey: key,
          source: CuratedSignalSource.localScan,
          fetchedAt: DateTime.now().toUtc(),
          read: false,
          snapshot: DetectionSnapshot.fromDetection(d),
        ),
      );
      added++;
    }
    if (added > 0) {
      await saveInbox(inbox);
    }
    return added;
  }

  Future<int> mergeFromFeedItems(List<DetectionSnapshot> snapshots) async {
    if (snapshots.isEmpty) return 0;
    var inbox = await loadInbox();
    var added = 0;
    for (final snap in snapshots) {
      final d = snap.toDetection();
      if (!CuratedBroadcast.matches(d)) continue;
      final key = _dedupeKeyFromSnapshot(snap);
      final existing = inbox.indexWhere((e) => e.dedupeKey == key);
      if (existing >= 0) {
        final prev = inbox[existing];
        if (snap.detectedAt.isAfter(prev.snapshot.detectedAt)) {
          inbox[existing] = prev.copyWith(
            snapshot: snap,
            fetchedAt: DateTime.now().toUtc(),
            source: CuratedSignalSource.hostedFeed,
          );
        }
        continue;
      }
      inbox.insert(
        0,
        CuratedInboxItem(
          dedupeKey: key,
          source: CuratedSignalSource.hostedFeed,
          fetchedAt: DateTime.now().toUtc(),
          read: false,
          snapshot: snap,
        ),
      );
      added++;
    }
    if (added > 0) {
      await saveInbox(inbox);
    }
    return added;
  }

  Future<void> markRead(String dedupeKey) async {
    final inbox = await loadInbox();
    final i = inbox.indexWhere((e) => e.dedupeKey == dedupeKey);
    if (i < 0) return;
    inbox[i] = inbox[i].copyWith(read: true);
    await saveInbox(inbox);
  }

  Future<void> markAllRead() async {
    final inbox = await loadInbox();
    await saveInbox([for (final e in inbox) e.copyWith(read: true)]);
  }

  static String _dedupeKeyFromSnapshot(DetectionSnapshot snap) {
    final levelBucket = snap.levelPrice == null
        ? snap.bias.name
        : snap.levelPrice!.toStringAsFixed(snap.levelPrice! >= 1 ? 2 : 5);
    return [
      snap.symbolId,
      snap.exchange.name,
      snap.timeframe.name,
      snap.kind.name,
      levelBucket,
      if (snap.levelPattern != null) snap.levelPattern!.name,
    ].join('|');
  }
}

enum CuratedSignalSource { localScan, hostedFeed }

class CuratedInboxItem {
  const CuratedInboxItem({
    required this.dedupeKey,
    required this.source,
    required this.fetchedAt,
    required this.read,
    required this.snapshot,
  });

  final String dedupeKey;
  final CuratedSignalSource source;
  final DateTime fetchedAt;
  final bool read;
  final DetectionSnapshot snapshot;

  CuratedInboxItem copyWith({
    bool? read,
    DetectionSnapshot? snapshot,
    CuratedSignalSource? source,
    DateTime? fetchedAt,
  }) {
    return CuratedInboxItem(
      dedupeKey: dedupeKey,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      read: read ?? this.read,
      snapshot: snapshot ?? this.snapshot,
    );
  }

  Map<String, dynamic> toJson() => {
        'dedupeKey': dedupeKey,
        'source': source.name,
        'fetchedAt': fetchedAt.toIso8601String(),
        'read': read,
        'snapshot': snapshot.toJson(),
      };

  factory CuratedInboxItem.fromJson(Map<String, dynamic> json) {
    return CuratedInboxItem(
      dedupeKey: json['dedupeKey'] as String,
      source: CuratedSignalSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => CuratedSignalSource.hostedFeed,
      ),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String).toUtc(),
      read: json['read'] as bool? ?? false,
      snapshot: DetectionSnapshot.fromJson(
        Map<String, dynamic>.from(json['snapshot'] as Map),
      ),
    );
  }
}

/// JSON-safe detection for inbox + hosted feed (candles loaded on detail open).
class DetectionSnapshot {
  const DetectionSnapshot({
    required this.id,
    required this.kind,
    required this.exchange,
    required this.symbolId,
    required this.symbolBase,
    required this.symbolDisplay,
    required this.timeframe,
    required this.title,
    required this.summary,
    required this.score,
    required this.detectedAt,
    required this.bias,
    this.price,
    this.levelPrice,
    this.levelSide,
    this.levelTouches,
    this.levelPattern,
    this.tags = const [],
    this.detailBullets = const [],
    this.alsoListedOn = const [],
  });

  final String id;
  final DetectorKind kind;
  final ExchangeId exchange;
  final String symbolId;
  final String symbolBase;
  final String symbolDisplay;
  final AppTimeframe timeframe;
  final String title;
  final String summary;
  final double score;
  final DateTime detectedAt;
  final StructureBias bias;
  final double? price;
  final double? levelPrice;
  final LevelSide? levelSide;
  final int? levelTouches;
  final LevelPattern? levelPattern;
  final List<String> tags;
  final List<String> detailBullets;
  final List<ExchangeId> alsoListedOn;

  factory DetectionSnapshot.fromDetection(Detection d) {
    return DetectionSnapshot(
      id: d.id,
      kind: d.kind,
      exchange: d.exchange,
      symbolId: d.symbol.id,
      symbolBase: d.symbol.base,
      symbolDisplay: d.symbol.display,
      timeframe: d.timeframe,
      title: d.title,
      summary: d.summary,
      score: d.score,
      detectedAt: d.detectedAt,
      bias: d.bias,
      price: d.price,
      levelPrice: d.level?.price,
      levelSide: d.level?.side,
      levelTouches: d.level?.touches,
      levelPattern: d.level?.pattern,
      tags: d.tags,
      detailBullets: d.detailBullets,
      alsoListedOn: d.symbol.alsoListedOn,
    );
  }

  Detection toDetection() {
    LevelZone? level;
    if (levelPrice != null && levelSide != null && levelTouches != null) {
      level = LevelZone(
        price: levelPrice!,
        side: levelSide!,
        touches: levelTouches!,
        strength: score,
        pattern: levelPattern ?? LevelPattern.horizontal,
      );
    }
    return Detection(
      id: id,
      kind: kind,
      exchange: exchange,
      symbol: MarketSymbol(
        id: symbolId,
        base: symbolBase,
        quote: 'USDT',
        display: symbolDisplay,
        alsoListedOn: alsoListedOn,
      ),
      timeframe: timeframe,
      title: title,
      summary: summary,
      score: score,
      detectedAt: detectedAt,
      bias: bias,
      candles: const [],
      price: price,
      level: level,
      tags: tags,
      detailBullets: detailBullets,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'exchange': exchange.name,
        'symbolId': symbolId,
        'symbolBase': symbolBase,
        'symbolDisplay': symbolDisplay,
        'timeframe': timeframe.name,
        'title': title,
        'summary': summary,
        'score': score,
        'detectedAt': detectedAt.toIso8601String(),
        'bias': bias.name,
        'price': price,
        'levelPrice': levelPrice,
        'levelSide': levelSide?.name,
        'levelTouches': levelTouches,
        'levelPattern': levelPattern?.name,
        'tags': tags,
        'detailBullets': detailBullets,
        'alsoListedOn': alsoListedOn.map((e) => e.name).toList(),
      };

  factory DetectionSnapshot.fromJson(Map<String, dynamic> json) {
    T enumOf<T extends Enum>(List<T> values, String? name, T fallback) {
      return values.firstWhere((e) => e.name == name, orElse: () => fallback);
    }

    final also = (json['alsoListedOn'] as List? ?? [])
        .map((e) => enumOf(ExchangeId.values, '$e', ExchangeId.binance))
        .toList();

    return DetectionSnapshot(
      id: json['id'] as String? ?? '',
      kind: enumOf(
        DetectorKind.values,
        json['kind'] as String?,
        DetectorKind.structureShift,
      ),
      exchange: enumOf(
        ExchangeId.values,
        json['exchange'] as String?,
        ExchangeId.binance,
      ),
      symbolId: json['symbolId'] as String? ?? 'BTCUSDT',
      symbolBase: json['symbolBase'] as String? ?? 'BTC',
      symbolDisplay: json['symbolDisplay'] as String? ?? 'BTC',
      timeframe: enumOf(
        AppTimeframe.values,
        json['timeframe'] as String?,
        AppTimeframe.h4,
      ),
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      detectedAt: DateTime.parse(
        json['detectedAt'] as String? ?? DateTime.now().toIso8601String(),
      ).toUtc(),
      bias: enumOf(
        StructureBias.values,
        json['bias'] as String?,
        StructureBias.neutral,
      ),
      price: (json['price'] as num?)?.toDouble(),
      levelPrice: (json['levelPrice'] as num?)?.toDouble(),
      levelSide: json['levelSide'] == null
          ? null
          : enumOf(
              LevelSide.values,
              json['levelSide'] as String?,
              LevelSide.resistance,
            ),
      levelTouches: json['levelTouches'] as int?,
      levelPattern: json['levelPattern'] == null
          ? null
          : enumOf(
              LevelPattern.values,
              json['levelPattern'] as String?,
              LevelPattern.horizontal,
            ),
      tags: (json['tags'] as List? ?? []).map((e) => '$e').toList(),
      detailBullets:
          (json['detailBullets'] as List? ?? []).map((e) => '$e').toList(),
      alsoListedOn: also,
    );
  }

  /// Hosted feed item wrapper: `{ "detection": { ...snapshot fields } }`.
  factory DetectionSnapshot.fromFeedItem(Map<String, dynamic> json) {
    final inner = json['detection'] is Map
        ? Map<String, dynamic>.from(json['detection'] as Map)
        : json;
    return DetectionSnapshot.fromJson(inner);
  }
}
