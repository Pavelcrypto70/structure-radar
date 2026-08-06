enum AppLang { en, es, pt, ru }

extension AppLangX on AppLang {
  String get code => switch (this) {
    AppLang.en => 'en',
    AppLang.es => 'es',
    AppLang.pt => 'pt',
    AppLang.ru => 'ru',
  };
  String get nativeLabel => switch (this) {
    AppLang.en => 'English',
    AppLang.es => 'Español',
    AppLang.pt => 'Português',
    AppLang.ru => 'Русский',
  };
  String get label => nativeLabel;

  static AppLang fromCode(String? code) => switch (code) {
    'es' => AppLang.es,
    'pt' => AppLang.pt,
    'ru' => AppLang.ru,
    _ => AppLang.en,
  };
}

/// Compact EN/ES/PT/RU dictionary for Structure Radar UI.
class L10n {
  L10n(this.lang);
  final AppLang lang;

  bool get isRu => lang == AppLang.ru;
  String t(String en, {String? es, String? pt, String? ru}) => switch (lang) {
    AppLang.ru => ru ?? en,
    AppLang.es => es ?? en,
    AppLang.pt => pt ?? en,
    AppLang.en => en,
  };

  String get appName => 'Structure Radar';

  String get tabRadar => t('Radar', es: 'Radar', pt: 'Radar', ru: 'Радар');
  String get tabResults =>
      t('Results', es: 'Resultados', pt: 'Resultados', ru: 'Результаты');
  String get tabProfile =>
      t('Profile', es: 'Perfil', pt: 'Perfil', ru: 'Профиль');
  String get tabGlossary =>
      t('Glossary', es: 'Glosario', pt: 'Glossário', ru: 'Глоссарий');

  String get language => t('Language', es: 'Idioma', pt: 'Idioma', ru: 'Язык');
  String get disclaimers => t(
    'Disclaimers',
    es: 'Avisos legales',
    pt: 'Avisos legais',
    ru: 'Дисклеймеры',
  );
  String get enterRadar => t(
    'Enter Radar',
    es: 'Entrar al radar',
    pt: 'Entrar no radar',
    ru: 'Войти в Radar',
  );
  String get beforeContinue => t(
    'Before you continue',
    es: 'Antes de continuar',
    pt: 'Antes de continuar',
    ru: 'Перед продолжением',
  );
  String get acceptDisclaimer => t(
    'I understand this app is educational only and not financial advice.',
    es: 'Entiendo que esta aplicación es solo educativa y no constituye asesoramiento financiero.',
    pt: 'Entendo que este app é apenas educacional e não constitui aconselhamento financeiro.',
    ru: 'Я понимаю: приложение только для обучения и не является финансовой рекомендацией.',
  );

  String get scanTitle => appName;
  String get scanSubtitle => t(
    'Scan all USDT pairs except top-15 market-cap coins: mid/small caps, cross-venue dedupe, structure / MA / levels.',
    es: 'Escanea pares USDT fuera del top 15 por capitalización: medianas y pequeñas, deduplicación entre exchanges, estructura / MA / niveles.',
    pt: 'Escaneia pares USDT fora das 15 maiores por capitalização: médias e pequenas, deduplicação entre corretoras, estrutura / MA / níveis.',
    ru: 'Скан всех USDT кроме топ-15 по капе: мелкокап, дедуп между биржами, структура / MA / уровни.',
  );
  String get buildingUniverse => t(
    'Building pair universe…',
    es: 'Preparando el universo de pares…',
    pt: 'Montando o universo de pares…',
    ru: 'Собираю юниверс пар…',
  );
  String get emptyUniverse => t(
    'Could not build the pair universe. Check network and retry.',
    es: 'No se pudo crear el universo de pares. Revisa la conexión e inténtalo de nuevo.',
    pt: 'Não foi possível montar o universo de pares. Verifique a conexão e tente novamente.',
    ru: 'Не удалось собрать список пар. Проверь сеть и попробуй снова.',
  );
  String get allFetchesFailed => t(
    '429/network again. Hard Ctrl+F5 (not normal refresh). Then Binance only, one TF — 4H.',
    es: '429/red otra vez. Haz Ctrl+F5 (no una recarga normal). Después usa solo Binance y un TF: 4H.',
    pt: '429/rede novamente. Use Ctrl+F5 (não uma recarga normal). Depois, apenas Binance e um TF: 4H.',
    ru: 'Снова 429/сеть. Нужен жёсткий Ctrl+F5 (не обычный refresh). Потом только Binance, один TF — 4H.',
  );
  String get buildStamp => 'r11';

