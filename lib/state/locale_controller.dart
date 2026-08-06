import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_lang.dart';

class LocaleController extends ChangeNotifier {
  static const _key = 'app_lang_v1';
  static const _chosenKey = 'lang_chosen_v1';
  static const _disclaimerKey = 'disclaimer_accepted_v1';

  AppLang lang = AppLang.en;
  bool languageChosen = false;
  L10n get t => L10n(lang);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    languageChosen = prefs.getBool(_chosenKey) ?? false;
    if (languageChosen) {
      lang = AppLangX.fromCode(prefs.getString(_key));
    } else {
      lang = AppLang.en;
    }
    notifyListeners();
  }

  Future<void> chooseLanguage(AppLang next) => setLang(next);

  Future<void> setLang(AppLang next) async {
    lang = next;
    languageChosen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next.code);
    await prefs.setBool(_chosenKey, true);
    notifyListeners();
  }

  Future<void> resetLanguageChoice() async {
    languageChosen = false;
    lang = AppLang.en;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chosenKey, false);
    await prefs.setBool(_disclaimerKey, false);
    notifyListeners();
  }
}
