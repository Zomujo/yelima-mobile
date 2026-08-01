import 'package:flutter/material.dart';
import '../services/shared_prefs_service.dart';

class LocaleController extends ChangeNotifier {
  final SharedPrefsService _prefsService;
  static const _localeKey = 'selected_locale';

  Locale? _locale;

  LocaleController(this._prefsService) {
    _loadLocale();
  }

  Locale? get locale => _locale;

  void _loadLocale() {
    final langCode = _prefsService.getString(_localeKey);
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefsService.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }
}