  String universeRecap(int unique, int raw) => t(
    'Unique pairs: $unique (raw listings: $raw)',
    es: 'Pares únicos: $unique (listados brutos: $raw)',
    pt: 'Pares únicos: $unique (listagens brutas: $raw)',
    ru: 'Уник. пар: $unique (сырых листингов: $raw)',
  );
  String alsoOn(String venues) => t(
    'Also on: $venues',
    es: 'También en: $venues',
    pt: 'Também em: $venues',
    ru: 'Также на: $venues',
  );
  String get hitsLive => t(
    'Hits appear live',
    es: 'Hallazgos en tiempo real',
    pt: 'Detecções em tempo real',
    ru: 'Хиты по мере скана',
  );
  String get hitsLabel =>
      t('HITS', es: 'HALLAZGOS', pt: 'DETECÇÕES', ru: 'ХИТЫ');
  String get exchanges =>
      t('Exchanges', es: 'Exchanges', pt: 'Corretoras', ru: 'Биржи');
  String get timeframes =>
      t('Timeframes', es: 'Temporalidades', pt: 'Períodos', ru: 'Таймфреймы');
  String get detectors =>
      t('Detectors', es: 'Detectores', pt: 'Detectores', ru: 'Детекторы');
  String get minScore => t(
    'Min confidence',
    es: 'Confianza mín.',
    pt: 'Confiança mín.',
    ru: 'Мин. уверенность',
  );
  String get minScoreHint => t(
    'Score threshold 50–90: weaker hits stay out of the feed. Not price or risk — a cleanliness filter for setups.',
    es: 'Um umbral de 50–90: los hallazgos más débiles no entran en la lista. No es precio ni riesgo; filtra la claridad del setup.',
    pt: 'Limiar de 50–90: detecções mais fracas ficam fora da lista. Não é preço nem risco; filtra a clareza do setup.',
    ru: 'Порог score 50–90: слабее порога — в ленту не попадёт. Это не цена и не риск, а фильтр «насколько чисто выглядит сетап».',
  );
  String get runScan => t(
    'Run scan',
    es: 'Iniciar escaneo',
    pt: 'Iniciar varredura',
    ru: 'Запустить скан',
  );
  String get scanning =>
      t('Scanning…', es: 'Escaneando…', pt: 'Escaneando…', ru: 'Сканирование…');
  String get cancel =>
      t('Cancel', es: 'Cancelar', pt: 'Cancelar', ru: 'Отмена');
  String get starting =>
      t('Starting…', es: 'Iniciando…', pt: 'Iniciando…', ru: 'Запуск…');
  String get done => t('Done', es: 'Listo', pt: 'Concluído', ru: 'Готово');
  String get selectAtLeast => t(
    'Select at least one exchange, timeframe, and detector.',
    es: 'Selecciona al menos un exchange, una temporalidad y un detector.',
    pt: 'Selecione ao menos uma corretora, um período e um detector.',
    ru: 'Выбери хотя бы одну биржу, таймфрейм и детектор.',
  );
  String get latestResults => t(
    'Latest results',
    es: 'Últimos resultados',
    pt: 'Resultados recentes',
    ru: 'Последние результаты',
  );
  String get openResultsHint => t(
    'Open Results for the full list.',
    es: 'Abre Resultados para ver la lista completa.',
    pt: 'Abra Resultados para ver a lista completa.',
    ru: 'Полный список — во вкладке Результаты.',
  );
  String get shortDisclaimer => t(
    'Educational simulation of chart heuristics only. Not financial advice. Not a broker. No orders are placed. Detections can be wrong.',
    es: 'Solo heurísticas educativas de gráficos. No es asesoramiento financiero ni un bróker. No se ejecutan órdenes. Las detecciones pueden fallar.',
    pt: 'Apenas heurísticas educacionais de gráficos. Não é aconselhamento financeiro nem corretora. Nenhuma ordem é executada. As detecções podem falhar.',
    ru: 'Образовательные эвристики по графику. Не финансовый совет. Не брокер. Сделки не исполняются. Детекции могут ошибаться.',
  );

