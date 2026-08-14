import '../l10n/app_lang.dart';

class GlossaryLocalized {
  static List<Map<String, String>> entries(AppLang lang) {
    return [
      {
        'id': 'det_structure',
        'title': srLocalized(
          lang,
          'Structure Shift',
          es: 'Cambio de estructura',
          pt: 'Mudança de estrutura',
          ru: 'Смена структуры',
        ),
        'subtitle': srLocalized(
          lang,
          'Trend structure break (BOS-style heuristic)',
          es: 'Ruptura de estructura de tendencia (heurística tipo BOS)',
          pt: 'Quebra de estrutura de tendência (heurística estilo BOS)',
          ru: 'Слом трендовой структуры (BOS-эвристика)',
        ),
        'body': srLocalized(
          lang,
          'Structure Shift looks for a change in swing structure: higher-highs / higher-lows flipping into lower-highs / lower-lows (or the reverse).',
          es:
              'Busca un cambio en la estructura de swings: máximos/mínimos ascendentes que pasan a máximos/mínimos descendentes (o al revés). Un giro bajista suele ser el cierre bajo el último higher-low tras un uptrend; uno alcista — el cierre sobre el último lower-high tras un downtrend.',
          pt:
              'Procura mudança na estrutura de swings: topos/fundos ascendentes que viram descendentes (ou o inverso). Giro baixista costuma ser fechamento abaixo do último higher-low após uptrend; altista — acima do último lower-high após downtrend.',
          ru:
              'Ищем смену свинговой структуры: higher-highs / higher-lows переходят в lower-highs / lower-lows (или наоборот). Медвежий сдвиг обычно при пробое прошлого higher-low после аптренда; бычий — при пробое прошлого lower-high после даунтренда.',
        ),
        'mechanica': srLocalized(
          lang,
          '1) ATR% volatility gate — skip dead flats.\n2) Wider pivot window.\n3) Clean prior HH/HL or LH/LL only (no emerging).\n4) BOS: close clears swing by ≥0.35×ATR for 2 closes.',
          es:
              '1) Filtro ATR% — descartamos rangos muertos.\n2) Ventana de pivotes más amplia.\n3) Solo geometría limpia HH/HL o LH/LL (sin «emerging»).\n4) BOS: cierre ≥0.35×ATR sobre el swing en 2 cierres.',
          pt:
              '1) Filtro ATR% — descartamos ranges mortos.\n2) Janela de pivôs mais larga.\n3) Só geometria limpa HH/HL ou LH/LL (sem «emerging»).\n4) BOS: fechamento ≥0.35×ATR além do swing em 2 closes.',
          ru:
              '1) Фильтр волатильности (ATR%) — мёртвый флэт отбрасываем.\n2) Шире окно пивотов.\n3) Только чистая геометрия HH/HL или LH/LL (без «emerging»).\n4) BOS: close за свингом ≥0.35×ATR на 2 закрытиях.',
        ),
        'limitations': srLocalized(
          lang,
          'Still heuristic. Thin markets and wicks can fake a break. Not a trade signal.',
          es: 'Sigue siendo heurística. Mercados finos y mechas pueden simular rupturas. No es señal de trading.',
          pt: 'Ainda heurístico. Mercados finos e pavios podem simular rupturas. Não é sinal de trade.',
          ru: 'Эвристика. Тонкие рынки и фитили всё ещё могут обмануть. Не торговый сигнал.',
        ),
      },
      {
        'id': 'det_ma',
        'title': srLocalized(
          lang,
          'MA Regime',
          es: 'Régimen MA',
          pt: 'Regime MA',
          ru: 'Режим MA',
        ),
        'subtitle': srLocalized(
          lang,
          'Slow MA stack regime change',
          es: 'Cambio de régimen por medias móviles lentas',
          pt: 'Mudança de regime por médias móveis lentas',
          ru: 'Смена режима по медленным скользящим',
        ),
        'body': srLocalized(
          lang,
          'Slow EMA stack sized like a higher timeframe on this chart (15m→55/100/200, 30m→45/90/180, 1H→55/100/200, 4H→40/80/180, 1D→30/60/150). Emits only after confirm + long cooldown — not every scalp cross.',
          es:
              'Stack EMA lento «como TF superior» en el gráfico actual (15m→55/100/200, 30m→45/90/180, 1H→55/100/200, 4H→40/80/180, 1D→30/60/150). Señal solo tras confirmación y cooldown largo — no cada cruce de scalping.',
          pt:
              'Stack EMA lento «como TF superior» no gráfico atual (15m→55/100/200, 30m→45/90/180, 1H→55/100/200, 4H→40/80/180, 1D→30/60/150). Emite só após confirmação e cooldown longo — não cada cruzamento de scalp.',
          ru:
              'Медленный стек EMA «как с старшего ТФ» на текущем графике (15m→55/100/200, 30m→45/90/180, 1H→55/100/200, 4H→40/80/180, 1D→30/60/150). Сигнал только после подтверждения и длинного cooldown — не каждый скальп-кросс.',
        ),
        'mechanica': srLocalized(
          lang,
          '1) ATR% gate — skip flats.\n2) Slow stack per TF.\n3) Regime holds 3 closes.\n4) ≥18 bars since previous opposite regime.',
          es:
              '1) Filtro ATR% — sin rangos planos.\n2) Stack lento por TF.\n3) Régimen 3 cierres.\n4) ≥18 barras desde el régimen opuesto anterior.',
          pt:
              '1) Filtro ATR% — sem ranges planos.\n2) Stack lento por TF.\n3) Regime 3 closes.\n4) ≥18 barras desde o regime oposto anterior.',
          ru:
              '1) ATR%-гейт — флэт мимо.\n2) Медленный стек по TF.\n3) Режим держится 3 закрытия.\n4) ≥18 баров с прошлого противоположного режима.',
        ),
        'limitations': srLocalized(
          lang,
          'EMAs lag. Cooldown cuts whipsaws but also delays sharp reversals.',
          es: 'Las EMA van con retraso. El cooldown reduce whipsaws pero también retrasa giros bruscos.',
          pt: 'EMAs atrasam. Cooldown corta whipsaws mas também atrasa reversões bruscas.',
          ru: 'EMA запаздывают. Cooldown режет пилу, но и откладывает резкие развороты.',
        ),
      },
      {
        'id': 'det_levels',
        'title': srLocalized(
          lang,
          'Support / Resistance',
          es: 'Soporte / resistencia',
          pt: 'Suporte / resistência',
          ru: 'Поддержка / сопротивление',
        ),
        'subtitle': srLocalized(
          lang,
          'Horizontal level clusters from swing pivots',
          es: 'Zonas horizontales desde pivotes de swing',
          pt: 'Zonas horizontais a partir de pivôs de swing',
          ru: 'Горизонтальные зоны из свинговых пивотов',
        ),
        'body': srLocalized(
          lang,
          'Levels aggregates repeated swing highs/lows into horizontal zones and flags price interaction.',
          es: 'Agrupa máximos/mínimos de swing repetidos en zonas horizontales y marca la interacción del precio.',
          pt: 'Agrega topos/fundos de swing repetidos em zonas horizontais e sinaliza interação do preço.',
          ru: 'Собираем повторяющиеся хаи/лоу в горизонтальные зоны и помечаем взаимодействие цены с зоной.',
        ),
        'mechanica': srLocalized(
          lang,
          '1) Highs and lows separately.\n2) Tight cluster (~0.22×ATR).\n3) ≥3 time-separated touches.\n4) Only when price approaches an unbroken level.\n5) Optional triangle overlay.',
          es:
              '1) Máximos y mínimos por separado.\n2) Cluster estrecho (~0.22×ATR).\n3) ≥3 toques separados en el tiempo.\n4) Solo si el precio se acerca a un nivel intacto.\n5) Triángulo opcional.',
          pt:
              '1) Topos e fundos separados.\n2) Cluster apertado (~0.22×ATR).\n3) ≥3 toques separados no tempo.\n4) Só quando o preço se aproxima de nível intacto.\n5) Triângulo opcional.',
          ru:
              '1) Хаи и лои отдельно.\n2) Узкий кластер (~0.22×ATR).\n3) ≥3 касания с разнесением во времени.\n4) Только если цена подходит к несломанному уровню.\n5) Опционально треугольник.',
        ),
        'limitations': srLocalized(
          lang,
          'Markets respect zones, not ticks. Wick noise is common.',
          es: 'El mercado respeta zonas, no ticks. El ruido de mechas es habitual.',
          pt: 'O mercado respeita zonas, não ticks. Ruído de pavios é comum.',
          ru: 'Рынок уважает зоны, не тики. Ложные проколы фитилями обычны.',
        ),
      },
      {
        'id': 'exchanges',
        'title': srLocalized(
          lang,
          'Multi-exchange USDT scan',
          es: 'Escaneo USDT multi-exchange',
          pt: 'Scan USDT multi-corretora',
          ru: 'Мультибиржа USDT',
        ),
        'subtitle': 'Binance · Bybit · Gate.io',
        'body': srLocalized(
          lang,
          'Queries public spot USDT market data from three venues for comparable setups.',
          es: 'Consulta datos spot USDT públicos en tres exchanges para comparar el mismo setup con distinta liquidez.',
          pt: 'Consulta dados spot USDT públicos em três corretoras para comparar o mesmo setup com liquidez diferente.',
          ru: 'Сканируем только спотовые USDT-пары на трёх площадках, чтобы сравнивать один сетап на разной ликвидности.',
        ),
        'mechanica': srLocalized(
          lang,
          'Each venue has its own REST candles API. Short universe keeps scans practical. Browser demos may use a CORS relay.',
          es: 'Cada exchange tiene su API REST de velas. Universo corto para escaneos prácticos. En navegador puede usarse relay CORS.',
          pt: 'Cada corretora tem sua API REST de candles. Universo curto mantém scans práticos. No browser pode haver relay CORS.',
          ru: 'У каждой биржи свой REST klines и нейминг USDT. Юниверс короткий — чтобы полный скан был практичным. В браузере возможен CORS-relay.',
        ),
        'limitations': srLocalized(
          lang,
          'Prices differ by venue. A hit on one exchange is not a guarantee on another.',
          es: 'Precios y volumen difieren por exchange. Un hit en una no garantiza otro.',
          pt: 'Preços e volume diferem por corretora. Um hit numa não garante noutra.',
          ru: 'Цены/объёмы различаются. Хит на одной бирже ≠ гарантия на другой.',
        ),
      },
      {
        'id': 'score',
        'title': srLocalized(
          lang,
          'Confidence score',
          es: 'Puntuación de confianza',
          pt: 'Pontuação de confiança',
          ru: 'Confidence score',
        ),
        'subtitle': srLocalized(
          lang,
          '0–100 heuristic quality',
          es: 'Calidad heurística 0–100',
          pt: 'Qualidade heurística 0–100',
          ru: '0–100 качество эвристики',
        ),
        'body': srLocalized(
          lang,
          'Score estimates how clean the setup looks under detector rules — not profit probability.',
          es: 'La puntuación estima la «limpieza» del setup según reglas del detector — no probabilidad de beneficio.',
          pt: 'A pontuação estima o quão «limpo» o setup parece pelas regras do detector — não probabilidade de lucro.',
          ru: 'Score оценивает «чистоту» сетапа по правилам детектора — это не вероятность прибыли.',
        ),
        'mechanica': srLocalized(
          lang,
          'Blends recency, separation from noise, touch quality, and regime clarity.',
          es: 'Combina recencia, separación del ruido, calidad de toques y claridad del régimen.',
          pt: 'Combina recência, separação do ruído, qualidade de toques e clareza do regime.',
          ru: 'Смешиваем свежесть, отделение от шума, качество касаний и ясность режима.',
        ),
        'limitations': srLocalized(
          lang,
          'High score ≠ good trade.',
          es: 'Puntuación alta ≠ buen trade.',
          pt: 'Pontuação alta ≠ bom trade.',
          ru: 'Высокий score ≠ хорошая сделка.',
        ),
      },
      {
        'id': 'alert_profile',
        'title': srLocalized(
          lang,
          'Alert profile',
          es: 'Perfil de alertas',
          pt: 'Perfil de alertas',
          ru: 'Профиль алертов',
        ),
        'subtitle': srLocalized(
          lang,
          'Telegram-ready preferences',
          es: 'Preferencias listas para Telegram',
          pt: 'Preferências prontas para Telegram',
          ru: 'Настройки под будущий Telegram',
        ),
        'body': srLocalized(
          lang,
          'Stores which detectors/timeframes/exchanges/min score should fan out to Telegram later.',
          es: 'Guarda qué detectores, TF, exchanges y score mínimo deben enviarse a Telegram más adelante.',
          pt: 'Armazena quais detectores, TFs, corretoras e score mínimo devem ir ao Telegram depois.',
          ru: 'Профиль хранит детекторы, TF, биржи и мин. score для будущей доставки в Telegram.',
        ),
        'mechanica': srLocalized(
          lang,
          'Local JSON + bridge payload schema + on-device outbound queue.',
          es: 'JSON local + esquema bridge payload + cola de salida en el dispositivo.',
          pt: 'JSON local + schema bridge payload + fila de saída no dispositivo.',
          ru: 'JSON локально + schema bridge payload + локальная очередь событий.',
        ),
        'limitations': srLocalized(
          lang,
          'Until the bot backend is connected, events stay on-device only.',
          es: 'Hasta conectar el bot, los eventos quedan solo en el dispositivo.',
          pt: 'Até conectar o bot, eventos ficam só no dispositivo.',
          ru: 'Пока бот не подключён, события остаются на устройстве.',
        ),
      },
    ];
  }
}
