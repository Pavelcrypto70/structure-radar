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
  Future<List<Candle>> fetchCandles({
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    int limit = 240,
  }) async {
    final uri = webSafeUri(Uri.https('api.gateio.ws', '/api/v4/spot/candlesticks', {
      'currency_pair': _pair(symbol),
      'interval': gateInterval(timeframe),
      'limit': '$limit',
    }));
    final res = await _http.get(uri).timeout(const Duration(seconds: 25));
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
