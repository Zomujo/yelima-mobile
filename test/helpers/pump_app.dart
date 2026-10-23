import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:yelima/core/localization/fallback_localization_delegates.dart';
import 'package:yelima/core/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside the app's theme, translations, a router and [providers].
  Future<void> pumpApp(
    Widget widget, {
    List<SingleChildWidget> providers = const [],
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
    await pumpWidget(providers.isEmpty
        ? app
        : MultiProvider(providers: providers, child: app));
    await pump();
  }
}
