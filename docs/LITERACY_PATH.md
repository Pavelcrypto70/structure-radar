# Literacy path (Structure Radar)

Guided path for people who already know candles. The app teaches **reading market structure** — never buy/sell/entry/TP signals.

## Phases

| Phase | Condition | Screen | CTA |
|-------|-----------|--------|-----|
| Gate | cold start | Language → Splash → Disclaimer | Continue / Accept |
| P0 | `orientStep < 3` | `OrientationFlow` (3 steps) | Next ×3 |
| P1 | `literacyStep < 4`, no active mission | `LiteracyHome` (4 missions) | Start mission N |
| P1 mission | `activeMission` 1..4 | Radar + `MissionBanner`, fixed scan lens | Find → open matching hit → *Mission complete — Next* |
| P2 | `literacyStep >= 4 && !p2BridgeSeen` | `Phase2Bridge` | Daily habit |
| Habit | after P2 | Free radar + `NextStepCard` | Daily scan |
| P3 | `hitsOpened >= 3 && !glossaryTourSeen` | `GlossaryTour` (3 detector cards) | Got it |
| P4 | `habitDays >= 3 && !clubBridgeSeen` | `ClubBridge` → t.me/Desk_Club | Open community |
| P5 | `habitDays >= 7 && !academyBridgeSeen` | `AcademyBridge` (Trade Master, optional) | Learn / Later |
| Map | any time in terminal | `JourneyMapScreen` (Profile or NextStepCard) | — |

Shell cascade (`lib/ui/shell.dart`): language → splash → disclaimer → orientation → literacy home → P2 → glossary → club → academy → terminal.

### Missions

| # | Lens | TF | Min score |
|---|------|----|-----------|
| 1 | Structure Shift only | 1H, 4H | 55 |
| 2 | MA Regime only | 1H, 4H | 55 |
| 3 | Levels only | 1H, 4H, 15m, 30m | 55 |
| 4 | All detectors (restored defaults) | all | profile min score |

- Starting a mission calls `ScanController.applyMissionLens(kind)` and drops the user onto Radar (web keeps Binance only). Filter chips are hidden during a mission.
- Opening a hit of the matching kind arms the mission; the detail screen shows **Mission complete — Next**, which advances `literacyStep`. The banner has the same button if the user backs out.
- A scan with 0 hits shows `EmptyHitSheet` (teaches that empty is normal); "Understood" completes the mission.
- Mission 4 also calls `markFirstGestureDone()`. Tabs: only Radar (+ Results once hits exist) during missions 1–3; all tabs when `literacyStep >= 4 || firstGestureDone`.
- Mission state survives restarts (lens is re-applied in `ScanController.bootstrap`).

### Habit days

A habit day = completed scan **and** ≥1 opened hit the same calendar day, or an explicit *Check in* on `NextStepCard` after a scan. Counted once per day (`sr_habit_day_v1`).

`NextStepCard` priority: finish mission → daily scan → check-in → glossary countdown → club countdown → academy countdown → day clear.

## State (`lib/state/path_controller.dart`, SharedPreferences)

`splash_seen_v1`, `sr_orient_step_v1`, `sr_literacy_step_v1` (0–3 pending, 4 missions done, 5 habit mode), `sr_active_mission_v1`, `sr_hits_opened_v1`, `sr_scans_v1`, `sr_habit_days_v1`, `sr_habit_day_v1`, `sr_scan_day_v1`, `sr_seen_kinds_v1` (bitmask: 1 structure, 2 MA, 4 levels), `sr_p2_bridge_seen_v1`, `sr_glossary_tour_seen_v1`, `sr_club_bridge_seen_v1`, `sr_academy_bridge_seen_v1`.

`main.dart` wipes these once under stamp `structure_radar_path_20261005` (the older `structure_radar_fresh_20260910` wipe is unchanged).

## Copy

`lib/l10n/path_l10n.dart` — `PathL10n(AppLang)` with EN/ES/PT/RU. UI kit: `lib/ui/path/path_kit.dart` (brass `SrColors`).

## QA presets (web)

Open the web build with `?qa=<preset>` (also `#/?qa=<preset>`). Any valid `qa` forces Russian, skips the language gate and writes the full state (reload re-applies it).

| `qa` | Lands on |
|------|----------|
| `fresh` | Splash → disclaimer (everything cold) |
| `orient` | Orientation step 1 |
| `home` | Literacy home, mission 1 available |
| `m1` … `m4` | Radar with mission N active (lens applied, previous missions done) |
| `habit` | Radar + NextStepCard "Daily scan" (1 habit day) |
| `glossary` | Glossary tour (3 hits opened) |
| `club` | Desk Club bridge (3 habit days) |
| `academy` | Academy bridge (7 habit days) |
| `terminal` | Free terminal, all bridges seen, day clear |

Example: `http://localhost:8080/?qa=m1`.

## Tests

`flutter test test/path_controller_test.dart test/widget_test.dart` — controller rules and one render check per preset.
