enum AppLang { en, ru }

extension AppLangX on AppLang {
  String get code => this == AppLang.ru ? 'ru' : 'en';
  String get label => this == AppLang.ru ? 'Русский' : 'English';
}

/// Compact bilingual dictionary for Structure Radar UI.
class L10n {
  L10n(this.lang);
  final AppLang lang;

  bool get isRu => lang == AppLang.ru;

  String get appName => 'Structure Radar';

  String get tabRadar => isRu ? 'Радар' : 'Radar';
  String get tabResults => isRu ? 'Результаты' : 'Results';
  String get tabProfile => isRu ? 'Профиль' : 'Profile';
  String get tabGlossary => isRu ? 'Глоссарий' : 'Glossary';

  String get language => isRu ? 'Язык' : 'Language';
  String get disclaimers => isRu ? 'Дисклеймеры' : 'Disclaimers';
  String get enterRadar => isRu ? 'Войти в Radar' : 'Enter Radar';
  String get beforeContinue =>
      isRu ? 'Перед продолжением' : 'Before you continue';
  String get acceptDisclaimer => isRu
      ? 'Я понимаю: приложение только для обучения и не является финансовой рекомендацией.'
      : 'I understand this app is educational only and not financial advice.';

  String get scanTitle => appName;
  String get scanSubtitle => isRu
      ? 'Сканируем USDT-пары на Binance, Bybit и Gate.io: смена структуры, режим MA и уровни поддержки/сопротивления.'
      : 'Scan Binance, Bybit and Gate.io USDT pairs for structure shifts, MA regime flips, and S/R interactions.';

  String get exchanges => isRu ? 'Биржи' : 'Exchanges';
  String get timeframes => isRu ? 'Таймфреймы' : 'Timeframes';
  String get detectors => isRu ? 'Детекторы' : 'Detectors';
  String get minScore =>
      isRu ? 'Мин. уверенность' : 'Min confidence';
  String get minScoreHint => isRu
      ? 'Порог score 50–90: слабее порога — в ленту не попадёт. Это не цена и не риск, а фильтр «насколько чисто выглядит сетап».'
      : 'Score threshold 50–90: weaker hits stay out of the feed. Not price or risk — a cleanliness filter for setups.';
  String get runScan => isRu ? 'Запустить скан' : 'Run scan';
  String get scanning => isRu ? 'Сканирование…' : 'Scanning…';
  String get cancel => isRu ? 'Отмена' : 'Cancel';
  String get starting => isRu ? 'Запуск…' : 'Starting…';
  String get done => isRu ? 'Готово' : 'Done';
  String get selectAtLeast => isRu
      ? 'Выбери хотя бы одну биржу, таймфрейм и детектор.'
      : 'Select at least one exchange, timeframe, and detector.';
  String get latestResults => isRu ? 'Последние результаты' : 'Latest results';
  String get openResultsHint => isRu
      ? 'Полный список — во вкладке Результаты.'
      : 'Open Results for the full list.';
  String get shortDisclaimer => isRu
      ? 'Образовательные эвристики по графику. Не финансовый совет. Не брокер. Сделки не исполняются. Детекции могут ошибаться.'
      : 'Educational simulation of chart heuristics only. Not financial advice. Not a broker. No orders are placed. Detections can be wrong.';

  String get resultsTitle => isRu ? 'Результаты' : 'Results';
  String get noDetectionsYet => isRu
      ? 'Пока нет детекций. Запусти скан во вкладке Радар.'
      : 'No detections yet. Run a scan from the Radar tab.';
  String get scanInProgress =>
      isRu ? 'Идёт сканирование…' : 'Scan in progress…';
  String get sortedByScore =>
      isRu ? 'отсортировано по score' : 'sorted by score';
  String get setups => isRu ? 'сетапов' : 'setups';
  String get heuristicsOnly => isRu
      ? 'Только образовательные эвристики — не торговые сигналы.'
      : 'Educational heuristics only — not trade signals.';
  String get filterAll => isRu ? 'Все' : 'All';
  String get sortScore => isRu ? 'Score' : 'Score';
  String get sortTime => isRu ? 'Время' : 'Time';