  String get resultsTitle => tabResults;
  String get noDetectionsYet => t(
    'No detections yet. Run a scan from the Radar tab.',
    es: 'Aún no hay detecciones. Inicia un escaneo en Radar.',
    pt: 'Ainda não há detecções. Inicie uma varredura na aba Radar.',
    ru: 'Пока нет детекций. Запусти скан во вкладке Радар.',
  );
  String get scanInProgress => t(
    'Scan in progress…',
    es: 'Escaneo en curso…',
    pt: 'Varredura em andamento…',
    ru: 'Идёт сканирование…',
  );
  String get sortedByScore => t(
    'sorted by score',
    es: 'ordenado por score',
    pt: 'ordenado por score',
    ru: 'отсортировано по score',
  );
  String get setups => t('setups', es: 'setups', pt: 'setups', ru: 'сетапов');
  String get heuristicsOnly => t(
    'Educational heuristics only — not trade signals.',
    es: 'Solo heurísticas educativas; no son señales de trading.',
    pt: 'Apenas heurísticas educacionais — não são sinais de trade.',
    ru: 'Только образовательные эвристики — не торговые сигналы.',
  );
  String get filterAll => t('All', es: 'Todos', pt: 'Todos', ru: 'Все');
  String get sortScore => 'Score';
  String get sortTime => t('Time', es: 'Hora', pt: 'Hora', ru: 'Время');

  String get alertProfile => t(
    'Alert profile',
    es: 'Perfil de alertas',
    pt: 'Perfil de alertas',
    ru: 'Профиль алертов',
  );
  String get alertProfileBody => t(
    'Configure which detections should fan out to Telegram later. Delivery is prepared on-device; the bot is not connected yet.',
    es: 'Configura qué detecciones se enviarán más tarde a Telegram. La entrega está preparada en el dispositivo; el bot aún no está conectado.',
    pt: 'Configure quais detecções serão enviadas depois ao Telegram. A entrega está preparada no dispositivo; o bot ainda não está conectado.',
    ru: 'Настрой, какие детекции позже уйдут в Telegram. Доставка подготовлена локально; бот ещё не подключён.',
  );

  String get joinCommunity => t(
    'Join Desk Club',
    es: 'Únete a Desk Club',
    pt: 'Participe do Desk Club',
    ru: 'Сообщество Desk Club',
  );
  String get joinCommunityBody => t(
    'EN portfolio hub: structure talks, Paper League, academy. This is not the alert bot.',
    es: 'Hub del portafolio en inglés: análisis de estructura, Paper League y academia. No es el bot de alertas.',
    pt: 'Hub do portfólio em inglês: análises de estrutura, Paper League e academia. Não é o bot de alertas.',
    ru: 'EN-хаб портфеля: разборы структуры, Paper League, академия. Это не бот алертов.',
  );
  String get openCommunity => t(
    'Open Desk Club',
    es: 'Abrir Desk Club',
    pt: 'Abrir Desk Club',
    ru: 'Открыть Desk Club',
  );

