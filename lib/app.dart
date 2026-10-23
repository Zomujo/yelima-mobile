import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/router/router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/utils/globals.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/user/presentation/controllers/user_controller.dart';
import 'features/home/presentation/controllers/home_metrics_controller.dart';
import 'features/medications/presentation/controllers/medication_controller.dart';
import 'features/medications/presentation/controllers/all_medicines_controller.dart';
import 'features/medications/domain/repositories/medication_repository.dart';
import 'features/appointment/presentation/controllers/appointment_controller.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'features/symptoms/presentation/controllers/symptoms_controller.dart';
import 'core/db/daos/vitals_dao.dart';
import 'injection_container.dart';
import 'core/controllers/locale_controller.dart';
import 'core/localization/fallback_localization_delegates.dart';

import 'package:go_router/go_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router =
        AppRouter.createRouter(sl<AuthController>(), sl<UserController>());
    // After the first frame, so a notification that launched the app can navigate.
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => NotificationService.instance.attachNavigator(_router.go));
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
      child: Builder(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: sl<AuthController>()),
            ChangeNotifierProvider.value(value: sl<UserController>()),
            ChangeNotifierProvider.value(value: sl<LocaleController>()),
            ChangeNotifierProvider(
                create: (_) => sl<HomeMetricsController>()..fetchMetrics()),
            ChangeNotifierProvider(create: (_) => sl<MedicationController>()),
            ChangeNotifierProvider(create: (_) => sl<AllMedicinesController>()),
            Provider<MedicationRepository>(create: (_) => sl()),
            ChangeNotifierProvider(
                create: (_) => sl<AppointmentController>()..initialize()),
            ChangeNotifierProvider(
                create: (_) => sl<ReadingLoggingController>()),
            ChangeNotifierProvider(
                create: (_) =>
                    sl<SymptomsController>()..fetchSymptoms(silent: true)),
            Provider<VitalsDao>(create: (_) => sl()),
          ],
          child: Consumer<LocaleController>(
            builder: (context, localeController, child) {
              return MaterialApp.router(
                scaffoldMessengerKey: scaffoldMessengerKey,
                routerConfig: _router,
                title: 'yelima',
                locale: localeController.locale,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
