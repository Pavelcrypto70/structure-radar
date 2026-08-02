import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_lang.dart';

class LocaleController extends ChangeNotifier {
  static const _key = 'app_lang_v1';

  AppLang lang = AppLang.ru;
  L10n get t => L10n(lang);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == 'en') {
      lang = AppLang.en;
    } else {
      lang = AppLang.ru;
    }
    notifyListeners();
  }

  Future<void> setLang(AppLang next) async {
    if (lang == next) return;
    lang = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next.code);
    notifyListeners();
  }
}
