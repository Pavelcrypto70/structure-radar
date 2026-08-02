import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models.dart';
import 'exchange_client.dart';
import 'web_safe_http.dart';

class BinanceClient implements ExchangeClient {
  BinanceClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  @override
  ExchangeId get id => ExchangeId.binance;

  @override
  Future<List<Candle>> fetchCandles({
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    int limit = 240,
  }) async {
    final uri = webSafeUri(Uri.https('api.binance.com', '/api/v3/klines', {
      'symbol': symbol.id,
      'interval': binanceInterval(timeframe),
      'limit': '$limit',
    }));
    final res = await _http.get(uri).timeout(const Duration(seconds: 25));
    if (res.statusCode != 200) {
      throw ExchangeException(id, 'HTTP ${res.statusCode}');
    }
    final raw = jsonDecode(res.body) as List<dynamic>;
    return raw.map((row) {
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
