import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  final SharedPreferences _prefs;
  const SharedPrefsService(this._prefs);

  static const _onboardingKey = 'has_completed_onboarding';

  // Specific helpers
  bool hasCompletedOnboarding() => getBool(_onboardingKey) ?? false;
  Future<void> setOnboardingCompleted() => setBool(_onboardingKey, true);

  // Generic helpers
  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
  Future<void> clear() => _prefs.clear();
}
