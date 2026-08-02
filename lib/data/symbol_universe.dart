import '../domain/models.dart';

/// Spot USDT pairs only — kept short to keep multi-exchange scans light.
class SymbolUniverse {
  static const symbols = <MarketSymbol>[
    MarketSymbol(id: 'BTCUSDT', base: 'BTC', quote: 'USDT', display: 'BTC/USDT'),
    MarketSymbol(id: 'ETHUSDT', base: 'ETH', quote: 'USDT', display: 'ETH/USDT'),
    MarketSymbol(id: 'SOLUSDT', base: 'SOL', quote: 'USDT', display: 'SOL/USDT'),
    MarketSymbol(id: 'XRPUSDT', base: 'XRP', quote: 'USDT', display: 'XRP/USDT'),
    MarketSymbol(id: 'BNBUSDT', base: 'BNB', quote: 'USDT', display: 'BNB/USDT'),
    MarketSymbol(id: 'DOGEUSDT', base: 'DOGE', quote: 'USDT', display: 'DOGE/USDT'),
    MarketSymbol(id: 'ADAUSDT', base: 'ADA', quote: 'USDT', display: 'ADA/USDT'),
    MarketSymbol(id: 'LINKUSDT', base: 'LINK', quote: 'USDT', display: 'LINK/USDT'),
    MarketSymbol(id: 'AVAXUSDT', base: 'AVAX', quote: 'USDT', display: 'AVAX/USDT'),
    MarketSymbol(id: 'TONUSDT', base: 'TON', quote: 'USDT', display: 'TON/USDT'),
  ];
}
