import '../l10n/app_lang.dart';

class GlossaryLocalized {
  static List<Map<String, String>> entries(AppLang lang) {
    final ru = lang == AppLang.ru;
    return [
      {
        'id': 'det_structure',
        'title': ru ? 'Смена структуры' : 'Structure Shift',
        'subtitle': ru
            ? 'Слом трендовой структуры (BOS-эвристика)'
            : 'Trend structure break (BOS-style heuristic)',
        'body': ru
            ? 'Ищем смену свинговой структуры: higher-highs / higher-lows переходят в lower-highs / lower-lows (или наоборот). Медвежий сдвиг обычно при пробое прошлого higher-low после аптренда; бычий — при пробое прошлого lower-high после даунтренда.'
            : 'Structure Shift looks for a change in swing structure: higher-highs / higher-lows flipping into lower-highs / lower-lows (or the reverse).',
        'mechanica': ru
            ? '1) Фильтр волатильности (ATR%) — мёртвый флэт отбрасываем.\n2) Шире окно пивотов.\n3) Только чистая геометрия HH/HL или LH/LL (без «emerging»).\n4) BOS: close за свингом ≥0.35×ATR на 2 закрытиях.'
            : '1) ATR% volatility gate — skip dead flats.\n2) Wider pivot window.\n3) Clean prior HH/HL or LH/LL only (no emerging).\n4) BOS: close clears swing by ≥0.35×ATR for 2 closes.',
        'limitations': ru
            ? 'Эвристика. Тонкие рынки и фитили всё ещё могут обмануть. Не торговый сигнал.'
            : 'Still heuristic. Thin markets and wicks can fake a break. Not a trade signal.',
      },
      {
        'id': 'det_ma',
        'title': ru ? 'Режим MA' : 'MA Regime',
        'subtitle': ru
            ? 'Смена режима по медленным скользящим'
            : 'Slow MA stack regime change',
        'body': ru
            ? 'Медленный стек EMA «как с старшего ТФ» на текущем графике (1H→55/100/200, 4H→40/80/180, 1D→30/60/150). Сигнал только после подтверждения и длинного cooldown — не каждый скальп-кросс.'
            : 'Slow EMA stack sized like a higher timeframe on this chart (1H→55/100/200, 4H→40/80/180, 1D→30/60/150). Emits only after confirm + long cooldown — not every scalp cross.',
        'mechanica': ru
            ? '1) ATR%-гейт — флэт мимо.\n2) Медленный стек по TF.\n3) Режим держится 3 закрытия.\n4) ≥18 баров с прошлого противоположного режима.'
            : '1) ATR% gate — skip flats.\n2) Slow stack per TF.\n3) Regime holds 3 closes.\n4) ≥18 bars since previous opposite regime.',
        'limitations': ru
            ? 'EMA запаздывают. Cooldown режет пилу, но и откладывает резкие развороты.'
            : 'EMAs lag. Cooldown cuts whipsaws but also delays sharp reversals.',
      },
      {
        'id': 'det_levels',
        'title': ru ? 'Поддержка / сопротивление' : 'Support / Resistance',
        'subtitle': ru
            ? 'Горизонтальные зоны из свинговых пивотов'
            : 'Horizontal level clusters from swing pivots',
        'body': ru
            ? 'Собираем повторяющиеся хаи/лоу в горизонтальные зоны и помечаем взаимодействие цены с зоной.'
            : 'Levels aggregates repeated swing highs/lows into horizontal zones and flags price interaction.',
        'mechanica': ru
            ? '1) Хаи и лои отдельно.\n2) Узкий кластер (~0.22×ATR).\n3) ≥3 касания с разнесением во времени.\n4) Только если цена подходит к несломанному уровню.\n5) Опционально треугольник.'
            : '1) Highs and lows separately.\n2) Tight cluster (~0.22×ATR).\n3) ≥3 time-separated touches.\n4) Only when price approaches an unbroken level.\n5) Optional triangle overlay.',
        'limitations': ru
            ? 'Рынок уважает зоны, не тики. Ложные проколы фитилями обычны.'
            : 'Markets respect zones, not ticks. Wick noise is common.',
      },
      {
        'id': 'exchanges',
        'title': ru ? 'Мультибиржа USDT' : 'Multi-exchange USDT scan',
        'subtitle': 'Binance · Bybit · Gate.io',
        'body': ru
            ? 'Сканируем только спотовые USDT-пары на трёх площадках, чтобы сравнивать один сетап на разной ликвидности.'
            : 'Queries public spot USDT market data from three venues for comparable setups.',
        'mechanica': ru
            ? 'У каждой биржи свой REST klines и нейминг USDT. Юниверс короткий — чтобы полный скан был практичным. В браузере возможен CORS-relay.'
            : 'Each venue has its own REST candles API. Short universe keeps scans practical. Browser demos may use a CORS relay.',
        'limitations': ru
            ? 'Цены/объёмы различаются. Хит на одной бирже ≠ гарантия на другой.'
            : 'Prices differ by venue. A hit on one exchange is not a guarantee on another.',
      },
      {
        'id': 'score',
        'title': ru ? 'Confidence score' : 'Confidence score',
        'subtitle': ru ? '0–100 качество эвристики' : '0–100 heuristic quality',
        'body': ru
            ? 'Score оценивает «чистоту» сетапа по правилам детектора — это не вероятность прибыли.'
            : 'Score estimates how clean the setup looks under detector rules — not profit probability.',
        'mechanica': ru
            ? 'Смешиваем свежесть, отделение от шума, качество касаний и ясность режима.'
            : 'Blends recency, separation from noise, touch quality, and regime clarity.',
        'limitations': ru
            ? 'Высокий score ≠ хорошая сделка.'
            : 'High score ≠ good trade.',
      },
      {
        'id': 'alert_profile',
        'title': ru ? 'Профиль алертов' : 'Alert profile',
        'subtitle': ru
            ? 'Настройки под будущий Telegram'
            : 'Telegram-ready preferences',
        'body': ru
            ? 'Профиль хранит детекторы, TF, биржи и мин. score для будущей доставки в Telegram.'
            : 'Stores which detectors/timeframes/exchanges/min score should fan out to Telegram later.',
        'mechanica': ru
            ? 'JSON локально + schema bridge payload + локальная очередь событий.'
            : 'Local JSON + bridge payload schema + on-device outbound queue.',
        'limitations': ru
            ? 'Пока бот не подключён, события остаются на устройстве.'
            : 'Until the bot backend is connected, events stay on-device only.',
      },
    ];
  }
}
