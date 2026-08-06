import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models.dart';
import 'exchanges/exchange_client.dart';
import 'exchanges/web_safe_http.dart';
import 'symbol_universe.dart';

/// Built scan universe: mid/small-cap USDT pairs, mega-caps excluded, cross-venue deduped.
class ScanUniverse {
  const ScanUniverse({
    required this.symbols,
    required this.excludedTopBases,
    required this.rawPairCount,
    this.source = 'exchanges',
  });

  final List<UniverseEntry> symbols;
  final Set<String> excludedTopBases;
  final int rawPairCount;
  final String source;
}

class UniverseEntry {
  const UniverseEntry({required this.primaryExchange, required this.symbol});

  final ExchangeId primaryExchange;
  final MarketSymbol symbol;
}

class UniverseService {
  UniverseService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  ScanUniverse? _cache;
  Set<ExchangeId>? _cacheExchanges;
  DateTime? _cacheAt;
  bool? _cacheLight;

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

  /// Pegs / FX / wrapped cash — not midcap trade setups.
  static const pegBases = <String>{
    'USDT',
    'USDC',
    'FDUSD',
    'TUSD',
    'USDE',
    'DAI',
    'USDP',
    'USDD',
    'USD1',
    'USDS',
    'EUR',
    'AEUR',
    'EURI',
    'BUSD',
    'XAUT',
    'PAXG',
  };

  Future<ScanUniverse> build({
    required Set<ExchangeId> exchanges,
    required Map<ExchangeId, ExchangeClient> clients,
    bool forceRefresh = false,
    bool lightweight = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _cacheExchanges != null &&
        _cacheLight == lightweight &&
        _sameSet(_cacheExchanges!, exchanges) &&
        _cacheAt != null &&
        now.difference(_cacheAt!) < _cacheTtl) {
      return _cache!;
    }

    ScanUniverse universe;
    if (lightweight) {
      universe = await _buildLightweight(exchanges);
    } else {
      universe = await _buildFromExchanges(exchanges, clients);
      if (universe.symbols.isEmpty) {
        universe = await _buildLightweight(exchanges);
      }
    }

    _cache = universe;
    _cacheExchanges = {...exchanges};
    _cacheAt = now;
    _cacheLight = lightweight;
    return universe;
  }

  Future<ScanUniverse> _buildFromExchanges(
    Set<ExchangeId> exchanges,
    Map<ExchangeId, ExchangeClient> clients,
  ) async {
    final top = await fetchTopMarketCapBases(15);
    final exclude = {...top, ...pegBases};
    final listings = <ExchangeId, List<MarketSymbol>>{};
    await Future.wait(
      exchanges.map((ex) async {
        final client = clients[ex];
        if (client == null) return;
        try {
          listings[ex] = await client.listUsdtSpotPairs();
        } catch (_) {
          listings[ex] = const [];
        }
      }),
    );

    var raw = 0;
    final byBase = <String, Map<ExchangeId, MarketSymbol>>{};
    for (final ex in exchanges) {
      final pairs = listings[ex] ?? const [];
      raw += pairs.length;
      for (final s in pairs) {
        final base = s.base.toUpperCase();
        if (exclude.contains(base)) continue;
        byBase.putIfAbsent(base, () => {});
        byBase[base]![ex] = s;
      }
    }

    const priority = [ExchangeId.binance, ExchangeId.bybit, ExchangeId.gate];
    final entries = mergeListings(byBase: byBase, priority: priority);
    return ScanUniverse(
      symbols: entries,
      excludedTopBases: top,
      rawPairCount: raw,
      source: 'exchanges',
    );
  }

  /// Web-safe path: CoinGecko midcap pages (small JSON) + static fallback.
  /// Avoids multi-MB Binance ticker payloads that break CORS relays.
  Future<ScanUniverse> _buildLightweight(Set<ExchangeId> exchanges) async {
    final top = await fetchTopMarketCapBases(15);
    final exclude = {...top, ...pegBases};
    final bases = <String>{};

    try {
      // Pages 1–2 ≈ top 500 by mcap; drop top-15 → mid/small.
      for (final page in [1, 2]) {
        final uri = webSafeUri(
          Uri.https('api.coingecko.com', '/api/v3/coins/markets', {
            'vs_currency': 'usd',
            'order': 'market_cap_desc',
            'per_page': '250',
            'page': '$page',
            'sparkline': 'false',
          }),
        );
        final res = await _http.get(uri).timeout(const Duration(seconds: 25));
        if (res.statusCode != 200) continue;
        final list = jsonDecode(res.body) as List<dynamic>;
        for (final row in list) {
          final m = row as Map<String, dynamic>;
          final sym = '${m['symbol']}'.toUpperCase();
          if (sym.isEmpty || exclude.contains(sym)) continue;
          if (sym.length > 12) continue;
          bases.add(sym);
        }
      }
    } catch (_) {
      // fall through to static
    }

    if (bases.isEmpty) {
      for (final s in SymbolUniverse.fallbackMidcaps) {
        if (!exclude.contains(s.base)) bases.add(s.base);
      }
    }

    // Prefer known liquid midcaps first so web's shortlist actually trades on Binance.
    final preferred = <String>[
      for (final s in SymbolUniverse.fallbackMidcaps)
        if (!exclude.contains(s.base)) s.base,
    ];
    final rest = bases.where((b) => !preferred.contains(b)).toList()..sort();
    final ordered = <String>[...preferred, ...rest];

    // Prefer Binance as primary when selected; else first selected venue.
    final primary = exchanges.contains(ExchangeId.binance)
        ? ExchangeId.binance
        : exchanges.first;
    final also = exchanges.where((e) => e != primary).toList();

    final entries = ordered.map((base) {
      return UniverseEntry(
        primaryExchange: primary,
        symbol: MarketSymbol(
          id: '${base}USDT',
          base: base,
          quote: 'USDT',
          display: '$base/USDT',
          alsoListedOn: also,
          quoteVolume24h: 0,
        ),
      );
    }).toList();

    return ScanUniverse(
      symbols: entries,
      excludedTopBases: top,
      rawPairCount: ordered.length,
      source: 'lightweight',
    );
  }

  static bool _sameSet(Set<ExchangeId> a, Set<ExchangeId> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
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
