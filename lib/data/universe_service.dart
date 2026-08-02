import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../domain/models.dart';
import 'exchanges/exchange_client.dart';
import 'exchanges/web_safe_http.dart';

/// Built scan universe: mid/small-cap USDT pairs, mega-caps excluded, cross-venue deduped.
class ScanUniverse {
  const ScanUniverse({
    required this.symbols,
    required this.excludedTopBases,
    required this.rawPairCount,
  });

  final List<UniverseEntry> symbols;
  final Set<String> excludedTopBases;
  final int rawPairCount;
}

class UniverseEntry {
  const UniverseEntry({
    required this.primaryExchange,
    required this.symbol,
  });

  final ExchangeId primaryExchange;
  final MarketSymbol symbol;
}

class UniverseService {
  UniverseService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  ScanUniverse? _cache;
  Set<ExchangeId>? _cacheExchanges;
  DateTime? _cacheAt;

  static const _cacheTtl = Duration(minutes: 20);

  /// Fallback if CoinGecko is unreachable (approx global top by market cap).
  static const fallbackTop15 = <String>{
    'BTC',
    'ETH',
    'USDT',
    'XRP',
    'BNB',
    'SOL',
    'USDC',
    'DOGE',
    'ADA',
    'TRX',
    'AVAX',
    'LINK',
    'TON',
    'DOT',
    'SHIB',
  };

  Future<ScanUniverse> build({
    required Set<ExchangeId> exchanges,
    required Map<ExchangeId, ExchangeClient> clients,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _cacheExchanges != null &&
        setEquals(_cacheExchanges, exchanges) &&
        _cacheAt != null &&
        now.difference(_cacheAt!) < _cacheTtl) {
      return _cache!;
    }

    final top = await fetchTopMarketCapBases(15);
    final listings = <ExchangeId, List<MarketSymbol>>{};
    await Future.wait(exchanges.map((ex) async {
      final client = clients[ex];
      if (client == null) return;
      try {
        listings[ex] = await client.listUsdtSpotPairs();
      } catch (_) {
        listings[ex] = const [];
      }
    }));

    var raw = 0;
    // base -> exchange -> symbol
    final byBase = <String, Map<ExchangeId, MarketSymbol>>{};
    for (final ex in exchanges) {
      final pairs = listings[ex] ?? const [];
      raw += pairs.length;
      for (final s in pairs) {
        final base = s.base.toUpperCase();
        if (top.contains(base)) continue;
        byBase.putIfAbsent(base, () => {});
        byBase[base]![ex] = s;
      }
    }

    const priority = [ExchangeId.binance, ExchangeId.bybit, ExchangeId.gate];
    final entries = mergeListings(
      byBase: byBase,
      priority: priority,
    );

    final universe = ScanUniverse(
      symbols: entries,
      excludedTopBases: top,
      rawPairCount: raw,
    );
    _cache = universe;
    _cacheExchanges = {...exchanges};
    _cacheAt = now;
    return universe;
  }

  Future<Set<String>> fetchTopMarketCapBases(int n) async {
    try {
      final uri = webSafeUri(
        Uri.https('api.coingecko.com', '/api/v3/coins/markets', {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': '$n',
          'page': '1',
          'sparkline': 'false',
        }),
      );
      final res = await _http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return fallbackTop15;
      final list = jsonDecode(res.body) as List<dynamic>;
      final out = <String>{};
      for (final row in list) {
        final m = row as Map<String, dynamic>;
        final sym = '${m['symbol']}'.toUpperCase();
        if (sym.isNotEmpty) out.add(sym);
      }
      return out.isEmpty ? fallbackTop15 : out;
    } catch (_) {
      return fallbackTop15;
    }
  }

  /// Pure merge: one primary venue per base, others → alsoListedOn.
  static List<UniverseEntry> mergeListings({
    required Map<String, Map<ExchangeId, MarketSymbol>> byBase,
    required List<ExchangeId> priority,
  }) {
    final entries = <UniverseEntry>[];
    for (final entry in byBase.entries) {
      final venues = entry.value;
      ExchangeId? primary;
      for (final p in priority) {
        if (venues.containsKey(p)) {
          primary = p;
          break;
        }
      }
      primary ??= venues.keys.first;
      final sym = venues[primary]!;
      final others = venues.keys.where((e) => e != primary).toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      entries.add(
        UniverseEntry(
          primaryExchange: primary,
          symbol: sym.copyWith(alsoListedOn: others),
        ),
      );
    }
    entries.sort(
      (a, b) => b.symbol.quoteVolume24h.compareTo(a.symbol.quoteVolume24h),
    );
    return entries;
  }
}
