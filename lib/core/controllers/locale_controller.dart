import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core_providers.dart';

part 'locale_controller.g.dart';

/// The chosen app language (null until one is picked), saved between launches.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  static const _localeKey = 'selected_locale';

  @override
  Locale? build() {
    final code = ref.watch(sharedPrefsServiceProvider).getString(_localeKey);
    return code == null ? null : Locale(code);
  }

  /// Switches the app to [locale] and remembers it.
  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    await ref
        .read(sharedPrefsServiceProvider)
        .setString(_localeKey, locale.languageCode);
  }
}
