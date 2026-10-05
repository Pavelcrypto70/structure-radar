# Alert bot runbook (P0 delivery)

Client already queues matching detections with anti-spam.
This doc is the server/bot half — **do not put the bot token in the Flutter app**.

## What the app does today (r18)

| Gate | Value |
|------|--------|
| Default alert `minScore` | **75** (personal opt-in) |
| **Broadcast / everyone** `minScore` | **90** |
| Broadcast TFs | **1H · 4H · 1D** (no 15m/30m; no triangle patterns in broadcast) |
| Default alert TFs | 1H · 4H · 1D |
| Quiet hours default | 23:00–08:00 local (personal alerts only) |
| Personal dedupe | same fingerprint · **6h** |
| Broadcast dedupe | same fingerprint · **12h** |
| Personal daily cap | **8** / UTC day |
| Broadcast daily cap | **3** / UTC day (device queue; server must mirror) |
| Personal queue | `outbound_alert_queue_v1` |
| Broadcast queue | `outbound_broadcast_queue_v1` |
| Payload schemas | `structure_radar.detection_alert.v1` · `structure_radar.broadcast_alert.v1` |
| In-app feed | `curated_inbox_v1` + hosted `web/data/curated-signals.json` |
| Deep link | `t.me/StructureRadarBot?start=<linkCode>` |

## Provisioning

1. Create bot via @BotFather → username `StructureRadarBot` (or update `TelegramBridge.botUsername`).
2. Store token in server secret manager / env `SR_TELEGRAM_BOT_TOKEN` — never in git.
3. Deploy a small worker (Cloud Function / Fly / VPS) that:
   - accepts `POST /v1/alerts/enqueue` with auth (device JWT or HMAC) **or**
   - polls a private queue fed by the app after scan
4. On Telegram `/start <linkCode>`: map `chat_id` ↔ `linkCode` in DB.
5. Send `message` from payload; mark delivered; retry with backoff.

## Preferred architecture (anti-churn)

**Server-side scan** for opted-in profiles is better than draining a client queue:

```
Profile (opt-in, filters) → hosted scanner every N min
  → dedupe + cap → Bot API → user

Hosted scanner (shortlist) → score ≥90 + TF gates
  → write curated-signals.json + broadcast queue
  → Bot API → public channel + all apps pull feed
```

Client queues remain fallback / offline buffer until server drain is live.

## Dedup key (must match client)

```
symbol|exchange|timeframe|kind|levelBucket|pattern?
```

Cooldown 6h; max 8/day/user. Raise alert minScore if spam returns.

## Privacy

- `chat_id` is personal data → Privacy Policy + delete path (`/stop` or in-app disconnect).
- Educational copy on every message (already in template).

## Checklist before “alerts live”

- [ ] Bot provisioned
- [ ] Bind `/start` → chat_id
- [ ] Drain or server scan live
- [ ] Dedup + rate limits on server too
- [ ] Data safety / privacy updated
- [ ] Soft launch to Desk Club volunteers
