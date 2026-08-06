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
          '1) Require enough ATR% for the timeframe (skip flat ranges).\n'
          '2) Find swing highs/lows with a wider pivot window.\n'
          '3) Require clean prior HH/HL or LH/LL (no emerging micro-breaks).\n'
          '4) BOS only if close clears the swing by ≥0.35×ATR for 2 closes.',
      limitations:
          'Still heuristic. Low-liquidity wicks can fake a break. Not a trade signal.',
    ),
    GlossaryEntry(
      id: 'det_ma',
      title: 'MA Regime',
      subtitle: 'Slow MA stack regime change',
      body:
          'MA Regime uses a slow EMA stack sized like a higher timeframe on this '
          'chart (15m→55/100/200, 30m→45/90/180, 1H→55/100/200, 4H→40/80/180, '
          '1D→30/60/150). A flip emits only '
          'after confirm closes and a long cooldown since the opposite regime — '
          'quality trend change, not every scalp cross in a flat.',
      mechanica:
          '1) Volatility gate (ATR%) — skip dead flats.\n'
          '2) Slow EMA stack sized like a higher timeframe on this chart '
          '(15m→55/100/200, 30m→45/90/180, 1H→55/100/200, 4H→40/80/180, 1D→30/60/150).\n'
          '3) Regime must hold for 3 closes.\n'
          '4) Min ~18 bars since the previous opposite regime (cooldown).',
      limitations:
          'EMAs lag. Cooldown reduces whipsaws but also delays recognition of sharp reversals.',
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
          '1) Collect swing highs (resistance) and lows (support) separately.\n'
          '2) Cluster only tight prices (≈0.22×ATR / ~0.25% of price).\n'
          '3) Require ≥3 touches separated in time (not adjacent micro-pivots).\n'
          '4) Emit only when price is approaching an unbroken level.\n'
          '5) Optionally attach ascending/descending triangle diagonals.',
      limitations:
          'Markets respect zones, not single ticks. Soft levels and wick noise remain. '
          'Triangle detection is a heuristic overlay on clean horizontals.',
    ),
    GlossaryEntry(
      id: 'tf_15m',
      title: '15 Minutes',
      subtitle: 'Fast intraday structure',
      body:
          '15m is the fastest frame in Structure Radar. Expect more noise than 1H+; '
          'detectors use slow MA stacks and volatility gates so flat chop is filtered harder.',
      mechanica:
          'Candles aggregated at 15-minute open boundaries from each exchange API.',
      limitations:
          'Whipsaws and news spikes are common. Prefer with higher-TF context.',
    ),
    GlossaryEntry(
      id: 'tf_30m',
      title: '30 Minutes',
      subtitle: 'Short intraday swing',
      body:
          '30m sits between scalp noise and 1H structure. Useful for active sessions '
          'when 1H feels late, without going fully to 15m chatter.',
      mechanica:
          'Candles aggregated at 30-minute open boundaries from each exchange API.',
      limitations:
          'Still noisier than 4H/1D; confirm regime on a higher frame when unsure.',
    ),
    GlossaryEntry(
      id: 'tf_1h',
      title: '1 Hour',
      subtitle: 'Intraday structure',
      body:
          '1H balances responsiveness and noise. Useful for active monitoring, '
          'but expects more false structure flips than 4H/1D.',
      mechanica:
          'Candles aggregated at 60-minute open boundaries from each exchange API.',
      limitations: 'News spikes and thin books distort swings.',
    ),
    GlossaryEntry(
      id: 'tf_4h',
      title: '4 Hour',
      subtitle: 'Swing framing',
      body:
          '4H is the default “read the market” frame for many discretionary traders. '
          'Structure and MA flips here tend to be more meaningful than on 1H.',
      mechanica:
          'Candles aggregated at 4-hour open boundaries from each exchange API.',
      limitations:
          'Still lagging versus the tape; not a substitute for risk management.',
    ),
    GlossaryEntry(
      id: 'tf_1d',
      title: '1 Day',
      subtitle: 'Higher-timeframe bias',
      body:
          '1D emphasizes regime and major levels. Fewer signals, usually higher context value.',
      mechanica:
          'Daily candles from each exchange API (exchange timezone rules may differ slightly).',
      limitations:
          'Slow to update; do not expect many daily prints per scan cycle.',
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
