class GlossaryEntry {
  const GlossaryEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.mechanica,
    required this.limitations,
  });

  final String id;
  final String title;
  final String subtitle;
  final String body;
  final String mechanica;
  final String limitations;
}

/// Full in-app documentation of mechanics (EN copy for store/hub alignment).
class AppGlossary {
  static const entries = <GlossaryEntry>[
    GlossaryEntry(
      id: 'det_structure',
      title: 'Structure Shift',
      subtitle: 'Trend structure break (BOS-style heuristic)',
      body:
          'Structure Shift looks for a change in swing structure: higher-highs / '
          'higher-lows flipping into lower-highs / lower-lows (or the reverse). '
          'A bearish shift is typically flagged when price breaks below a prior '
          'higher-low after an uptrend; a bullish shift when price breaks above '
          'a prior lower-high after a downtrend.',
      mechanica:
          '1) Find swing highs/lows with a symmetric pivot window.\n'
          '2) Classify the recent swing sequence as bullish, bearish, or mixed.\n'
          '3) Detect a break of the last opposing swing within the latest bars.\n'
          '4) Score by clarity of prior trend, break distance, and recency.',
      limitations:
          'Swing detection is parameter-sensitive. Sideways markets produce noise. '
          'This is not Smart Money Concepts certification — it is a transparent heuristic.',
    ),
    GlossaryEntry(
      id: 'det_ma',
      title: 'MA Regime',
      subtitle: 'Moving-average trend regime change',
      body:
          'MA Regime classifies price relative to an EMA stack (20 / 50 / 200) and '
          'flags a regime change when the stack relationship flips from bullish '
          'to bearish (or reverse) on recent bars.',
      mechanica:
          '1) Compute EMA20, EMA50, EMA200 on closed bars.\n'
          '2) Bull regime: price above EMA20 and EMA20 above EMA50 (stack alignment).\n'
          '3) Bear regime: price below EMA20 and EMA20 below EMA50.\n'
          '4) Emit when regime on the last closed bar differs from the prior regime.',
      limitations:
          'EMAs lag. Chop around the averages creates false flips. Always confirm on the chart.',
    ),
    GlossaryEntry(
      id: 'det_levels',
      title: 'Support / Resistance',
      subtitle: 'Horizontal level clusters from swing pivots',
      body:
          'Levels aggregates repeated swing highs/lows into horizontal zones. '
          'A detection is emitted when price is interacting with a zone — '
          'approaching, rejecting, or resting near support or resistance.',
      mechanica:
          '1) Collect pivot highs and lows.\n'
          '2) Cluster prices within an ATR-relative tolerance.\n'
          '3) Rank zones by touch count and compactness.\n'
          '4) Flag interaction when close is within a proximity band of the zone.',
      limitations:
          'Markets respect zones, not single ticks. Soft levels and wick noise are common. '
          'Multi-timeframe confluence is not automatic in v1.',
    ),
    GlossaryEntry(
      id: 'tf_1h',
      title: '1 Hour',
      subtitle: 'Intraday structure',
      body:
          '1H balances responsiveness and noise. Useful for active monitoring, '
          'but expects more false structure flips than 4H/1D.',
      mechanica: 'Candles aggregated at 60-minute open boundaries from each exchange API.',
      limitations: 'News spikes and thin books distort swings.',
    ),
    GlossaryEntry(
      id: 'tf_4h',
      title: '4 Hour',
      subtitle: 'Swing framing',
      body:
          '4H is the default “read the market” frame for many discretionary traders. '
          'Structure and MA flips here tend to be more meaningful than on 1H.',
      mechanica: 'Candles aggregated at 4-hour open boundaries from each exchange API.',
      limitations: 'Still lagging versus the tape; not a substitute for risk management.',
    ),
    GlossaryEntry(
      id: 'tf_1d',
      title: '1 Day',
      subtitle: 'Higher-timeframe bias',
      body:
          '1D emphasizes regime and major levels. Fewer signals, usually higher context value.',
      mechanica: 'Daily candles from each exchange API (exchange timezone rules may differ slightly).',
      limitations: 'Slow to update; do not expect many daily prints per scan cycle.',
    ),
    GlossaryEntry(
      id: 'exchanges',
      title: 'Multi-exchange USDT scan',
      subtitle: 'Binance · Bybit · Gate.io',
      body:
          'Structure Radar queries public spot USDT market data from three venues '
          'so the same setup can be compared across liquidity venues. Only USDT '
          'quoted pairs are scanned.',
      mechanica:
          'Each venue has its own REST candle endpoint and USDT symbol naming '
          '(BTCUSDT / BTC_USDT). The universe is intentionally short to keep '
          'full multi-exchange scans practical.',
      limitations:
          'Prices and volumes differ by venue. A hit on one exchange is not a guarantee '
          'on another. API limits and downtime can skip symbols mid-scan. '
          'Browser demos may use a CORS relay for public APIs.',
    ),
    GlossaryEntry(
      id: 'score',
      title: 'Confidence score',
      subtitle: '0–100 heuristic quality',
      body:
          'Each detection carries a score estimating how clean the setup looks '
          'under the detector rules — not a probability of profit.',
      mechanica:
          'Scores blend recency, separation from noise thresholds, touch quality, '
          'and regime clarity. Profiles can filter by minimum score before alerts.',
      limitations:
          'High score ≠ good trade. Always read the chart and manage risk.',
    ),
    GlossaryEntry(
      id: 'alert_profile',
      title: 'Alert profile',
      subtitle: 'Telegram-ready preferences',
      body:
          'Your alert profile stores which detectors, timeframes, exchanges, and '
          'minimum score should fan out to Telegram later. Linking is prepared '
          'in-app; outbound bot delivery is not live in this build.',
      mechanica:
          'Profile JSON is persisted locally and mirrored into a bridge payload '
          'schema (structure_radar.alert_profile.v1) plus an outbound event queue.',
      limitations:
          'Until the bot backend is connected, events stay on-device only.',
    ),
  ];

  static GlossaryEntry? byId(String id) {
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }
}
