import 'app_lang.dart';

/// Literacy-path copy (EN/ES/PT/RU). Same `t()` style as [L10n].
/// Educational tone only — the app teaches reading structure, never actions.
class PathL10n {
  PathL10n(this.lang);
  final AppLang lang;

  String t(String en, {String? es, String? pt, String? ru}) => switch (lang) {
    AppLang.ru => ru ?? en,
    AppLang.es => es ?? en,
    AppLang.pt => pt ?? en,
    AppLang.en => en,
  };

  List<String> _l(
    List<String> en, {
    List<String>? es,
    List<String>? pt,
    List<String>? ru,
  }) => switch (lang) {
    AppLang.ru => ru ?? en,
    AppLang.es => es ?? en,
    AppLang.pt => pt ?? en,
    AppLang.en => en,
  };

  // ---------------------------------------------------------------- common
  String get next => t('Next', es: 'Siguiente', pt: 'Próximo', ru: 'Далее');
  String get later => t('Later', es: 'Más tarde', pt: 'Depois', ru: 'Позже');
  String get gotIt => t('Got it', es: 'Entendido', pt: 'Entendi', ru: 'Понятно');
  String get skip => t('Skip', es: 'Omitir', pt: 'Pular', ru: 'Пропустить');
  String get eduFooter => t(
    'Educational only · reading practice, not advice',
    es: 'Solo educativo · práctica de lectura, no consejo',
    pt: 'Somente educacional · prática de leitura, não conselho',
    ru: 'Только обучение · практика чтения, не совет',
  );

  // ----------------------------------------------------------- orientation
  String orientKicker(int step) => t(
    'ORIENTATION · $step / 3',
    es: 'ORIENTACIÓN · $step / 3',
    pt: 'ORIENTAÇÃO · $step / 3',
    ru: 'ОРИЕНТАЦИЯ · $step / 3',
  );

  String orientTitle(int step) => switch (step) {
    1 => t(
      'You know candles.\nNow read what they build.',
      es: 'Ya conoces las velas.\nAhora lee lo que forman.',
      pt: 'Você já conhece candles.\nAgora leia o que eles formam.',
      ru: 'Свечи ты знаешь.\nТеперь читай, что они строят.',
    ),
    2 => t(
      'Three lenses on one chart',
      es: 'Tres lentes sobre un gráfico',
      pt: 'Três lentes em um gráfico',
      ru: 'Три взгляда на один график',
    ),
    _ => t(
      'How it works: 4 short missions',
      es: 'Cómo funciona: 4 misiones cortas',
      pt: 'Como funciona: 4 missões curtas',
      ru: 'Как это устроено: 4 короткие миссии',
    ),
  };

  String orientBody(int step) => switch (step) {
    1 => t(
      'Structure Radar never tells you what to do. It scans USDT pairs and shows where a chart’s structure has changed — reading it is the skill you practice.',
      es: 'Structure Radar nunca te dice qué hacer. Escanea pares USDT y muestra dónde cambió la estructura del gráfico; leerla es la habilidad que practicas.',
      pt: 'O Structure Radar nunca diz o que fazer. Ele varre pares USDT e mostra onde a estrutura do gráfico mudou; ler isso é a habilidade que você pratica.',
      ru: 'Structure Radar ничего не советует делать. Он сканирует USDT-пары и показывает места, где у графика изменилась структура. Читать её — навык, который ты тренируешь.',
    ),
    2 => t(
      'Every hit belongs to one of three types. You will learn them one by one — that is what the missions are for.',
      es: 'Cada hallazgo es de uno de tres tipos. Los aprenderás uno a uno; para eso son las misiones.',
      pt: 'Cada detecção é de um dos três tipos. Você aprende um por vez; é para isso que servem as missões.',
      ru: 'Каждый хит — один из трёх типов. Разберём их по очереди: именно для этого нужны миссии.',
    ),
    _ => t(
      'One mission = one scan with one lens + opening a real hit on a chart. About 3–5 minutes each. Progress is saved.',
      es: 'Una misión = un escaneo con un lente + abrir un hallazgo real en el gráfico. Unos 3–5 minutos cada una. El progreso se guarda.',
      pt: 'Uma missão = uma varredura com uma lente + abrir uma detecção real no gráfico. Cerca de 3–5 minutos cada. O progresso é salvo.',
      ru: 'Одна миссия = один скан одним взглядом + открыть настоящий хит на графике. Около 3–5 минут на каждую. Прогресс сохраняется.',
    ),
  };

