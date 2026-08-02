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
  String get minScore => isRu ? 'Мин. score' : 'Min score';
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
      isRu ? 'Мин. score алерта' : 'Alert min score';
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
}