  String get alertProfile => isRu ? 'Профиль алертов' : 'Alert profile';
  String get alertProfileBody => isRu
      ? 'Настрой, какие детекции позже уйдут в Telegram. Доставка подготовлена локально; бот ещё не подключён.'
      : 'Configure which detections should fan out to Telegram later. Delivery is prepared on-device; the bot is not connected yet.';
  String get telegramBridge => isRu ? 'Мост Telegram' : 'Telegram bridge';
  String get armTelegram =>
      isRu ? 'Вооружить доставку в Telegram' : 'Arm Telegram delivery';
  String get armTelegramSub => isRu
      ? 'При включении подходящие детекции кладутся в локальную очередь для будущего воркера бота.'
      : 'When enabled, matching detections are queued locally for the future bot worker.';
  String get linkCode => isRu ? 'Код привязки' : 'Link code';
  String get copied => isRu ? 'Код скопирован' : 'Link code copied';
  String get openBotLink =>
      isRu ? 'Открыть deep link бота (заготовка)' : 'Open bot deep link (prep)';
  String get botPlaceholder => isRu
      ? 'Плейсхолдер бота: @StructureRadarBot. Deep link откроет Telegram; привязка заработает после бэкенда.'
      : 'Bot username placeholder: @StructureRadarBot. Deep link opens Telegram; linking will activate after backend wiring.';
  String get detectorsForAlerts =>
      isRu ? 'Детекторы для алертов' : 'Detectors for alerts';
  String get timeframesForAlerts =>
      isRu ? 'Таймфреймы для алертов' : 'Timeframes for alerts';
  String get exchangesForAlerts =>
      isRu ? 'Биржи для алертов' : 'Exchanges for alerts';
  String get alertMinScore =>
      isRu ? 'Мин. уверенность алерта' : 'Alert min confidence';
  String get bridgePreview =>
      isRu ? 'Превью bridge payload' : 'Bridge payload preview';
  String outboundQueue(int n) => isRu
      ? 'Локальная очередь: $n событий(я) ждут воркер бота.'
      : 'Outbound queue (local): $n event(s) waiting for bot worker.';

  String get glossaryTitle =>
      isRu ? 'Глоссарий и механики' : 'Glossary & mechanics';
  String get glossarySubtitle => isRu
      ? 'Полное описание каждого детектора, таймфрейма, score и профиля алертов Telegram.'
      : 'Full description of each detector, timeframe, scoring, and the Telegram alert profile.';
  String get howItWorks => isRu ? 'Как работает' : 'How it works';
  String get limitations => isRu ? 'Ограничения' : 'Limitations';
  String get mechanic => isRu ? 'Механика' : 'Mechanic';
  String get legalTitle => isRu ? 'Дисклеймеры' : 'Disclaimers';
  String get legalHeading =>
      isRu ? 'Юридические и риск-уведомления' : 'Legal & risk notices';

  String get detectedBar => isRu ? 'Бар детекции' : 'Detected bar';
  String get notAdviceFooter => isRu
      ? 'Не финансовый совет. Эвристики паттернов могут ошибаться. Делай собственное исследование.'
      : 'Not financial advice. Pattern heuristics can fail. Do your own research.';

  String get etaHint => isRu
      ? 'Параллельный скан USDT · обычно быстрее полного перебора'
      : 'Parallel USDT scan · usually faster than serial crawl';

  String detectorLabel(String key) {
    if (!isRu) {
      return switch (key) {
        'structureShift' => 'Structure Shift',
        'maRegime' => 'MA Regime',
        'levels' => 'Support / Resistance',
        _ => key,
      };
    }
    return switch (key) {
      'structureShift' => 'Смена структуры',
      'maRegime' => 'Режим MA',
      'levels' => 'Поддержка / сопротивление',
      _ => key,
    };
  }