  List<String> orientPoints(int step) => switch (step) {
    1 => _l(
      [
        'The radar finds a place on the chart',
        'You open it and read the line yourself',
        'No advice — only reading practice',
      ],
      es: [
        'El radar encuentra un lugar en el gráfico',
        'Tú lo abres y lees la línea por ti mismo',
        'Sin consejos: solo práctica de lectura',
      ],
      pt: [
        'O radar encontra um ponto no gráfico',
        'Você abre e lê a linha por conta própria',
        'Sem conselhos: apenas prática de leitura',
      ],
      ru: [
        'Радар находит место на графике',
        'Ты открываешь его и сам читаешь линию',
        'Никаких советов — только практика чтения',
      ],
    ),
    2 => _l(
      [
        'Direction change (Structure Shift) — highs and lows swapped roles',
        'Strong trend (MA Regime) — price holds one side of the moving averages',
        'Price wall (Levels) — price keeps returning to the same zone',
      ],
      es: [
        'Cambio de dirección (Structure Shift): máximos y mínimos cambiaron de rol',
        'Tendencia fuerte (MA Regime): el precio se mantiene de un lado de las medias',
        'Pared de precio (Levels): el precio vuelve una y otra vez a la misma zona',
      ],
      pt: [
        'Mudança de direção (Structure Shift): topos e fundos trocaram de papel',
        'Tendência forte (MA Regime): o preço fica de um lado das médias',
        'Parede de preço (Levels): o preço volta várias vezes à mesma zona',
      ],
      ru: [
        'Смена направления (Structure Shift) — максимумы и минимумы поменялись ролями',
        'Сильный тренд (MA Regime) — цена держится по одну сторону скользящих',
        'Цена у стенки (Levels) — цена снова и снова возвращается в одну зону',
      ],
    ),
    _ => _l(
      [
        'Press Find — the radar scans live pairs',
        'Open a hit and look at the line on the chart',
        'Mission 4 opens the full radar: tabs, filters, glossary',
        'An empty scan is a lesson too — we explain why',
      ],
      es: [
        'Pulsa Buscar: el radar escanea pares en vivo',
        'Abre un hallazgo y mira la línea en el gráfico',
        'La misión 4 abre el radar completo: pestañas, filtros, glosario',
        'Un escaneo vacío también es una lección: te explicamos por qué',
      ],
      pt: [
        'Toque em Buscar: o radar varre pares ao vivo',
        'Abra uma detecção e veja a linha no gráfico',
        'A missão 4 abre o radar completo: abas, filtros, glossário',
        'Uma varredura vazia também é lição: explicamos o porquê',
      ],
      ru: [
        'Нажми «Найти» — радар сканирует живые пары',
        'Открой хит и посмотри линию на графике',
        'Миссия 4 открывает полный радар: вкладки, фильтры, глоссарий',
        'Пустой скан — тоже урок: объясним почему',
      ],
    ),
  };

  String orientCta(int step) => step >= 3
      ? t(
          'TO MISSIONS',
          es: 'A LAS MISIONES',
          pt: 'ÀS MISSÕES',
          ru: 'К МИССИЯМ',
        )
      : t('NEXT', es: 'SIGUIENTE', pt: 'PRÓXIMO', ru: 'ДАЛЕЕ');

  // ------------------------------------------------------- literacy home
  String get homeKicker => t(
    'LITERACY PATH',
    es: 'RUTA DE LECTURA',
    pt: 'TRILHA DE LEITURA',
    ru: 'ПУТЬ ЧТЕНИЯ',
  );
  String get homeTitle => t(
    'Learn to read market structure',
    es: 'Aprende a leer la estructura del mercado',
    pt: 'Aprenda a ler a estrutura do mercado',
    ru: 'Учимся читать структуру рынка',
  );
  String get homeSub => t(
    'Four missions, one lens at a time. Each ends with a real chart you open and read.',
    es: 'Cuatro misiones, un lente a la vez. Cada una termina con un gráfico real que abres y lees.',
    pt: 'Quatro missões, uma lente por vez. Cada uma termina com um gráfico real que você abre e lê.',
    ru: 'Четыре миссии, по одному взгляду за раз. Каждая заканчивается реальным графиком, который ты открываешь и читаешь.',
  );
  String homeProgress(int done) => t(
    'Missions: $done / 4',
    es: 'Misiones: $done / 4',
    pt: 'Missões: $done / 4',
    ru: 'Миссии: $done / 4',
  );

  String missionName(int n) => switch (n) {
    1 => t(
      'Direction change',
      es: 'Cambio de dirección',
      pt: 'Mudança de direção',
      ru: 'Смена направления',
    ),
    2 => t(
      'Strong trend',
      es: 'Tendencia fuerte',
      pt: 'Tendência forte',
      ru: 'Сильный тренд',
    ),
    3 => t(
      'Price wall',
      es: 'Pared de precio',
      pt: 'Parede de preço',
      ru: 'Цена у стенки',
    ),
    _ => t(
      'Full radar',
      es: 'Radar completo',
      pt: 'Radar completo',
      ru: 'Полный радар',
    ),
  };

