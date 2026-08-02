import 'package:flutter/foundation.dart';

/// Browser-safe URL rewrite for exchange GETs.
///
/// Binance public market-data host sends `Access-Control-Allow-Origin: *`.
/// Never route Binance through free CORS relays (429 / geo-block / paid plans).
/// Gate still needs a relay; Bybit/CoinGecko work with browser Origin.
Uri webSafeUri(Uri target) {
  if (!kIsWeb) return target;

  if (target.host == 'api.binance.com' ||
      target.host == 'data.binance.com' ||
      target.host == 'fapi.binance.com') {
    // Spot market data only — never futures host from the web demo.
    return Uri(
      scheme: 'https',
      host: 'data-api.binance.vision',
      path: target.path.replaceFirst('/fapi/', '/api/'),
      queryParameters: target.queryParameters.isEmpty ? null : target.queryParameters,
    );
  }

  final host = target.host;
  if (host.contains('gateio') || host.contains('gate.com')) {
    // Prefer skipping Gate on web scans; if called, use allorigins (not corsproxy).
    return Uri.parse(
      'https://api.allorigins.win/raw?url=${Uri.encodeComponent(target.toString())}',
    );
  }

  return target;
}
