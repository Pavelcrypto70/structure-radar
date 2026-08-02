import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models.dart';
import 'exchange_client.dart';
import 'web_safe_http.dart';

class BybitClient implements ExchangeClient {
  BybitClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  @override
  ExchangeId get id => ExchangeId.bybit;

  @override
  Future<List<MarketSymbol>> listUsdtSpotPairs() async {
    final infoUri = webSafeUri(Uri.https('api.bybit.com', '/v5/market/instruments-info', {
      'category': 'spot',
      'limit': '1000',
    }));
    final tickUri = webSafeUri(Uri.https('api.bybit.com', '/v5/market/tickers', {
      'category': 'spot',
    }));
    final results = await Future.wait([
      _http.get(infoUri).timeout(const Duration(seconds: 40)),
      _http.get(tickUri).timeout(const Duration(seconds: 40)),
    ]);
    for (final res in results) {
      if (res.statusCode != 200) {
        throw ExchangeException(id, 'HTTP ${res.statusCode}');
      }
    }

    final infoBody = jsonDecode(results[0].body) as Map<String, dynamic>;
    if ('${infoBody['retCode']}' != '0') {
      throw ExchangeException(id, '${infoBody['retMsg']}');
    }
    final list =
        (infoBody['result'] as Map<String, dynamic>)['list'] as List<dynamic>? ??
            [];
    final tradable = <String, String>{}; // symbol -> base
    for (final row in list) {
      final m = row as Map<String, dynamic>;
      if (m['status'] != 'Trading') continue;
      if (m['quoteCoin'] != 'USDT') continue;
      final base = '${m['baseCoin']}';
      if (_junkBase(base)) continue;
      tradable['${m['symbol']}'] = base;
    }

    // Bybit instruments-info is paginated; fetch remaining pages if needed.
    var next = (infoBody['result'] as Map<String, dynamic>)['nextPageCursor'];
    while (next != null && '$next'.isNotEmpty) {
      final pageUri = webSafeUri(Uri.https('api.bybit.com', '/v5/market/instruments-info', {
        'category': 'spot',
        'limit': '1000',
        'cursor': '$next',
      }));
      final pageRes = await _http.get(pageUri).timeout(const Duration(seconds: 40));
      if (pageRes.statusCode != 200) break;
      final pageBody = jsonDecode(pageRes.body) as Map<String, dynamic>;
      if ('${pageBody['retCode']}' != '0') break;
      final pageList =
          (pageBody['result'] as Map<String, dynamic>)['list'] as List<dynamic>? ??
              [];
      for (final row in pageList) {
        final m = row as Map<String, dynamic>;
        if (m['status'] != 'Trading') continue;
        if (m['quoteCoin'] != 'USDT') continue;
        final base = '${m['baseCoin']}';
        if (_junkBase(base)) continue;
        tradable['${m['symbol']}'] = base;
      }
      next = (pageBody['result'] as Map<String, dynamic>)['nextPageCursor'];
    }

    final tickBody = jsonDecode(results[1].body) as Map<String, dynamic>;
    if ('${tickBody['retCode']}' != '0') {
      throw ExchangeException(id, '${tickBody['retMsg']}');
    }
    final ticks =
        (tickBody['result'] as Map<String, dynamic>)['list'] as List<dynamic>? ??
            [];
    final out = <MarketSymbol>[];
    for (final row in ticks) {
      final m = row as Map<String, dynamic>;
      final sym = '${m['symbol']}';
      final base = tradable[sym];
      if (base == null) continue;
      final quoteVol = double.tryParse('${m['turnover24h']}') ?? 0;
      if (quoteVol <= 0) continue;
      out.add(
        MarketSymbol(
          id: sym,
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
    final uri = webSafeUri(Uri.https('api.bybit.com', '/v5/market/kline', {
      'category': 'spot',
      'symbol': symbol.id,
      'interval': bybitInterval(timeframe),
      'limit': '$limit',
    }));
    final res = await _http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw ExchangeException(id, 'HTTP ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if ('${body['retCode']}' != '0') {
      throw ExchangeException(id, '${body['retMsg']}');
    }
    final list =
        (body['result'] as Map<String, dynamic>)['list'] as List<dynamic>? ??
            [];
    final candles = list.map((row) {
      final r = row as List<dynamic>;
      return Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch(int.parse('${r[0]}')),
        open: double.parse('${r[1]}'),
        high: double.parse('${r[2]}'),
        low: double.parse('${r[3]}'),
        close: double.parse('${r[4]}'),
        volume: double.parse('${r[5]}'),
      );
    }).toList();
    return candles.reversed.toList();
  }
}

bool _junkBase(String base) {
  final u = base.toUpperCase();
  if (u.endsWith('UP') || u.endsWith('DOWN')) return true;
  if (u.endsWith('BULL') || u.endsWith('BEAR')) return true;
  if (RegExp(r'\d+[LS]$').hasMatch(u)) return true;
  return false;
}
