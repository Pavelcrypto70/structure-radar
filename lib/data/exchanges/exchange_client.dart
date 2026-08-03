import '../../domain/models.dart';

abstract class ExchangeClient {
  ExchangeId get id;

  /// Returns newest-last candles. [limit] typical 200–300.
  Future<List<Candle>> fetchCandles({
    required MarketSymbol symbol,
    required AppTimeframe timeframe,
    int limit = 280,
  });

  /// Tradable spot */USDT pairs with 24h quote volume (USDT).
  Future<List<MarketSymbol>> listUsdtSpotPairs();
}

class ExchangeException implements Exception {
  ExchangeException(this.exchange, this.message);
  final ExchangeId exchange;
  final String message;

  @override
  String toString() => '${exchange.label}: $message';
}

String binanceInterval(AppTimeframe tf) => switch (tf) {
      AppTimeframe.m15 => '15m',
      AppTimeframe.m30 => '30m',
      AppTimeframe.h1 => '1h',
      AppTimeframe.h4 => '4h',
      AppTimeframe.d1 => '1d',
    };

String bybitInterval(AppTimeframe tf) => switch (tf) {
      AppTimeframe.m15 => '15',
      AppTimeframe.m30 => '30',
      AppTimeframe.h1 => '60',
      AppTimeframe.h4 => '240',
      AppTimeframe.d1 => 'D',
    };

String gateInterval(AppTimeframe tf) => switch (tf) {
      AppTimeframe.m15 => '15m',
      AppTimeframe.m30 => '30m',
      AppTimeframe.h1 => '1h',
      AppTimeframe.h4 => '4h',
      AppTimeframe.d1 => '1d',
    };