  String missionTech(int n) => switch (n) {
    1 => 'Structure Shift',
    2 => 'MA Regime',
    3 => 'Levels',
    _ => t(
      'All three lenses',
      es: 'Los tres lentes',
      pt: 'As três lentes',
      ru: 'Все три взгляда',
    ),
  };

  String missionGoal(int n) => switch (n) {
    1 => t(
      'Find a chart where highs and lows changed direction.',
      es: 'Encuentra un gráfico donde máximos y mínimos cambiaron de dirección.',
      pt: 'Encontre um gráfico em que topos e fundos mudaram de direção.',
      ru: 'Найди график, где максимумы и минимумы сменили направление.',
    ),
    2 => t(
      'Find a chart where price holds one side of the moving averages.',
      es: 'Encuentra un gráfico donde el precio se mantiene de un lado de las medias.',
      pt: 'Encontre um gráfico em que o preço fica de um lado das médias.',
      ru: 'Найди график, где цена держится по одну сторону скользящих.',
    ),
    3 => t(
      'Find a zone that price has touched several times.',
      es: 'Encuentra una zona que el precio ha tocado varias veces.',
      pt: 'Encontre uma zona que o preço tocou várias vezes.',
      ru: 'Найди зону, которой цена касалась несколько раз.',
    ),
    _ => t(
      'Scan with all lenses and open any hit. Name its type before you read the card.',
      es: 'Escanea con todos los lentes y abre cualquier hallazgo. Nombra su tipo antes de leer la tarjeta.',
      pt: 'Varra com todas as lentes e abra qualquer detecção. Diga o tipo antes de ler o cartão.',
      ru: 'Просканируй всеми взглядами и открой любой хит. Назови его тип, прежде чем читать карточку.',
    ),
  };

  /// Shown on the detection screen during the mission.
  String missionLookFor(int n) => switch (n) {
    1 => t(
      'Look at the line: it marks the swing price closed beyond. Before it highs and lows moved one way; after it — the other.',
      es: 'Mira la línea: marca el swing que el precio superó con su cierre. Antes, máximos y mínimos iban en un sentido; después, en el otro.',
      pt: 'Veja a linha: ela marca o swing que o preço superou no fechamento. Antes, topos e fundos iam em um sentido; depois, no outro.',
      ru: 'Смотри на линию: она отмечает свинг, за который цена закрылась. До неё максимумы и минимумы шли в одну сторону, после — в другую.',
    ),
    2 => t(
      'Look at the moving averages: price stays on one side and the lines point the same way. That is a regime, not a promise it continues.',
      es: 'Mira las medias móviles: el precio se mantiene de un lado y las líneas apuntan igual. Es un régimen, no una promesa de continuidad.',
      pt: 'Veja as médias móveis: o preço fica de um lado e as linhas apontam para o mesmo lado. É um regime, não uma promessa de continuidade.',
      ru: 'Смотри на скользящие: цена держится по одну сторону, линии смотрят в одну сторону. Это режим, а не обещание продолжения.',
    ),
    3 => t(
      'Count the touches of the zone: more clean reactions = a more visible wall. A wall can break — you only read it.',
      es: 'Cuenta los toques de la zona: más reacciones limpias = pared más visible. Una pared puede romperse; tú solo la lees.',
      pt: 'Conte os toques na zona: mais reações limpas = parede mais visível. Uma parede pode romper; você apenas a lê.',
      ru: 'Посчитай касания зоны: чем больше чистых реакций, тем заметнее стенка. Стенка может сломаться — ты её только читаешь.',
    ),
    _ => t(
      'Which lens is this hit — structure, trend or wall? Say it first, then compare with the card text.',
      es: '¿Qué lente es este hallazgo: estructura, tendencia o pared? Dilo primero y compara con el texto de la tarjeta.',
      pt: 'Qual lente é esta detecção: estrutura, tendência ou parede? Diga primeiro e compare com o texto do cartão.',
      ru: 'Какой это взгляд: структура, тренд или стенка? Скажи сам, потом сверься с текстом карточки.',
    ),
  };

  String missionStart(int n) => t(
    'START MISSION $n',
    es: 'INICIAR MISIÓN $n',
    pt: 'INICIAR MISSÃO $n',
    ru: 'НАЧАТЬ МИССИЮ $n',
  );
  String get missionLocked => t(
    'Finish the previous mission',
    es: 'Termina la misión anterior',
    pt: 'Termine a missão anterior',
    ru: 'Сначала пройди предыдущую',
  );
  String get missionDoneLabel =>
      t('DONE', es: 'LISTO', pt: 'FEITO', ru: 'ГОТОВО');

