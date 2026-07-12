import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_startup_widget.dart';

import 'core/utils/globals.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/user/presentation/controllers/user_controller.dart';
import 'features/home/presentation/controllers/home_metrics_controller.dart';
import 'features/medications/presentation/controllers/medication_controller.dart';
import 'features/medications/presentation/controllers/all_medicines_controller.dart';
import 'features/medications/domain/usecases/create_medication_usecase.dart';
import 'features/medications/domain/usecases/update_medication_usecase.dart';
import 'features/appointment/presentation/controllers/appointment_controller.dart';
import 'features/reading_logging/presentation/controllers/reading_logging_controller.dart';
import 'core/db/daos/vitals_dao.dart';
import 'injection_container.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Status bar (top)
        statusBarColor: Color(0xFFFDFAF4),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        // Navigation bar (bottom)
        systemNavigationBarColor: Color(0xFFFDFAF4),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: AppStartupWidget(
        onLoaded: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: sl<AuthController>()),
            ChangeNotifierProvider.value(value: sl<UserController>()),
            ChangeNotifierProvider(
                create: (_) => sl<HomeMetricsController>()..fetchMetrics()),
            ChangeNotifierProvider(create: (_) => sl<MedicationController>()),
            ChangeNotifierProvider(create: (_) => sl<AllMedicinesController>()),
            Provider<CreateMedicationUseCase>(create: (_) => sl()),
            Provider<UpdateMedicationUseCase>(create: (_) => sl()),
            ChangeNotifierProvider(
                create: (_) => sl<AppointmentController>()..initialize()),
            ChangeNotifierProvider(create: (_) => sl<ReadingLoggingController>()),
            Provider<VitalsDao>(create: (_) => sl()),
          ],
          child: MaterialApp.router(
            scaffoldMessengerKey: scaffoldMessengerKey,
            routerConfig: _router,
            title: 'yelima',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            themeMode: ThemeMode.light,
          ),
        ),
      ),
    );
  }
}
