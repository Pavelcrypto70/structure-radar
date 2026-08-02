import '../domain/models.dart';

/// Legacy static list kept only as offline fallback for tests.
class SymbolUniverse {
  static const symbols = <MarketSymbol>[
    MarketSymbol(id: 'NEARUSDT', base: 'NEAR', quote: 'USDT', display: 'NEAR/USDT'),
    MarketSymbol(id: 'APTUSDT', base: 'APT', quote: 'USDT', display: 'APT/USDT'),
    MarketSymbol(id: 'ARBUSDT', base: 'ARB', quote: 'USDT', display: 'ARB/USDT'),
    MarketSymbol(id: 'OPUSDT', base: 'OP', quote: 'USDT', display: 'OP/USDT'),
    MarketSymbol(id: 'SUIUSDT', base: 'SUI', quote: 'USDT', display: 'SUI/USDT'),
    MarketSymbol(id: 'INJUSDT', base: 'INJ', quote: 'USDT', display: 'INJ/USDT'),
    MarketSymbol(id: 'FETUSDT', base: 'FET', quote: 'USDT', display: 'FET/USDT'),
    MarketSymbol(id: 'RENDERUSDT', base: 'RENDER', quote: 'USDT', display: 'RENDER/USDT'),
    MarketSymbol(id: 'PEPEUSDT', base: 'PEPE', quote: 'USDT', display: 'PEPE/USDT'),
    MarketSymbol(id: 'WIFUSDT', base: 'WIF', quote: 'USDT', display: 'WIF/USDT'),
  ];
}