  String get tabsLockedMission => t(
    'Finish the mission to unlock the tabs.',
    es: 'Termina la misión para desbloquear las pestañas.',
    pt: 'Termine a missão para liberar as abas.',
    ru: 'Пройди миссию — вкладки откроются.',
  );

  // ------------------------------------------------------ mission banner
  String bannerKicker(int n) => t(
    'MISSION $n / 4',
    es: 'MISIÓN $n / 4',
    pt: 'MISSÃO $n / 4',
    ru: 'МИССИЯ $n / 4',
  );
  String get bannerFind => t(
    'Press “Find” below — the radar scans with this lens only.',
    es: 'Pulsa «Buscar» abajo: el radar escanea solo con este lente.',
    pt: 'Toque em “Buscar” abaixo: o radar varre só com esta lente.',
    ru: 'Нажми «Найти» внизу — радар просканирует только этим взглядом.',
  );
  String get bannerScanning => t(
    'Scanning… hits appear as they are found.',
    es: 'Escaneando… los hallazgos aparecen al encontrarse.',
    pt: 'Varrendo… as detecções aparecem conforme são achadas.',
    ru: 'Сканирую… хиты появляются по мере поиска.',
  );
  String bannerOpenHit(int n) => n == 4
      ? t(
          'Hits found. Tap any card to open its chart.',
          es: 'Hay hallazgos. Toca cualquier tarjeta para abrir su gráfico.',
          pt: 'Há detecções. Toque em qualquer cartão para abrir o gráfico.',
          ru: 'Хиты найдены. Нажми любую карточку — откроется график.',
        )
      : t(
          'Hits found. Tap a “${missionName(n)}” card to open its chart.',
          es: 'Hay hallazgos. Toca una tarjeta «${missionName(n)}» para abrir su gráfico.',
          pt: 'Há detecções. Toque em um cartão «${missionName(n)}» para abrir o gráfico.',
          ru: 'Хиты найдены. Нажми карточку «${missionName(n)}» — откроется график.',
        );
  String get bannerReady => t(
    'You opened a matching hit. Finish the mission.',
    es: 'Abriste un hallazgo válido. Termina la misión.',
    pt: 'Você abriu uma detecção válida. Conclua a missão.',
    ru: 'Ты открыл подходящий хит. Завершай миссию.',
  );
  String get bannerEmpty => t(
    'No hits for this lens this time. That is normal — see why.',
    es: 'Sin hallazgos para este lente esta vez. Es normal: mira por qué.',
    pt: 'Sem detecções para esta lente desta vez. É normal: veja por quê.',
    ru: 'В этот раз хитов для этого взгляда нет. Это нормально — смотри почему.',
  );
  String get bannerComplete => t(
    'COMPLETE MISSION',
    es: 'TERMINAR MISIÓN',
    pt: 'CONCLUIR MISSÃO',
    ru: 'ЗАВЕРШИТЬ МИССИЮ',
  );
  String get bannerWhyEmpty => t(
    'WHY EMPTY?',
    es: '¿POR QUÉ VACÍO?',
    pt: 'POR QUE VAZIO?',
    ru: 'ПОЧЕМУ ПУСТО?',
  );
  String get bannerBack =>
      t('Missions', es: 'Misiones', pt: 'Missões', ru: 'Миссии');
  String lensLine(String detector, String tfs, int minScore) => t(
    'Lens: $detector · $tfs · score ≥ $minScore',
    es: 'Lente: $detector · $tfs · puntuación ≥ $minScore',
    pt: 'Lente: $detector · $tfs · pontuação ≥ $minScore',
    ru: 'Взгляд: $detector · $tfs · скор ≥ $minScore',
  );
  String get lensAll => t(
    'all lenses',
    es: 'todos los lentes',
    pt: 'todas as lentes',
    ru: 'все взгляды',
  );

