# Play Data safety — Structure Radar

Use this in Play Console → App content → Data safety.

## Collected
- App activity / language preference — **on device** (SharedPreferences)
- Optional: local analytics events (e.g. community button tap) — **on device**, not sold
Local language, disclaimer flag, alert-profile preferences, local outbound queue for a future bot (not sent until you opt in). Public candle APIs (Binance/Bybit/Gate). No IAP. Telegram only if you tap community or future alert opt-in.

## Shared
- None sold
- Telegram: user leaves the app if they tap Desk Club (external)
- Market data APIs: requests for public candles/series (not user identity)

## Security
- Data encrypted in transit (HTTPS) for network calls
- Users can reset language / legal acceptance in Profile
- Account deletion: not applicable unless the user later enables cloud league (Paper League only)

## Financial
This app does **not** process payments. Not a broker. Educational / simulation.

## Children
Not directed at children.
