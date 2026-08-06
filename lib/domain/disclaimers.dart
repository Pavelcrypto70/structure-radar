import '../l10n/app_lang.dart';

class AppDisclaimers {
  static String shortBanner(AppLang lang) => switch (lang) {
    AppLang.es =>
      'Heurísticas educativas de gráficos. No es asesoramiento financiero ni un bróker. No se ejecutan órdenes. Las detecciones pueden fallar.',
    AppLang.pt =>
      'Heurísticas educacionais de gráficos. Não é aconselhamento financeiro nem corretora. Nenhuma ordem é executada. As detecções podem falhar.',
    AppLang.ru =>
      'Образовательные эвристики по графику. Не финансовый совет. Не брокер. Сделки не исполняются. Детекции могут ошибаться.',
    AppLang.en =>
      'Educational simulation of chart heuristics only. Not financial advice. Not a broker. No orders are placed. Detections can be wrong.',
  };

  static String full(AppLang lang) {
    if (lang == AppLang.es) {
      return '''
STRUCTURE RADAR — AVISOS IMPORTANTES

1) Finalidad educativa
Structure Radar es una herramienta educativa de visualización de mercado. Resalta condiciones heurísticas de gráficos; no ofrece asesoramiento de inversión, trading, fiscal ni legal.

2) No es un bróker / sin ejecución
La aplicación no acepta depósitos, no custodia activos y no coloca, enruta ni ejecuta órdenes en ningún exchange. Cualquier operación ocurre en plataformas de terceros bajo tu propia responsabilidad.

3) Sin promesa de rendimiento
La estructura pasada, los indicadores y el score no predicen resultados futuros. Un score alto no es una probabilidad de ganancia y los patrones pueden invalidarse de inmediato.

4) Límites de las heurísticas
Los detectores son aproximaciones basadas en reglas. Pueden omitir setups válidos, crear falsos positivos, retrasarse o diferir entre exchanges y temporalidades. Revisa siempre el contexto del gráfico.

5) Datos de terceros
Las velas provienen de API públicas de Binance, Bybit y Gate.io para pares spot USDT. Los datos pueden retrasarse, ser incompletos, diferir entre plataformas o no estar disponibles temporalmente.

6) Alertas de Telegram
Los perfiles preparan la entrega opcional a Telegram. Hasta conectar el backend del bot y activar el opt-in, no se envían mensajes.

7) Regulación y riesgo
Las normas sobre cripto difieren por país. Eres responsable de cumplir la ley aplicable. Operar e invertir implica un riesgo sustancial de pérdida; nunca uses dinero que no puedas perder.

Al usar Structure Radar confirmas que entiendes estos avisos.
''';
    }
    if (lang == AppLang.pt) {
      return '''
STRUCTURE RADAR — AVISOS IMPORTANTES

1) Finalidade educacional
Structure Radar é uma ferramenta educacional de visualização de mercado. Ela destaca condições heurísticas de gráficos e não oferece aconselhamento de investimento, trade, tributário ou jurídico.

2) Não é corretora / sem execução
O app não aceita depósitos, não guarda ativos e não envia, roteia ou executa ordens em nenhuma corretora. Qualquer operação ocorre em plataformas de terceiros sob sua própria responsabilidade.

3) Sem promessa de desempenho
Estrutura passada, indicadores e score não preveem resultados futuros. Score alto não é probabilidade de lucro e padrões podem ser invalidados imediatamente.

4) Limites das heurísticas
Os detectores são aproximações baseadas em regras. Podem perder setups válidos, criar falsos positivos, atrasar ou divergir entre corretoras e períodos. Sempre confira o contexto do gráfico.

5) Dados de terceiros
Os candles vêm de APIs públicas da Binance, Bybit e Gate.io para pares spot USDT. Os dados podem atrasar, ser incompletos, diferir entre corretoras ou ficar indisponíveis.

6) Alertas do Telegram
Os perfis preparam a entrega opcional ao Telegram. Até o backend do bot ser conectado e você ativar o opt-in, nenhuma mensagem será enviada.

7) Regulação e risco
As regras para cripto variam por país. Você é responsável por cumprir as leis aplicáveis. Operar e investir envolvem risco substancial de perda; nunca use dinheiro que não pode perder.

Ao usar o Structure Radar, você confirma que entende estes avisos.
''';
    }
    if (lang == AppLang.ru) {
      return '''
STRUCTURE RADAR — ВАЖНЫЕ ДИСКЛЕЙМЕРЫ

1) Образовательная цель
Structure Radar — образовательный инструмент визуализации рынка. Он подсвечивает эвристические условия графика (смена структуры, режимы скользящих, горизонтальные уровни). Это не инвестиционная, торговая, налоговая или юридическая рекомендация.

2) Не брокер / без исполнения
Приложение не принимает депозиты, не хранит активы и не размещает/не исполняет ордера ни на одной бирже. Любая торговля — только на сторонних площадках под вашу ответственность.

3) Нет обещания результата
Прошлая структура, индикаторы или score не предсказывают будущее. Высокий score — не вероятность прибыли. Рынок может сразу отменить паттерн.

4) Ограничения эвристик
Детекторы — правила. Они могут пропускать валидные сетапы, рисовать ложные, запаздывать и расходиться между биржами/таймфреймами. Всегда смотрите график сами.

5) Сторонние рыночные данные
Свечи берутся из публичных API (Binance, Bybit, Gate.io) по USDT spot. Данные могут быть задержаны, неполны, различаться между площадками или временно недоступны. Structure Radar не аффилирован с этими биржами, если прямо не указано иное.

6) Telegram-алерты (будущее)
Профили алертов и bridge payload готовят опциональную доставку в Telegram. Пока бэкенд бота не подключён и вы явно не включили opt-in, сообщения в Telegram не отправляются.

7) Регионы / регулирование
Правила крипты и деривативов отличаются по странам. Соблюдение законов — ваша ответственность. При сомнениях обратитесь к лицензированному специалисту.

8) Риск убытков
Торговля и инвестиции связаны с существенным риском потери средств и подходят не всем. Не торгуйте деньгами, которые не можете позволить себе потерять.

Используя Structure Radar, вы подтверждаете, что понимаете эти дисклеймеры.
''';
    }

    return '''
STRUCTURE RADAR — IMPORTANT DISCLAIMERS

1) Educational purpose
Structure Radar is an educational market-visualization tool. It highlights heuristic chart conditions (structure shifts, moving-average regimes, and horizontal support/resistance interactions). It does not provide investment, trading, tax, or legal advice.

2) Not a broker / no execution
This application does not accept deposits, does not custody assets, and does not place, route, or execute orders on any exchange. Any trading you do happens solely on third-party venues under your own accounts and responsibility.

3) No performance promise
Past market structure, indicator behavior, or detection scores do not predict future results. A high confidence score is not a probability of profit. Markets can and do invalidate patterns immediately.

4) Heuristic limitations
Detectors are rule-based approximations. They may miss valid setups, invent false setups, lag, or disagree across exchanges and timeframes. Always inspect the chart context yourself.

5) Third-party market data
Candle data is fetched from public exchange APIs (including Binance, Bybit, and Gate.io) for USDT spot pairs. Data may be delayed, incomplete, mismatched across venues, or temporarily unavailable. Structure Radar is not affiliated with or endorsed by those venues unless explicitly stated.

6) Telegram alerts (future)
In-app alert profiles and bridge payloads prepare optional Telegram delivery. Until a bot backend is connected and you explicitly opt in, no messages are sent to Telegram. You can disable opt-in at any time in Profile.

7) Regional / regulatory
Crypto and derivatives rules differ by country. You are responsible for complying with laws that apply to you. If you are unsure, consult a licensed professional.

8) Risk of loss
Trading and investing involve substantial risk of loss and are not suitable for every person. Never trade money you cannot afford to lose.

By using Structure Radar you acknowledge that you understand these disclaimers.
''';
  }
}
