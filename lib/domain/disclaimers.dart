import '../l10n/app_lang.dart';

class AppDisclaimers {
  static String shortBanner(AppLang lang) => lang == AppLang.ru
      ? 'Образовательные эвристики по графику. Не финансовый совет. Не брокер. Сделки не исполняются. Детекции могут ошибаться.'
      : 'Educational simulation of chart heuristics only. Not financial advice. Not a broker. No orders are placed. Detections can be wrong.';

  static String full(AppLang lang) {
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
