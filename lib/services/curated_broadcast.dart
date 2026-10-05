import '../domain/models.dart';

/// Curated setups for the public bot + in-app «signals for everyone» feed.
/// Stricter than personal alerts (75+): precision over recall.
class CuratedBroadcast {
  CuratedBroadcast._();

  static const minScore = 90.0;

  static const linkCode = 'SR_BROADCAST';

  static const broadcastTimeframes = {
    AppTimeframe.h1,
    AppTimeframe.h4,
    AppTimeframe.d1,
  };

  static const dedupeCooldown = Duration(hours: 12);

  /// Max posts to the shared bot channel per UTC day (server should mirror).
  static const maxBroadcastPerDay = 3;

  static bool matches(Detection d) {
    if (d.score < minScore) return false;
    if (!broadcastTimeframes.contains(d.timeframe)) return false;
    if (d.kind == DetectorKind.levels &&
        d.level != null &&
        d.level!.pattern != LevelPattern.horizontal) {
      // Triangles stay in-app only until live QA says otherwise.
      return false;
    }
    return true;
  }
}
