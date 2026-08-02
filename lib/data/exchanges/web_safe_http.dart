import 'package:flutter/foundation.dart';

/// Exchange APIs block browser CORS. On web we route GET through a relay.
/// Prefer corsproxy.io — allorigins often truncates multi-MB ticker payloads.
Uri webSafeUri(Uri target) {
  if (!kIsWeb) return target;
  return Uri.parse(
    'https://corsproxy.io/?${Uri.encodeComponent(target.toString())}',
  );
}
