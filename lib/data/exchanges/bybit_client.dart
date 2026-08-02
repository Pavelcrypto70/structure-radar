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
  Future<List<Candle>> fetchCandles({
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    int limit = 240,
  }) async {
    final uri = webSafeUri(Uri.https('api.bybit.com', '/v5/market/kline', {
      'category': 'spot',
      'symbol': symbol.id,
      'interval': bybitInterval(timeframe),
      'limit': '$limit',
    }));
    final res = await _http.get(uri).timeout(const Duration(seconds: 25));
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
