import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePreference {
  static const _key = 'preferred_locale';

  static const supportedLanguageCodes = <String>{'en', 'it', 'fa'};

  static Future<Locale?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_key);

    if (languageCode == null ||
        !supportedLanguageCodes.contains(languageCode)) {
      return null;
    }

    return Locale(languageCode);
  }

  static Future<void> save(Locale? locale) async {
    final preferences = await SharedPreferences.getInstance();

    if (locale == null) {
      await preferences.remove(_key);
      return;
    }

    await preferences.setString(_key, locale.languageCode);
  }
}