  String detectorShort(String key) {
    if (!isRu) {
      return switch (key) {
        'structureShift' => 'STRUCTURE',
        'maRegime' => 'MA REGIME',
        'levels' => 'LEVELS',
        _ => key,
      };
    }
    return switch (key) {
      'structureShift' => 'СТРУКТУРА',
      'maRegime' => 'РЕЖИМ MA',
      'levels' => 'УРОВНИ',
      _ => key,
    };
  }

  String progressOf(int done, int total, String label) =>
      isRu ? '$done / $total · $label' : '$done / $total · $label';

  String get splashMark => 'STRUCTURE RADAR';
  String get splashTitle =>
      isRu ? 'Структура рынка — под контролем.' : 'Market structure, scored.';
  String get splashSub => isRu
      ? 'USDT · три биржи · смена структуры · режим MA · уровни.\nОбразовательные эвристики. Не сигналы.'
      : 'USDT · three venues · structure shift · MA regime · levels.\nEducational heuristics. Not signals.';
  String get splashCta => isRu ? 'ОТКРЫТЬ РАДАР' : 'ENTER RADAR';
  String get splashTag => isRu ? 'FREE #2 · EN/RU' : 'FREE #2 · EN/RU';

  String get coachTitle => isRu ? 'ПОДСКАЗКА' : 'COACH';
  String get coachBody => isRu
      ? 'Сначала выбери биржи и TF, затем Run scan. Открывай карточку и сверяй график — score не равен входу.'
      : 'Pick venues and TFs, then Run scan. Open a card and verify the chart — score is not an entry.';
  String get coachDismiss => isRu ? 'Понятно' : 'Got it';

  String get firstRunKicker => isRu ? '01 · СТАРТ' : '01 · START';
  String get firstRunTitle1 => isRu ? 'Выбери параметры' : 'Set the lens';
  String get firstRunBody1 => isRu
      ? 'Биржи, таймфреймы и детекторы — это твой фильтр. Не включай всё сразу, если хочешь чище читать ленту.'
      : 'Exchanges, timeframes and detectors are your filter. Don’t arm everything if you want a cleaner tape.';
  String get firstRunTitle2 => isRu ? 'Запусти скан' : 'Run the scan';
  String get firstRunBody2 => isRu
      ? 'Радар параллельно обходит USDT-пары. Прогресс покажет площадку и символ.'
      : 'Radar walks USDT pairs in parallel. Progress shows venue and symbol.';
  String get firstRunTitle3 => isRu ? 'Читай график' : 'Read the chart';
  String get firstRunBody3 => isRu
      ? 'Каждая детекция — эвристика. Открой карточку, проверь EMA/уровни, сверься с глоссарием.'
      : 'Every hit is a heuristic. Open the card, check EMA/levels, use the glossary.';
  String get firstRunNext => isRu ? 'ДАЛЕЕ' : 'NEXT';
  String get firstRunDone => isRu ? 'К РАДАРУ' : 'TO RADAR';

  String get recapKicker => isRu ? 'СКАН ЗАВЕРШЁН' : 'SCAN COMPLETE';
  String get recapTitle => isRu ? 'Сводка радара' : 'Radar recap';
  String get recapOpenResults => isRu ? 'К РЕЗУЛЬТАТАМ' : 'OPEN RESULTS';
  String get recapClose => isRu ? 'ОСТАТЬСЯ' : 'STAY';
  String recapHits(int n) => isRu ? '$n сетапов выше порога' : '$n setups above threshold';

  String get emptyResultsTitle =>
      isRu ? 'Лента пуста' : 'Tape is empty';
  String get emptyResultsBody => isRu
      ? 'Запусти скан во вкладке Радар. Здесь появятся сетапы по score.'
      : 'Run a scan from Radar. Setups will land here sorted by score.';

  String get guideCta => isRu ? 'ГИД РАДАРА' : 'RADAR GUIDE';
  String get guideTitle => isRu ? 'Гид Structure Radar' : 'Structure Radar guide';
  String get eduOnly => isRu
      ? 'Только обучение · без реальных денег · без исполнения ордеров'
      : 'Educational only · no real money · no order execution';
}
