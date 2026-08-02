enum ExchangeId {
  binance,
  bybit,
  gate,
}

extension ExchangeIdX on ExchangeId {
  String get label => switch (this) {
        ExchangeId.binance => 'Binance',
        ExchangeId.bybit => 'Bybit',
        ExchangeId.gate => 'Gate.io',
      };

  String get short => switch (this) {
        ExchangeId.binance => 'BIN',
        ExchangeId.bybit => 'BYB',
        ExchangeId.gate => 'GATE',
      };
}

enum AppTimeframe {
  h1,
  h4,
  d1,
}

extension AppTimeframeX on AppTimeframe {
  String get label => switch (this) {
        AppTimeframe.h1 => '1H',
        AppTimeframe.h4 => '4H',
        AppTimeframe.d1 => '1D',
      };

  String get glossaryKey => switch (this) {
        AppTimeframe.h1 => 'tf_1h',
        AppTimeframe.h4 => 'tf_4h',
        AppTimeframe.d1 => 'tf_1d',
      };

  Duration get barDuration => switch (this) {
        AppTimeframe.h1 => const Duration(hours: 1),
        AppTimeframe.h4 => const Duration(hours: 4),
        AppTimeframe.d1 => const Duration(days: 1),
      };
}

enum DetectorKind {
  structureShift,
  maRegime,
  levels,
}

extension DetectorKindX on DetectorKind {
  String get label => switch (this) {
        DetectorKind.structureShift => 'Structure Shift',
        DetectorKind.maRegime => 'MA Regime',
        DetectorKind.levels => 'Support / Resistance',
      };

  String get short => switch (this) {
        DetectorKind.structureShift => 'STRUCTURE',
        DetectorKind.maRegime => 'MA REGIME',
        DetectorKind.levels => 'LEVELS',
      };

  String get glossaryKey => switch (this) {
        DetectorKind.structureShift => 'det_structure',
        DetectorKind.maRegime => 'det_ma',
        DetectorKind.levels => 'det_levels',
      };
}

enum StructureBias {
  bullish,
  bearish,
  neutral,
}

enum LevelSide {
  support,
  resistance,
}