  // --------------------------------------------------------- empty sheet
  String get emptyKicker =>
      t('NO HITS', es: 'SIN HALLAZGOS', pt: 'SEM DETECÇÕES', ru: 'ХИТОВ НЕТ');
  String get emptyTitle => t(
    'An empty scan is not a failure',
    es: 'Un escaneo vacío no es un fallo',
    pt: 'Uma varredura vazia não é falha',
    ru: 'Пустой скан — не ошибка',
  );
  String get emptyBody => t(
    'The radar shows only clear structure. When the market is quiet or pairs sit in a range, there is nothing to read — you will see this often.',
    es: 'El radar muestra solo estructura clara. Si el mercado está tranquilo o los pares están en rango, no hay nada que leer; lo verás a menudo.',
    pt: 'O radar mostra só estrutura clara. Com o mercado calmo ou pares em range, não há o que ler; você verá isso com frequência.',
    ru: 'Радар показывает только чёткую структуру. Когда рынок тихий или пары стоят в диапазоне, читать нечего — ты будешь видеть это часто.',
  );
  List<String> get emptyPoints => _l(
    [
      'Quiet market: nothing clear to read right now',
      'Try again after a candle closes or later today',
      'Knowing an empty result is normal is part of reading',
    ],
    es: [
      'Mercado tranquilo: nada claro que leer ahora',
      'Prueba de nuevo tras cerrar una vela o más tarde',
      'Saber que un resultado vacío es normal también es leer',
    ],
    pt: [
      'Mercado calmo: nada claro para ler agora',
      'Tente de novo após o fechamento de um candle ou mais tarde',
      'Saber que vazio é normal também faz parte de ler',
    ],
    ru: [
      'Тихий рынок: сейчас нечего читать',
      'Повтори после закрытия свечи или позже сегодня',
      'Понимать, что пустой результат — норма, тоже часть чтения',
    ],
  );
  String get emptyContinue => t(
    'UNDERSTOOD — CONTINUE',
    es: 'ENTENDIDO — CONTINUAR',
    pt: 'ENTENDI — CONTINUAR',
    ru: 'ПОНЯТНО — ДАЛЬШЕ',
  );
  String get emptyRetry => t(
    'Scan again',
    es: 'Escanear de nuevo',
    pt: 'Varrer de novo',
    ru: 'Сканировать ещё раз',
  );

  // -------------------------------------------------------- detail CTA
  String missionCompleteNext(int n) => n >= 4
      ? t(
          'Mission complete — open the radar',
          es: 'Misión completa — abrir el radar',
          pt: 'Missão concluída — abrir o radar',
          ru: 'Миссия пройдена — к радару',
        )
      : t(
          'Mission complete — Next',
          es: 'Misión completa — Siguiente',
          pt: 'Missão concluída — Próxima',
          ru: 'Миссия пройдена — дальше',
        );
  String get detailCoachKicker =>
      t('WHAT TO LOOK AT', es: 'QUÉ MIRAR', pt: 'O QUE OLHAR', ru: 'НА ЧТО СМОТРЕТЬ');

  // ------------------------------------------------------------ phase 2
  String get p2Kicker => t(
    'MISSIONS DONE',
    es: 'MISIONES COMPLETAS',
    pt: 'MISSÕES CONCLUÍDAS',
    ru: 'МИССИИ ПРОЙДЕНЫ',
  );
  String get p2Title => t(
    'You can read three lenses.\nNow make it a habit.',
    es: 'Ya lees tres lentes.\nAhora hazlo un hábito.',
    pt: 'Você já lê três lentes.\nAgora faça disso um hábito.',
    ru: 'Три взгляда ты уже читаешь.\nТеперь сделай это привычкой.',
  );
  String get p2Body => t(
    'The full radar is open: filters, results, glossary. One scan and one opened hit a day train your eye better than one long session a week.',
    es: 'El radar completo está abierto: filtros, resultados, glosario. Un escaneo y un hallazgo abierto al día entrenan más tu ojo que una sesión larga a la semana.',
    pt: 'O radar completo está aberto: filtros, resultados, glossário. Uma varredura e uma detecção aberta por dia treinam mais o olhar do que uma sessão longa por semana.',
    ru: 'Полный радар открыт: фильтры, результаты, глоссарий. Один скан и один открытый хит в день тренируют глаз лучше, чем одна долгая сессия в неделю.',
  );
  List<String> get p2Points => _l(
    [
      'Daily: scan + open one hit',
      '3 hits opened → tour of the detector glossary',
      '3 habit days → community · 7 days → structured learning',
    ],
    es: [
      'Cada día: escaneo + abrir un hallazgo',
      '3 hallazgos abiertos → tour del glosario de detectores',
      '3 días de hábito → comunidad · 7 días → aprendizaje estructurado',
    ],
    pt: [
      'Todo dia: varredura + abrir uma detecção',
      '3 detecções abertas → tour do glossário dos detectores',
      '3 dias de hábito → comunidade · 7 dias → aprendizado estruturado',
    ],
    ru: [
      'Каждый день: скан + один открытый хит',
      '3 открытых хита → тур по глоссарию детекторов',
      '3 дня привычки → сообщество · 7 дней → системное обучение',
    ],
  );
  String get p2Cta => t(
    'DAILY HABIT',
    es: 'HÁBITO DIARIO',
    pt: 'HÁBITO DIÁRIO',
    ru: 'ЕЖЕДНЕВНАЯ ПРИВЫЧКА',
  );