  String get telegramBridge => t(
    'Telegram bridge',
    es: 'Puente de Telegram',
    pt: 'Ponte do Telegram',
    ru: 'Мост Telegram',
  );
  String get armTelegram => t(
    'Arm Telegram delivery',
    es: 'Activar entrega a Telegram',
    pt: 'Ativar envio ao Telegram',
    ru: 'Вооружить доставку в Telegram',
  );
  String get armTelegramSub => t(
    'When enabled, matching detections are queued locally for the future bot worker.',
    es: 'Al activarlo, las detecciones compatibles se guardan localmente para el futuro worker del bot.',
    pt: 'Quando ativado, as detecções correspondentes entram na fila local para o futuro worker do bot.',
    ru: 'При включении подходящие детекции кладутся в локальную очередь для будущего воркера бота.',
  );
  String get linkCode => t(
    'Link code',
    es: 'Código de vinculación',
    pt: 'Código de vínculo',
    ru: 'Код привязки',
  );
  String get copied => t(
    'Link code copied',
    es: 'Código copiado',
    pt: 'Código copiado',
    ru: 'Код скопирован',
  );
  String get openBotLink => t(
    'Open bot deep link (prep)',
    es: 'Abrir enlace profundo del bot (preparación)',
    pt: 'Abrir link direto do bot (preparação)',
    ru: 'Открыть deep link бота (заготовка)',
  );
  String get botPlaceholder => t(
    'Bot username placeholder: @StructureRadarBot. Deep link opens Telegram; linking will activate after backend wiring.',
    es: 'Marcador de usuario del bot: @StructureRadarBot. El enlace abre Telegram; la vinculación se activará al conectar el backend.',
    pt: 'Nome de usuário provisório do bot: @StructureRadarBot. O link abre o Telegram; a vinculação será ativada ao conectar o backend.',
    ru: 'Плейсхолдер бота: @StructureRadarBot. Deep link откроет Telegram; привязка заработает после бэкенда.',
  );
  String get detectorsForAlerts => t(
    'Detectors for alerts',
    es: 'Detectores para alertas',
    pt: 'Detectores para alertas',
    ru: 'Детекторы для алертов',
  );
  String get timeframesForAlerts => t(
    'Timeframes for alerts',
    es: 'Temporalidades para alertas',
    pt: 'Períodos para alertas',
    ru: 'Таймфреймы для алертов',
  );
  String get exchangesForAlerts => t(
    'Exchanges for alerts',
    es: 'Exchanges para alertas',
    pt: 'Corretoras para alertas',
    ru: 'Биржи для алертов',
  );
  String get alertMinScore => t(
    'Alert min confidence',
    es: 'Confianza mín. de alerta',
    pt: 'Confiança mín. do alerta',
    ru: 'Мин. уверенность алерта',
  );
  String get bridgePreview => t(
    'Bridge payload preview',
    es: 'Vista previa del payload',
    pt: 'Prévia do payload',
    ru: 'Превью bridge payload',
  );
  String outboundQueue(int n) => t(
    'Outbound queue (local): $n event(s) waiting for bot worker.',
    es: 'Cola local: $n evento(s) esperando al worker del bot.',
    pt: 'Fila local: $n evento(s) aguardando o worker do bot.',
    ru: 'Локальная очередь: $n событий(я) ждут воркер бота.',
  );

  String get glossaryTitle => t(
    'Glossary & mechanics',
    es: 'Glosario y mecánicas',
    pt: 'Glossário e mecânicas',
    ru: 'Глоссарий и механики',
  );
  String get glossarySubtitle => t(
    'Full description of each detector, timeframe, scoring, and the Telegram alert profile.',
    es: 'Descripción completa de cada detector, temporalidad, score y perfil de alertas de Telegram.',
    pt: 'Descrição completa de cada detector, período, score e perfil de alertas do Telegram.',
    ru: 'Полное описание каждого детектора, таймфрейма, score и профиля алертов Telegram.',
  );
  String get howItWorks => t(
    'How it works',
    es: 'Cómo funciona',
    pt: 'Como funciona',
    ru: 'Как работает',
  );
  String get limitations =>
      t('Limitations', es: 'Limitaciones', pt: 'Limitações', ru: 'Ограничения');
  String get mechanic =>
      t('Mechanic', es: 'Mecánica', pt: 'Mecânica', ru: 'Механика');
  String get legalTitle => disclaimers;
  String get legalHeading => t(
    'Legal & risk notices',
    es: 'Avisos legales y de riesgo',
    pt: 'Avisos legais e de risco',
    ru: 'Юридические и риск-уведомления',
  );
  String get detectedBar => t(
    'Detected bar',
    es: 'Vela detectada',
    pt: 'Candle detectado',
    ru: 'Бар детекции',
  );
  String get chartTf => t(
    'Chart timeframe',
    es: 'Temporalidad del gráfico',
    pt: 'Período do gráfico',
    ru: 'Таймфрейм графика',
  );
  String chartSignalOn(String tf) => t(
    'Signal found on $tf · check level/context on other TFs',
    es: 'Señal detectada en $tf · revisa nivel y contexto en otros TF',
    pt: 'Sinal encontrado em $tf · confira nível e contexto em outros TFs',
    ru: 'Сигнал найден на $tf · уровень/контекст можно сверить на других TF',
  );
  String get chartLoading => t(
    'Loading candles…',
    es: 'Cargando velas…',
    pt: 'Carregando candles…',
    ru: 'Гружу свечи…',
  );
  String get chartLoadFailed => t(
    'Could not load this timeframe',
    es: 'No se pudo cargar esta temporalidad',
    pt: 'Não foi possível carregar este período',
    ru: 'Не удалось загрузить этот TF',
  );
  String get notAdviceFooter => t(
    'Not financial advice. Pattern heuristics can fail. Do your own research.',
    es: 'No es asesoramiento financiero. Las heurísticas de patrones pueden fallar. Investiga por tu cuenta.',
    pt: 'Não é aconselhamento financeiro. Heurísticas de padrões podem falhar. Faça sua própria pesquisa.',
    ru: 'Не финансовый совет. Эвристики паттернов могут ошибаться. Делай собственное исследование.',
  );
  String get etaHint => t(
    'Parallel USDT scan · usually faster than serial crawl',
    es: 'Escaneo USDT paralelo · normalmente más rápido que el recorrido serial',
    pt: 'Varredura USDT paralela · normalmente mais rápida que a sequência serial',
    ru: 'Параллельный скан USDT · обычно быстрее полного перебора',
  );

