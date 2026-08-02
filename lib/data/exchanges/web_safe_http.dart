import 'package:flutter/foundation.dart';

/// Exchange APIs block browser CORS. On web we route GET requests through a
/// public CORS relay so GitHub Pages demos can still fetch candles.
Uri webSafeUri(Uri target) {
  if (!kIsWeb) return target;
  return Uri.parse(
    'https://api.allorigins.win/raw?url=${Uri.encodeComponent(target.toString())}',
  );
}