  // ------------------------------------------------------ glossary tour
  String get gtKicker => t(
    'GLOSSARY TOUR',
    es: 'TOUR DEL GLOSARIO',
    pt: 'TOUR DO GLOSSÁRIO',
    ru: 'ТУР ПО ГЛОССАРИЮ',
  );
  String get gtTitle => t(
    'Three detectors, three ways to read',
    es: 'Tres detectores, tres formas de leer',
    pt: 'Três detectores, três formas de ler',
    ru: 'Три детектора — три способа читать',
  );
  String get gtLookFor =>
      t('LOOK FOR', es: 'BUSCA', pt: 'PROCURE', ru: 'ЧТО ИСКАТЬ');
  String get gtLimit =>
      t('LIMIT', es: 'LÍMITE', pt: 'LIMITE', ru: 'ОГРАНИЧЕНИЕ');
  String gtCounter(int i, int n) => '$i / $n';

  // -------------------------------------------------------------- club
  String get clubKicker =>
      t('COMMUNITY', es: 'COMUNIDAD', pt: 'COMUNIDADE', ru: 'СООБЩЕСТВО');
  String get clubTitle => t(
    'Reading is easier together',
    es: 'Leer es más fácil en compañía',
    pt: 'Ler é mais fácil em grupo',
    ru: 'Читать вместе проще',
  );
  String get clubBody => t(
    'You have kept the habit for 3 days. Desk Club is our Telegram community for people learning to read charts.',
    es: 'Llevas 3 días con el hábito. Desk Club es nuestra comunidad de Telegram para quienes aprenden a leer gráficos.',
    pt: 'Você mantém o hábito há 3 dias. O Desk Club é nossa comunidade no Telegram para quem aprende a ler gráficos.',
    ru: 'Ты держишь привычку уже 3 дня. Desk Club — наше Telegram-сообщество для тех, кто учится читать графики.',
  );
  List<String> get clubPoints => _l(
    [
      'Ask about a hit you could not read',
      'See how others read the same structure',
      'Free — leave any time',
    ],
    es: [
      'Pregunta por un hallazgo que no pudiste leer',
      'Mira cómo otros leen la misma estructura',
      'Gratis — sal cuando quieras',
    ],
    pt: [
      'Pergunte sobre uma detecção que você não conseguiu ler',
      'Veja como outros leem a mesma estrutura',
      'Grátis — saia quando quiser',
    ],
    ru: [
      'Спроси про хит, который не получилось прочитать',
      'Посмотри, как другие читают ту же структуру',
      'Бесплатно — выйти можно в любой момент',
    ],
  );
  String get clubOpen => t(
    'OPEN COMMUNITY',
    es: 'ABRIR COMUNIDAD',
    pt: 'ABRIR COMUNIDADE',
    ru: 'ОТКРЫТЬ СООБЩЕСТВО',
  );

  // ----------------------------------------------------------- academy
  String get acKicker => t(
    'NEXT LEVEL',
    es: 'SIGUIENTE NIVEL',
    pt: 'PRÓXIMO NÍVEL',
    ru: 'СЛЕДУЮЩИЙ УРОВЕНЬ',
  );
  String get acTitle => t(
    'Want a systematic course?',
    es: '¿Quieres un curso sistemático?',
    pt: 'Quer um curso sistemático?',
    ru: 'Хочется системного курса?',
  );
  String get acBody => t(
    'Seven habit days — your eye is trained. Trade Master is our separate learning app with structured lessons, quizzes and a journal. Entirely optional: Structure Radar stays free.',
    es: 'Siete días de hábito: tu ojo ya está entrenado. Trade Master es nuestra app de aprendizaje aparte, con lecciones estructuradas, quizzes y diario. Totalmente opcional: Structure Radar sigue gratis.',
    pt: 'Sete dias de hábito: seu olhar está treinado. O Trade Master é nosso app de aprendizado separado, com lições estruturadas, quizzes e diário. Totalmente opcional: o Structure Radar continua grátis.',
    ru: 'Семь дней привычки — глаз уже натренирован. Trade Master — наше отдельное приложение с системными уроками, квизами и дневником. Это по желанию: Structure Radar остаётся бесплатным.',
  );
  List<String> get acPoints => _l(
    [
      'Short lessons on structure, trend and levels',
      'Quizzes to check your reading',
      'No pressure — close this and keep scanning',
    ],
    es: [
      'Lecciones cortas sobre estructura, tendencia y niveles',
      'Quizzes para comprobar tu lectura',
      'Sin presión: cierra esto y sigue escaneando',
    ],
    pt: [
      'Lições curtas sobre estrutura, tendência e níveis',
      'Quizzes para checar sua leitura',
      'Sem pressão: feche isto e continue varrendo',
    ],
    ru: [
      'Короткие уроки о структуре, тренде и уровнях',
      'Квизы, чтобы проверить своё чтение',
      'Без давления — закрой и продолжай сканировать',
    ],
  );
  String get acLearn =>
      t('LEARN MORE', es: 'SABER MÁS', pt: 'SAIBA MAIS', ru: 'УЗНАТЬ БОЛЬШЕ');

