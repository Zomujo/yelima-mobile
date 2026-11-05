import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/router/router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/utils/globals.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/core_providers.dart';
import 'core/localization/fallback_localization_delegates.dart';
import 'package:go_router/go_router.dart';

/// The app root: theme, translations and router.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = ref.read(appRouterProvider);
    // After the first frame, so a notification that launched the app can navigate.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => NotificationService.instance.attachNavigator(_router.go));
  }

  /// Sends queued changes as soon as the app is back on screen, so a dose taken
  /// offline reaches the server well inside its 48 h window.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(connectivityProvider).pause();
    }
    if (state == AppLifecycleState.resumed) {
      ref.read(connectivityProvider).resume();
      // Coming back to the app always shows fresh data.
      ref.read(recentFetchesProvider).clear();
      ref.read(dayChangesProvider).check();
      ref.read(mutationSyncManagerProvider).triggerSync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Status bar (top)
        statusBarColor: AppColors.globalBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        // Navigation bar (bottom)
        systemNavigationBarColor: AppColors.globalBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        routerConfig: _router,
        title: 'yelima',
        locale: ref.watch(localeControllerProvider),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          FallbackMaterialLocalizationDelegate(),
          FallbackCupertinoLocalizationDelegate(),
          FallbackWidgetsLocalizationDelegate(),
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        themeMode: ThemeMode.light,
      ),
    );
  }
}
