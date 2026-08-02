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
            ? '1) Находим swing high/low симметричным окном.\n2) Классифицируем недавнюю последовательность.\n3) Ловим пробой последнего встречного свинга.\n4) Score по чистоте тренда, дистанции пробоя и свежести.'
            : '1) Find swing highs/lows.\n2) Classify recent sequence.\n3) Detect break of last opposing swing.\n4) Score by clarity, separation, recency.',
        'limitations': ru
            ? 'Пивоты зависят от параметров. Флэт даёт шум. Это прозрачная эвристика, не «истина SMC».'
            : 'Swing detection is parameter-sensitive. Sideways markets produce noise.',
      },
      {
        'id': 'det_ma',
        'title': ru ? 'Режим MA' : 'MA Regime',
        'subtitle': ru
            ? 'Смена режима по скользящим средним'
            : 'Moving-average trend regime change',
        'body': ru
            ? 'Классифицируем цену относительно стека EMA (20 / 50 / 200) и фиксируем смену режима, когда выравнивание стека переворачивается.'
            : 'MA Regime classifies price relative to an EMA stack (20 / 50 / 200) and flags a regime change when the stack relationship flips.',
        'mechanica': ru
            ? '1) Считаем EMA20/50/200.\n2) Бычий режим: цена > EMA20 > EMA50.\n3) Медвежий: цена < EMA20 < EMA50.\n4) Сигнал, если режим последнего бара отличается от предыдущего.'
            : '1) Compute EMA20/50/200.\n2) Bull: price > EMA20 > EMA50.\n3) Bear: opposite.\n4) Emit on flip.',
        'limitations': ru
            ? 'EMA запаздывают. Пила вокруг средних даёт ложные флипы.'
            : 'EMAs lag. Chop around averages creates false flips.',
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
            ? '1) Пивоты.\n2) Кластеризация в пределах ATR-tolerance.\n3) Ранг по числу касаний.\n4) Флаг, если close близко к зоне.'
            : '1) Pivots.\n2) Cluster within ATR tolerance.\n3) Rank by touches.\n4) Flag proximity.',
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