  // --------------------------------------------------------- next step
  String get nsKicker =>
      t('NEXT STEP', es: 'SIGUIENTE PASO', pt: 'PRÓXIMO PASSO', ru: 'СЛЕДУЮЩИЙ ШАГ');
  String nsMissionTitle(int n) => t(
    'Finish mission $n: ${missionName(n)}',
    es: 'Termina la misión $n: ${missionName(n)}',
    pt: 'Conclua a missão $n: ${missionName(n)}',
    ru: 'Закончи миссию $n: ${missionName(n)}',
  );
  String get nsMissionCta =>
      t('CONTINUE', es: 'CONTINUAR', pt: 'CONTINUAR', ru: 'ПРОДОЛЖИТЬ');
  String get nsDailyTitle => t(
    'Daily scan',
    es: 'Escaneo diario',
    pt: 'Varredura diária',
    ru: 'Ежедневный скан',
  );
  String nsDailyBody(int days) => t(
    'One scan and one opened hit count as a habit day. Habit days so far: $days.',
    es: 'Un escaneo y un hallazgo abierto cuentan como día de hábito. Días de hábito hasta ahora: $days.',
    pt: 'Uma varredura e uma detecção aberta contam como dia de hábito. Dias de hábito até agora: $days.',
    ru: 'Один скан и один открытый хит — это день привычки. Дней привычки пока: $days.',
  );
  String get nsDailyCta =>
      t('DAILY SCAN', es: 'ESCANEO DIARIO', pt: 'VARREDURA DIÁRIA', ru: 'СКАН ДНЯ');
  String get nsCheckInTitle => t(
    'Scan done — close the day',
    es: 'Escaneo hecho — cierra el día',
    pt: 'Varredura feita — feche o dia',
    ru: 'Скан сделан — закрой день',
  );
  String get nsCheckInBody => t(
    'Open one hit from the results, or check in if you only studied the list.',
    es: 'Abre un hallazgo de los resultados o marca el día si solo revisaste la lista.',
    pt: 'Abra uma detecção dos resultados ou faça check-in se só olhou a lista.',
    ru: 'Открой один хит из результатов или отметь день, если изучал только список.',
  );
  String get nsCheckInCta =>
      t('CHECK IN', es: 'MARCAR DÍA', pt: 'MARCAR DIA', ru: 'ОТМЕТИТЬ ДЕНЬ');
  String get nsOpenResults =>
      t('Results', es: 'Resultados', pt: 'Resultados', ru: 'Результаты');
  String nsGlossaryTitle(int left) => t(
    'Open $left more hits for the glossary tour',
    es: 'Abre $left hallazgos más para el tour del glosario',
    pt: 'Abra mais $left detecções para o tour do glossário',
    ru: 'Осталось открыть хитов для тура по глоссарию: $left',
  );
  String nsGlossaryBody(int have) => t(
    'The tour explains how to read each detector. Opened: $have / 3.',
    es: 'El tour explica cómo leer cada detector. Abiertos: $have / 3.',
    pt: 'O tour explica como ler cada detector. Abertas: $have / 3.',
    ru: 'Тур объясняет, как читать каждый детектор. Открыто: $have / 3.',
  );
  String nsClubTitle(int left) => t(
    'Days to the community: $left',
    es: 'Días para la comunidad: $left',
    pt: 'Dias para a comunidade: $left',
    ru: 'Дней до сообщества: $left',
  );
  String nsClubBody(int have) => t(
    'Habit days: $have / 3. Come back tomorrow — one scan is enough.',
    es: 'Días de hábito: $have / 3. Vuelve mañana: un escaneo basta.',
    pt: 'Dias de hábito: $have / 3. Volte amanhã: uma varredura basta.',
    ru: 'Дней привычки: $have / 3. Возвращайся завтра — хватит одного скана.',
  );
  String nsAcademyTitle(int left) => t(
    'Days to structured learning: $left',
    es: 'Días para el aprendizaje estructurado: $left',
    pt: 'Dias para o aprendizado estruturado: $left',
    ru: 'Дней до системного обучения: $left',
  );
  String nsAcademyBody(int have) => t(
    'Habit days: $have / 7. Keep the rhythm.',
    es: 'Días de hábito: $have / 7. Mantén el ritmo.',
    pt: 'Dias de hábito: $have / 7. Mantenha o ritmo.',
    ru: 'Дней привычки: $have / 7. Держи ритм.',
  );
  String get nsDoneTitle =>
      t('Day clear', es: 'Día completo', pt: 'Dia completo', ru: 'День закрыт');
  String get nsDoneBody => t(
    'Everything for today is done. Free scans are always available — or see you tomorrow.',
    es: 'Todo listo por hoy. Los escaneos libres siempre están disponibles, o nos vemos mañana.',
    pt: 'Tudo certo por hoje. As varreduras livres estão sempre disponíveis, ou até amanhã.',
    ru: 'На сегодня всё. Свободные сканы всегда доступны — или до завтра.',
  );
  String get nsMap => t(
    'Journey map',
    es: 'Mapa del camino',
    pt: 'Mapa da jornada',
    ru: 'Карта пути',
  );