  String detectorLabel(String key) {
    return switch (key) {
      'structureShift' => t(
        'Structure Shift',
        es: 'Cambio de estructura',
        pt: 'Mudança de estrutura',
        ru: 'Смена структуры',
      ),
      'maRegime' => t(
        'MA Regime',
        es: 'Régimen de MA',
        pt: 'Regime de MA',
        ru: 'Режим MA',
      ),
      'levels' => t(
        'Support / Resistance',
        es: 'Soporte / resistencia',
        pt: 'Suporte / resistência',
        ru: 'Поддержка / сопротивление',
      ),
      _ => key,
    };
  }

  String detectorShort(String key) {
    return switch (key) {
      'structureShift' => t(
        'STRUCTURE',
        es: 'ESTRUCTURA',
        pt: 'ESTRUTURA',
        ru: 'СТРУКТУРА',
      ),
      'maRegime' => t(
        'MA REGIME',
        es: 'RÉGIMEN MA',
        pt: 'REGIME MA',
        ru: 'РЕЖИМ MA',
      ),
      'levels' => t('LEVELS', es: 'NIVELES', pt: 'NÍVEIS', ru: 'УРОВНИ'),
      _ => key,
    };
  }

  String progressOf(int done, int total, String label) =>
      isRu ? '$done / $total · $label' : '$done / $total · $label';

  String get splashMark => 'STRUCTURE RADAR';
  String get splashTitle => t(
    'Market structure, scored.',
    es: 'Estructura de mercado, evaluada.',
    pt: 'Estrutura de mercado, pontuada.',
    ru: 'Структура рынка — под контролем.',
  );
  String get splashSub => t(
    'USDT · three venues · structure shift · MA regime · levels.\nEducational heuristics. Not signals.',
    es: 'USDT · tres exchanges · cambio de estructura · régimen MA · niveles.\nHeurísticas educativas. No son señales.',
    pt: 'USDT · três corretoras · mudança de estrutura · regime MA · níveis.\nHeurísticas educacionais. Não são sinais.',
    ru: 'USDT · три биржи · смена структуры · режим MA · уровни.\nОбразовательные эвристики. Не сигналы.',
  );
  String get splashCta => t(
    'ENTER RADAR',
    es: 'ENTRAR AL RADAR',
    pt: 'ENTRAR NO RADAR',
    ru: 'ОТКРЫТЬ РАДАР',
  );
  String get splashTag => 'FREE #2 · EN/ES/PT/RU';