class Candle {
  const Candle({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  bool get isBullish => close >= open;
}

class MarketSymbol {
  const MarketSymbol({
    required this.id,
    required this.base,
    required this.quote,
    required this.display,
    this.alsoListedOn = const [],
    this.quoteVolume24h = 0,
  });

  /// Canonical id, e.g. BTCUSDT
  final String id;
  final String base;
  final String quote;
  final String display;

  /// Other venues that also list this base/USDT (not scanned — annotation only).
  final List<ExchangeId> alsoListedOn;
  final double quoteVolume24h;

  String alsoOnLabel({required bool ru}) {
    if (alsoListedOn.isEmpty) return '';
    final names = alsoListedOn.map((e) => e.label).join(', ');
    return ru ? 'Также на: $names' : 'Also on: $names';
  }

  MarketSymbol copyWith({
    List<ExchangeId>? alsoListedOn,
    double? quoteVolume24h,
  }) {
    return MarketSymbol(
      id: id,
      base: base,
      quote: quote,
      display: display,
      alsoListedOn: alsoListedOn ?? this.alsoListedOn,
      quoteVolume24h: quoteVolume24h ?? this.quoteVolume24h,
    );
  }
}

enum LevelPattern {
  horizontal,
  ascendingTriangle,
  descendingTriangle,
}

class LevelZone {
  const LevelZone({
    required this.price,
    required this.side,
    required this.touches,
    required this.strength,
    this.touchIndexes = const [],
    this.pattern = LevelPattern.horizontal,
    this.trendStartIndex,
    this.trendStartPrice,
    this.trendEndIndex,
    this.trendEndPrice,
  });

  final double price;
  final LevelSide side;
  final int touches;
  final double strength;

  /// Candle indexes of confirmed touches (full series).
  final List<int> touchIndexes;
  final LevelPattern pattern;

  /// Optional diagonal (triangle) endpoints in full-series indexes.
  final int? trendStartIndex;
  final double? trendStartPrice;
  final int? trendEndIndex;
  final double? trendEndPrice;
}

class Detection {
  const Detection({
    required this.id,
    required this.kind,
    required this.exchange,
    required this.symbol,
    required this.timeframe,
    required this.title,
    required this.summary,
    required this.score,
    required this.detectedAt,
    required this.bias,
    required this.candles,
    this.price,
    this.level,
    this.tags = const [],
    this.detailBullets = const [],
  });

  final String id;
  final DetectorKind kind;
  final ExchangeId exchange;
  final MarketSymbol symbol;
  final AppTimeframe timeframe;
  final String title;
  final String summary;
  final double score;
  final DateTime detectedAt;
  final StructureBias bias;
  final List<Candle> candles;
  final double? price;
  final LevelZone? level;
  final List<String> tags;
  final List<String> detailBullets;
}

class ScanRequest {
  const ScanRequest({
    required this.exchanges,
    required this.timeframes,
    required this.detectors,
    required this.minScore,
  });

  final Set<ExchangeId> exchanges;
  final Set<AppTimeframe> timeframes;
  final Set<DetectorKind> detectors;
  final double minScore;
}

class ScanProgress {
  const ScanProgress({
    required this.done,
    required this.total,
    required this.label,
  });

  final int done;
  final int total;
  final String label;

  double get fraction => total == 0 ? 0 : done / total;
}

/// Settings that will drive Telegram delivery later.
class AlertProfile {
  const AlertProfile({
    required this.enabledDetectors,
    required this.timeframes,
    required this.exchanges,
    required this.minScore,
    required this.telegramOptIn,
    required this.linkCode,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.displayName = 'Primary',
  });

  final String displayName;
  final Set<DetectorKind> enabledDetectors;
  final Set<AppTimeframe> timeframes;
  final Set<ExchangeId> exchanges;
  final double minScore;
  final bool telegramOptIn;
  final String linkCode;
  final int? quietHoursStart;
  final int? quietHoursEnd;

  static AlertProfile defaults(String linkCode) => AlertProfile(
        enabledDetectors: DetectorKind.values.toSet(),
        timeframes: AppTimeframe.values.toSet(),
        exchanges: ExchangeId.values.toSet(),
        minScore: 65,
        telegramOptIn: false,
        linkCode: linkCode,
      );

  AlertProfile copyWith({
    String? displayName,
    Set<DetectorKind>? enabledDetectors,
    Set<AppTimeframe>? timeframes,
    Set<ExchangeId>? exchanges,
    double? minScore,
    bool? telegramOptIn,
    String? linkCode,
    int? quietHoursStart,
    int? quietHoursEnd,
    bool clearQuietHours = false,
  }) {
    return AlertProfile(
      displayName: displayName ?? this.displayName,
      enabledDetectors: enabledDetectors ?? this.enabledDetectors,
      timeframes: timeframes ?? this.timeframes,
      exchanges: exchanges ?? this.exchanges,
      minScore: minScore ?? this.minScore,
      telegramOptIn: telegramOptIn ?? this.telegramOptIn,
      linkCode: linkCode ?? this.linkCode,
      quietHoursStart:
          clearQuietHours ? null : (quietHoursStart ?? this.quietHoursStart),
      quietHoursEnd:
          clearQuietHours ? null : (quietHoursEnd ?? this.quietHoursEnd),
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'enabledDetectors': enabledDetectors.map((e) => e.name).toList(),
        'timeframes': timeframes.map((e) => e.name).toList(),
        'exchanges': exchanges.map((e) => e.name).toList(),
        'minScore': minScore,
        'telegramOptIn': telegramOptIn,
        'linkCode': linkCode,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
      };

  factory AlertProfile.fromJson(Map<String, dynamic> json) {
    T parseEnum<T extends Enum>(List<T> values, String name, T fallback) {
      return values.firstWhere(
        (e) => e.name == name,
        orElse: () => fallback,
      );
    }

    final detectors = (json['enabledDetectors'] as List? ?? [])
        .map((e) => parseEnum(DetectorKind.values, '$e', DetectorKind.structureShift))
        .toSet();
    final tfs = (json['timeframes'] as List? ?? [])
        .map((e) => parseEnum(AppTimeframe.values, '$e', AppTimeframe.h4))
        .toSet();
    final exs = (json['exchanges'] as List? ?? [])
        .map((e) => '$e')
        .where((name) => ExchangeId.values.any((v) => v.name == name))
        .map((name) => parseEnum(ExchangeId.values, name, ExchangeId.binance))
        .toSet();

    return AlertProfile(
      displayName: json['displayName'] as String? ?? 'Primary',
      enabledDetectors:
          detectors.isEmpty ? DetectorKind.values.toSet() : detectors,
      timeframes: tfs.isEmpty ? AppTimeframe.values.toSet() : tfs,
      exchanges: exs.isEmpty ? ExchangeId.values.toSet() : exs,
      minScore: (json['minScore'] as num?)?.toDouble() ?? 65,
      telegramOptIn: json['telegramOptIn'] as bool? ?? false,
      linkCode: json['linkCode'] as String? ?? 'PENDING',
      quietHoursStart: json['quietHoursStart'] as int?,
      quietHoursEnd: json['quietHoursEnd'] as int?,
    );
  }

  /// Payload shape reserved for the future Telegram worker.
  Map<String, dynamic> toTelegramBridgePayload() => {
        'schema': 'structure_radar.alert_profile.v1',
        'profile': toJson(),
        'delivery': {
          'channel': 'telegram',
          'status': telegramOptIn ? 'armed_local' : 'disabled',
          'note':
              'Bot delivery is prepared in-app; outbound Telegram send is not live yet.',
        },
      };
}

/// Queued alert event ready for a future bot worker.
class OutboundAlertEvent {
  const OutboundAlertEvent({
    required this.id,
    required this.createdAt,
    required this.detectionId,
    required this.profileLinkCode,
    required this.message,
    required this.payload,
  });

  final String id;
  final DateTime createdAt;
  final String detectionId;
  final String profileLinkCode;
  final String message;
  final Map<String, dynamic> payload;
}
