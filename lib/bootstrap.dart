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

Future<void> bootstrap(FirebaseOptions? firebaseOptions, {String? envFile}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Apply system-wide UI overlay style so the status bar and Android navigation
  // bar always match the app's cream background, even on screens without AppBars.
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

  // Initialize Notification Service (Push Notifications). This only sets up
  // local plugin/channel state and reads cold-start message info - it's
  // fast and doesn't prompt the user, so it's safe to await here.
  await NotificationService.instance.initialize();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize GetIt Dependency Injection
  await di.init();

  AppLogger.i(
      '🚀 Bootstrapping ${AppConfig.instance.appName} [${AppConfig.instance.flavor.name}]...');

  runApp(const MyApp());

  // Request push notification permission after the UI is already rendering,
  // instead of blocking the entire app - including the splash screen -
  // behind the native OS prompt. `requestPermission()` awaits the user's
  // tap, so awaiting it here would previously delay `runApp()` (and
  // therefore the first frame) until they responded.
  unawaited(NotificationService.instance.requestPermissions());
}
