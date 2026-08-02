import 'package:flutter_test/flutter_test.dart';
import 'package:structure_radar/data/universe_service.dart';
import 'package:structure_radar/domain/models.dart';

void main() {
  test('mergeListings keeps one primary and annotates alsoListedOn', () {
    final byBase = {
      'PEPE': {
        ExchangeId.binance: const MarketSymbol(
          id: 'PEPEUSDT',
          base: 'PEPE',
          quote: 'USDT',
          display: 'PEPE/USDT',
          quoteVolume24h: 9e6,
        ),
        ExchangeId.bybit: const MarketSymbol(
          id: 'PEPEUSDT',
          base: 'PEPE',
          quote: 'USDT',
          display: 'PEPE/USDT',
          quoteVolume24h: 4e6,
        ),
        ExchangeId.gate: const MarketSymbol(
          id: 'PEPEUSDT',
          base: 'PEPE',
          quote: 'USDT',
          display: 'PEPE/USDT',
          quoteVolume24h: 2e6,
        ),
      },
      'WIF': {
        ExchangeId.gate: const MarketSymbol(
          id: 'WIFUSDT',
          base: 'WIF',
          quote: 'USDT',
          display: 'WIF/USDT',
          quoteVolume24h: 1e6,
        ),
      },
    };

    final merged = UniverseService.mergeListings(
      byBase: byBase,
      priority: const [ExchangeId.binance, ExchangeId.bybit, ExchangeId.gate],
    );

    expect(merged.length, 2);
    final pepe = merged.firstWhere((e) => e.symbol.base == 'PEPE');
    expect(pepe.primaryExchange, ExchangeId.binance);
    expect(pepe.symbol.alsoListedOn, [ExchangeId.bybit, ExchangeId.gate]);
    expect(pepe.symbol.alsoOnLabel(ru: true), contains('Bybit'));
    expect(pepe.symbol.alsoOnLabel(ru: true), contains('Gate.io'));

    final wif = merged.firstWhere((e) => e.symbol.base == 'WIF');
    expect(wif.primaryExchange, ExchangeId.gate);
    expect(wif.symbol.alsoListedOn, isEmpty);
  });
}
