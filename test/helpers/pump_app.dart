import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/core/localization/fallback_localization_delegates.dart';
import 'package:yelima/core/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside the app's theme, translations, a router and a
  /// Riverpod scope with [overrides].
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
    Locale locale = const Locale('en'),
  }) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => Scaffold(body: widget)),
    ]);
    final app = MaterialApp.router(
      theme: AppTheme.theme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
        FallbackWidgetsLocalizationDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
    await pumpWidget(ProviderScope(overrides: overrides, child: app));
    await pump();
  }
}