  // -------------------------------------------------------- journey map
  String get jmTitle => nsMap;
  String get jmSub => t(
    'Your literacy path: where you are and what unlocks next.',
    es: 'Tu ruta de lectura: dónde estás y qué se desbloquea después.',
    pt: 'Sua trilha de leitura: onde você está e o que libera depois.',
    ru: 'Твой путь чтения: где ты сейчас и что откроется дальше.',
  );
  String get jmDone => t('DONE', es: 'LISTO', pt: 'FEITO', ru: 'ГОТОВО');
  String get jmNow => t('NOW', es: 'AHORA', pt: 'AGORA', ru: 'СЕЙЧАС');
  String get jmNext => t('NEXT', es: 'LUEGO', pt: 'DEPOIS', ru: 'ДАЛЕЕ');

  String jmPhaseTitle(String id) => switch (id) {
    'gate' => t('Start', es: 'Inicio', pt: 'Início', ru: 'Старт'),
    'orient' => t(
      'Orientation',
      es: 'Orientación',
      pt: 'Orientação',
      ru: 'Ориентация',
    ),
    'missions' => t('Missions', es: 'Misiones', pt: 'Missões', ru: 'Миссии'),
    'p2' => t(
      'Daily habit',
      es: 'Hábito diario',
      pt: 'Hábito diário',
      ru: 'Ежедневная привычка',
    ),
    'glossary' => t(
      'Glossary tour',
      es: 'Tour del glosario',
      pt: 'Tour do glossário',
      ru: 'Тур по глоссарию',
    ),
    'club' => t(
      'Community',
      es: 'Comunidad',
      pt: 'Comunidade',
      ru: 'Сообщество',
    ),
    _ => t(
      'Structured learning',
      es: 'Aprendizaje estructurado',
      pt: 'Aprendizado estruturado',
      ru: 'Системное обучение',
    ),
  };

  String jmPhaseBody(String id) => switch (id) {
    'gate' => t(
      'Language, intro, disclaimer',
      es: 'Idioma, intro, aviso legal',
      pt: 'Idioma, intro, aviso legal',
      ru: 'Язык, заставка, дисклеймер',
    ),
    'orient' => t(
      '3 screens: what the radar is and is not',
      es: '3 pantallas: qué es y qué no es el radar',
      pt: '3 telas: o que o radar é e não é',
      ru: '3 экрана: чем радар является и чем нет',
    ),
    'missions' => t(
      'Structure → trend → levels → full radar',
      es: 'Estructura → tendencia → niveles → radar completo',
      pt: 'Estrutura → tendência → níveis → radar completo',
      ru: 'Структура → тренд → уровни → полный радар',
    ),
    'p2' => t(
      'Free radar, filters, results, daily scan',
      es: 'Radar libre, filtros, resultados, escaneo diario',
      pt: 'Radar livre, filtros, resultados, varredura diária',
      ru: 'Свободный радар, фильтры, результаты, скан дня',
    ),
    'glossary' => t(
      'Opens after 3 hits: how to read each detector',
      es: 'Se abre tras 3 hallazgos: cómo leer cada detector',
      pt: 'Abre após 3 detecções: como ler cada detector',
      ru: 'Откроется после 3 хитов: как читать каждый детектор',
    ),
    'club' => t(
      'Opens after 3 habit days: Desk Club',
      es: 'Se abre tras 3 días de hábito: Desk Club',
      pt: 'Abre após 3 dias de hábito: Desk Club',
      ru: 'Откроется после 3 дней привычки: Desk Club',
    ),
    _ => t(
      'After 7 habit days: optional lessons',
      es: 'Tras 7 días de hábito: lecciones opcionales',
      pt: 'Após 7 dias de hábito: lições opcionais',
      ru: 'После 7 дней привычки: уроки по желанию',
    ),
  };

  String jmMetric(String id, {int a = 0, int b = 0}) => '$a / $b';

  // ------------------------------------------------------------ profile
  String get profileMapTitle => nsMap;
  String get profileMapBody => t(
    'Missions, habit days and what unlocks next.',
    es: 'Misiones, días de hábito y qué se desbloquea después.',
    pt: 'Missões, dias de hábito e o que libera depois.',
    ru: 'Миссии, дни привычки и что откроется дальше.',
  );
  String get profileMapCta =>
      t('OPEN MAP', es: 'ABRIR MAPA', pt: 'ABRIR MAPA', ru: 'ОТКРЫТЬ КАРТУ');
}