  String get coachTitle => t('COACH', es: 'GUÍA', pt: 'GUIA', ru: 'ПОДСКАЗКА');
  String get coachBody => t(
    'Pick venues and TFs, then Run scan. Open a card and verify the chart — score is not an entry.',
    es: 'Elige exchanges y TF, luego inicia el escaneo. Abre una tarjeta y verifica el gráfico: el score no es una entrada.',
    pt: 'Escolha corretoras e TFs, depois inicie a varredura. Abra um cartão e confira o gráfico: score não é entrada.',
    ru: 'Сначала выбери биржи и TF, затем Run scan. Открывай карточку и сверяй график — score не равен входу.',
  );
  String get coachDismiss =>
      t('Got it', es: 'Entendido', pt: 'Entendi', ru: 'Понятно');
  String get firstRunKicker =>
      t('01 · START', es: '01 · INICIO', pt: '01 · INÍCIO', ru: '01 · СТАРТ');
  String get firstRunTitle1 => t(
    'Set the lens',
    es: 'Configura el enfoque',
    pt: 'Defina o filtro',
    ru: 'Выбери параметры',
  );
  String get firstRunBody1 => t(
    'Exchanges, timeframes and detectors are your filter. Don’t arm everything if you want a cleaner tape.',
    es: 'Exchanges, temporalidades y detectores son tu filtro. No actives todo si quieres una lista más limpia.',
    pt: 'Corretoras, períodos e detectores são seu filtro. Não ative tudo se quiser uma lista mais limpa.',
    ru: 'Биржи, таймфреймы и детекторы — это твой фильтр. Не включай всё сразу, если хочешь чище читать ленту.',
  );
  String get firstRunTitle2 => t(
    'Run the scan',
    es: 'Inicia el escaneo',
    pt: 'Inicie a varredura',
    ru: 'Запусти скан',
  );
  String get firstRunBody2 => t(
    'Radar walks USDT pairs in parallel. Progress shows venue and symbol.',
    es: 'Radar recorre pares USDT en paralelo. El progreso muestra exchange y símbolo.',
    pt: 'O Radar percorre pares USDT em paralelo. O progresso mostra corretora e símbolo.',
    ru: 'Радар параллельно обходит USDT-пары. Прогресс покажет площадку и символ.',
  );
  String get firstRunTitle3 => t(
    'Read the chart',
    es: 'Lee el gráfico',
    pt: 'Leia o gráfico',
    ru: 'Читай график',
  );
  String get firstRunBody3 => t(
    'Every hit is a heuristic. Open a card, check EMA/levels, use the glossary.',
    es: 'Cada hallazgo es una heurística. Abre una tarjeta, revisa EMA/niveles y usa el glosario.',
    pt: 'Cada detecção é uma heurística. Abra um cartão, confira EMA/níveis e use o glossário.',
    ru: 'Каждая детекция — эвристика. Открой карточку, проверь EMA/уровни, сверься с глоссарием.',
  );
  String get firstRunNext =>
      t('NEXT', es: 'SIGUIENTE', pt: 'PRÓXIMO', ru: 'ДАЛЕЕ');
  String get firstRunDone =>
      t('TO RADAR', es: 'AL RADAR', pt: 'PARA O RADAR', ru: 'К РАДАРУ');
  String get recapKicker => t(
    'SCAN COMPLETE',
    es: 'ESCANEO COMPLETO',
    pt: 'VARREDURA CONCLUÍDA',
    ru: 'СКАН ЗАВЕРШЁН',
  );
  String get recapTitle => t(
    'Radar recap',
    es: 'Resumen del radar',
    pt: 'Resumo do radar',
    ru: 'Сводка радара',
  );
  String get recapOpenResults => t(
    'OPEN RESULTS',
    es: 'ABRIR RESULTADOS',
    pt: 'ABRIR RESULTADOS',
    ru: 'К РЕЗУЛЬТАТАМ',
  );
  String get recapClose =>
      t('STAY', es: 'QUEDARME', pt: 'FICAR', ru: 'ОСТАТЬСЯ');
  String recapHits(int n) => t(
    '$n setups above threshold',
    es: '$n setups por encima del umbral',
    pt: '$n setups acima do limite',
    ru: '$n сетапов выше порога',
  );
  String get emptyResultsTitle => t(
    'Tape is empty',
    es: 'La lista está vacía',
    pt: 'A lista está vazia',
    ru: 'Лента пуста',
  );
  String get emptyResultsBody => t(
    'Run a scan from Radar. Setups will land here sorted by score.',
    es: 'Inicia un escaneo en Radar. Los setups aparecerán aquí ordenados por score.',
    pt: 'Inicie uma varredura no Radar. Os setups aparecerão aqui ordenados por score.',
    ru: 'Запусти скан во вкладке Радар. Здесь появятся сетапы по score.',
  );
  String get guideCta => t(
    'RADAR GUIDE',
    es: 'GUÍA DEL RADAR',
    pt: 'GUIA DO RADAR',
    ru: 'ГИД РАДАРА',
  );
  String get guideTitle => t(
    'Structure Radar guide',
    es: 'Guía de Structure Radar',
    pt: 'Guia do Structure Radar',
    ru: 'Гид Structure Radar',
  );
  String get eduOnly => t(
    'Educational only · no real money · no order execution',
    es: 'Solo educativo · sin dinero real · sin ejecución de órdenes',
    pt: 'Somente educacional · sem dinheiro real · sem execução de ordens',
    ru: 'Только обучение · без реальных денег · без исполнения ордеров',
  );
}
