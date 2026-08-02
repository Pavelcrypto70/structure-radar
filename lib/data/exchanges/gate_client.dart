import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models.dart';
import 'exchange_client.dart';
import 'web_safe_http.dart';

class GateClient implements ExchangeClient {
  GateClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  @override
  ExchangeId get id => ExchangeId.gate;

  String _pair(MarketSymbol symbol) => '${symbol.base}_${symbol.quote}';

  @override
  Future<List<MarketSymbol>> listUsdtSpotPairs() async {
    final pairsUri = webSafeUri(Uri.https('api.gateio.ws', '/api/v4/spot/currency_pairs'));
    final tickUri = webSafeUri(Uri.https('api.gateio.ws', '/api/v4/spot/tickers'));
    final results = await Future.wait([
      _http.get(pairsUri).timeout(const Duration(seconds: 40)),
      _http.get(tickUri).timeout(const Duration(seconds: 40)),
    ]);
    for (final res in results) {
      if (res.statusCode != 200) {
        throw ExchangeException(id, 'HTTP ${res.statusCode}');
      }
    }

    final pairs = jsonDecode(results[0].body) as List<dynamic>;
    final tradable = <String, String>{}; // GATE_PAIR -> base
    for (final row in pairs) {
      final m = row as Map<String, dynamic>;
      if (m['quote'] != 'USDT') continue;
      if (m['trade_status'] != 'tradable') continue;
      final base = '${m['base']}';
      if (_junkBase(base)) continue;
      tradable['${m['id']}'] = base;
    }

    final ticks = jsonDecode(results[1].body) as List<dynamic>;
    final out = <MarketSymbol>[];
    for (final row in ticks) {
      final m = row as Map<String, dynamic>;
      final pairId = '${m['currency_pair']}';
      final base = tradable[pairId];
      if (base == null) continue;
      final quoteVol = double.tryParse('${m['quote_volume']}') ?? 0;
      if (quoteVol <= 0) continue;
      out.add(
        MarketSymbol(
          id: '${base}USDT',
          base: base,
          quote: 'USDT',
          display: '$base/USDT',
          quoteVolume24h: quoteVol,
        ),
      );
    }
    out.sort((a, b) => b.quoteVolume24h.compareTo(a.quoteVolume24h));
    return out;
  }

  @override
  Future<List<Candle>> fetchCandles({
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    int limit = 220,
  }) async {
    final uri = webSafeUri(Uri.https('api.gateio.ws', '/api/v4/spot/candlesticks', {
      'currency_pair': _pair(symbol),
      'interval': gateInterval(timeframe),
      'limit': '$limit',
    }));
    final res = await _http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw ExchangeException(id, 'HTTP ${res.statusCode}');
    }
    final raw = jsonDecode(res.body) as List<dynamic>;
    final candles = raw.map((row) {
      final r = row as List<dynamic>;
      final ts = int.parse('${r[0]}');
      return Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
        volume: double.parse('${r[1]}'),
        close: double.parse('${r[2]}'),
        high: double.parse('${r[3]}'),
        low: double.parse('${r[4]}'),
        open: double.parse('${r[5]}'),
      );
    }).toList();
    candles.sort((a, b) => a.openTime.compareTo(b.openTime));
    return candles;
  }
}

bool _junkBase(String base) {
  final u = base.toUpperCase();
  if (u.endsWith('UP') || u.endsWith('DOWN')) return true;
  if (u.endsWith('BULL') || u.endsWith('BEAR')) return true;
  if (RegExp(r'\d+[LS]$').hasMatch(u)) return true;
  return false;
}
