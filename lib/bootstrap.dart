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
import 'core/services/monitoring_service.dart';
import 'core/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

Future<void> bootstrap(FirebaseOptions? firebaseOptions,
    {String? envFile}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Apply system-wide UI overlay style.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFFDFAF4),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFFDFAF4),
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Initialize Firebase
  await Firebase.initializeApp(options: firebaseOptions);

  // Initialize Monitoring Service (Crashlytics + Analytics)
  await MonitoringService.instance.initialize();

  // Initialize timezone data required for scheduled notifications
  tz.initializeTimeZones();

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
