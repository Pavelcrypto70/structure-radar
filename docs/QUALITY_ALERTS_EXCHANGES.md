# Structure Radar — Quality / Alerts / Exchanges (тимлид)

Снимок: **2026-10-05**  
Контекст: отток из‑за ложных треугольников + запрос на фоновые детекты и расширение бирж.

## Вердикт

| Приоритет | Тема | Решение |
|-----------|------|---------|
| **P0 сейчас** | Качество Levels / triangles | Ужесточить правила (сделано в коде r13) |
| **P0** | Не обещать фон без доставки | Сначала live bot + dedupe, потом фон |
| **P1** | Фоновые уведомления | Server-side scanner → Telegram/FCM (Android best-effort опционально) |
| **P2** | Пул бирж | +1–2 venue native-first (OKX/Bitget), web через proxy |

---

## 1. Почему отток: треугольники

Старый `_tryTriangle`:
- **2** opposing pivot = «треугольник»
- сжатие всего **~8%** (`0.92`)
- **+10** к score → слабый горизонталь проходил `minScore 65` из‑за ярлыка
- Levels **без** ATR volatility gate (Structure/MA уже имеют)
- production knobs были **слабее** class defaults (approach 1.25, cluster 0.28…)

Живой sweep: Levels на BTC ~**29–56%** баров @65 при цели ~**8%**.

### Что ужесточили в коде (P0)

| Правило | Было → Стало |
|---------|----------------|
| Opposing pivots | 2 → **≥3** |
| Convergence | 8% → **≥25%** (`0.75`) |
| Diagonal span | нет → **≥16** баров |
| Side integrity | нет → pivot ниже R / выше S |
| Score boost | +10 → **+3** и только если base ≥70 |
| Short TF triangles | были → **запрет** на 15m/30m |
| Volatility gate | нет → `isVolatileEnough` |
| Production approach | 1.25/0.70 → **0.85/0.45** |
| Cluster / gaps | loose → class defaults |
| Break | 2 closes / 0.35 → **1 close / 0.25** |
| Fat zone | 0.45 → **0.32 ATR** |
| Approach | always true → drift toward / tight band |

Файлы: `lib/detectors/levels_detector.dart`, `lib/data/market_repository.dart`, `test/levels_triangle_quality_test.dart`.

---

## 2. Настройки по детекторам (целевая матрица)

| Детектор | Ключ качества | Следующий шаг |
|----------|---------------|---------------|
| **Structure** | clean HH/HL + BOS ×2 closes + ATR gate | подтянуть `minBreakAtr` 0.28→0.35 (как в glossary) |
| **MA Regime** | slow stack + 3-bar confirm + cooldown | flat band 0.12→0.18 ATR; sync glossary cooldown |
| **Levels** | multi-touch + intact + approach | ✅ triangle gates; дальше live sweep QA |
| **Alerts minScore** | отдельный порог выше UI scan | P0 bot: alert minScore ≥75 |

Принцип продукта: **precision > recall**. Пустой скан лучше ложного треугольника.

---

## 3. Фоновые детекты + уведомления

### Сейчас
- Профиль алертов + локальная очередь после **ручного** скана
- `@StructureRadarBot` — placeholder, доставки нет
- Background / FCM / WorkManager — нет

### P0 — сделать алерты реальными (без фейка «фона»)
1. Бот + `/start` → bind `linkCode`↔`chat_id` (сервер)
2. Drain: сервер шлёт из очереди / лучше **сервер сам сканит** по профилю
3. Dedupe `(symbol, tf, kind, levelBucket)` + cooldown 4–12ч
4. Cap ≤5–10 msg/день; quiet hours UI
5. Копирайт: educational heuristics, не signals

### P1 — фон
- **Preferred:** hosted scanner → Telegram (+ optional FCM)
- **Android fallback:** WorkManager 15–60м, shortlist, best-effort
- **Web:** только foreground / «оставь вкладку» — не обещать фон

### Риски
Spam алертов = второй канал оттока. Без dedupe/caps не включать.

---

## 4. Расширение пула бирж

Сейчас: Binance · Bybit · Gate (web свечи ≈ Binance).

| Этап | Что |
|------|-----|
| Сейчас | Выбор биржи уже есть в Radar + Profile chips |
| P2 | OKX и/или Bitget client + universe priority |
| Web | CORS proxy свой или chip «native only» |
| Alerts | shortlist пар, не full midcap fan-out |

Выбор «нужной биржи» UX уже есть; боль — **качество хитов** и **живая доставка**, не отсутствие чекбокса.

---

## 5. Roadmap исполнения

```
Week 1 (сделано / добить)
  ✅ Triangle / Levels quality gates
  □ Live sweep report до/после на BTC+majors
  □ Structure minBreakAtr sync + MA flat band
  □ Обновить copy: «triangle rare / high bar»

Week 2–3
  □ Telegram bot live + dedupe + rate cap
  □ Quiet hours UI
  □ Alert minScore 75 default

Week 4+
  □ Server-side scheduled scan for opt-in profiles
  □ Optional Android local notify
  □ +1 exchange native
```

---

## 6. Метрики успеха (анти-отток)

| Метрика | Цель |
|---------|------|
| % сканов с ASC/DESC triangle | < 5% хитов Levels (было >>) |
| Levels density @65 на BTC 1H | ~8–12% баров (не 30%+) |
| Alert opt-in 7d retention | без spam spike |
| D1 reopen после пустого скана | не падает (empty = ok UX уже есть) |

---

## Связь с literacy path

Путь учит читать структуру. Ложные треугольники ломают доверие на миссии 3 и в Results — поэтому quality = P0 раньше фона и новых бирж.
