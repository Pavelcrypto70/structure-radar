import 'package:flutter/foundation.dart';

/// Browser-safe URL rewrite for exchange GETs.
///
/// Important: free CORS relays break Binance (geo-block / paid plans).
/// Binance public market-data host (`data-api.binance.vision`) already sends
/// `Access-Control-Allow-Origin: *`, so the browser can call it directly.
/// Bybit reflects Origin. CoinGecko allows *. Gate needs a relay.
Uri webSafeUri(Uri target) {
  if (!kIsWeb) return target;

  if (target.host == 'api.binance.com' || target.host == 'data.binance.com') {
    return target.replace(host: 'data-api.binance.vision');
  }

  final host = target.host;
  final needsRelay = host.contains('gateio') || host.contains('gate.com');
  if (!needsRelay) return target;

  return Uri.parse(
    'https://api.allorigins.win/raw?url=${Uri.encodeComponent(target.toString())}',
  );
}
