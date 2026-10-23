import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yelima/core/utils/logger.dart';

import 'package:firebase_core/firebase_core.dart';
import 'injection_container.dart' as di;

import 'core/config/app_config.dart';
import 'app.dart';

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/failures/guard.dart';
import 'core/services/monitoring_service.dart';
import 'core/services/notification_service.dart';
import 'core/utils/time_zone.dart';
import 'package:timezone/data/latest_all.dart' as tz;

Future<void> bootstrap(FirebaseOptions? firebaseOptions,
    {String? envFile}) async {
  WidgetsFlutterBinding.ensureInitialized();
  silenceDebugPrintInRelease();

  // Apply system-wide UI overlay style.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.globalBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseOptions);

  // Initialize Monitoring Service (Crashlytics + Analytics)
  await MonitoringService.instance.initialize();
  reportUnexpectedFailure =
      (e, stack) => MonitoringService.instance.recordNonFatalError(e, stack);

  // Initialize timezone data and the device zone, so reminders fire at local time.
  tz.initializeTimeZones();
  await configureLocalTimeZone();

  // Initialize Notification Service (Push Notifications).
  await NotificationService.instance.initialize();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Pass all uncaught framework errors to Crashlytics.
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors to Crashlytics.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize GetIt Dependency Injection
  await di.init();

  AppLogger.i(
      '🚀 Bootstrapping ${AppConfig.instance.appName} [${AppConfig.instance.flavor.name}]...');

  runApp(const MyApp());

  // Request push notification permissions non-blockingly after runApp.
  unawaited(NotificationService.instance.requestPermissions());
}
