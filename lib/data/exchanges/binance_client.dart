import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models.dart';
import 'exchange_client.dart';
import 'web_safe_http.dart';

class BinanceClient implements ExchangeClient {
  BinanceClient({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;

  @override
  ExchangeId get id => ExchangeId.binance;

  @override
  Future<List<MarketSymbol>> listUsdtSpotPairs() async {
    // Ticker alone is enough and much lighter than exchangeInfo+ticker (avoids 429).
    final tickUri = webSafeUri(
      Uri.https('api.binance.com', '/api/v3/ticker/24hr'),
    );
    final res = await _http.get(tickUri).timeout(const Duration(seconds: 40));
    if (res.statusCode != 200) {
      throw ExchangeException(id, 'HTTP ${res.statusCode}');
    }
    final tickers = jsonDecode(res.body) as List<dynamic>;
    final out = <MarketSymbol>[];
    for (final row in tickers) {
      final m = row as Map<String, dynamic>;
      final sym = '${m['symbol']}';
      if (!sym.endsWith('USDT')) continue;
      final base = sym.substring(0, sym.length - 4);
      if (_junkBase(base)) continue;
      final quoteVol = double.tryParse('${m['quoteVolume']}') ?? 0;
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
    int limit = 280,
  }) async {
    final uri = webSafeUri(
      Uri.https('api.binance.com', '/api/v3/klines', {
        'symbol': symbol.id,
        'interval': binanceInterval(timeframe),
        'limit': '$limit',
      }),
    );
    final res = await _http.get(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode == 429) {
      throw ExchangeException(id, 'HTTP 429 Too Many Requests');
    }
    if (res.statusCode != 200) {
      throw ExchangeException(id, 'HTTP ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw ExchangeException(id, 'Unexpected kline payload');
    }
    return decoded.map((row) {
      final r = row as List<dynamic>;
      return Candle(
        openTime: DateTime.fromMillisecondsSinceEpoch((r[0] as num).toInt()),
        open: double.parse('${r[1]}'),
        high: double.parse('${r[2]}'),
        low: double.parse('${r[3]}'),
        close: double.parse('${r[4]}'),
        volume: double.parse('${r[5]}'),
      );
    }).toList();
  }
}

bool _junkBase(String base) {
  final u = base.toUpperCase();
  if (u.endsWith('UP') || u.endsWith('DOWN')) return true;
  if (u.endsWith('BULL') || u.endsWith('BEAR')) return true;
  if (RegExp(r'\d+[LS]$').hasMatch(u)) return true;
  return false;
}
