import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/logger.dart';
import 'session_lifecycle_service.dart';
import 'update_service.dart';

enum StartupPhase {
  idle,
  initializingGlobal,
  initializingSession,
  ready,
  unauthenticated,
  error
}

class StartupStatus {
  final StartupPhase phase;

  StartupStatus({
    required this.phase,
  });
}

class AppStartupService extends ValueNotifier<StartupStatus> {
  final SessionLifecycleService _sessionService;

  AppStartupService(this._sessionService)
      : super(StartupStatus(phase: StartupPhase.idle));

  Future<void> start() async {
    //  Foreground Guard: Avoid initialization during headless background boot
    if (WidgetsBinding.instance.lifecycleState != null &&
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      final lifecycleCompleter = Completer<void>();
      late AppLifecycleListener listener;
      listener = AppLifecycleListener(
        onResume: () {
          if (!lifecycleCompleter.isCompleted) {
            lifecycleCompleter.complete();
          }
        },
      );

      try {
        // Wait up to 3 seconds for foreground before proceeding anyway
        await lifecycleCompleter.future.timeout(const Duration(seconds: 3));
      } catch (_) {
        AppLogger.w(
            'AppStartupService: Foreground timeout, proceeding in background');
      } finally {
        listener.dispose();
      }
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Global Phase (Critical services only)
      await _initGlobal().timeout(
        const Duration(seconds: 2),
        onTimeout: () => AppLogger.w(
            'AppStartupService: Global init exceeded snappy window'),
      );

      // Auth Discovery
      final userId = await _checkAuthentication();

      if (userId != null) {
        // Session Phase - Run in background so UI is unblocked instantly
        _initSession(userId).catchError((e) {
          AppLogger.e(
              'AppStartupService: Session init failed in background', e);
        });

        value = StartupStatus(phase: StartupPhase.ready);
      } else {
        value = StartupStatus(phase: StartupPhase.unauthenticated);
      }
    } catch (e, stack) {
      AppLogger.e('AppStartupService: Startup failure', e, stack);
      value = StartupStatus(phase: StartupPhase.unauthenticated);
    } finally {
      stopwatch.stop();
      AppLogger.d(
          'AppStartupService: Total startup took ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  /// Initialized global services (Database, Firebase, etc.)
  Future<void> _initGlobal() async {
    value = StartupStatus(phase: StartupPhase.initializingGlobal);

    // Global initializations
    try {
      // Update Check (OTA) - Run in background so it doesn't block startup
      UpdateService.checkForOTAPatches().catchError((e) {
        AppLogger.e('AppStartupService: OTA check failed in background', e);
      });
    } catch (e) {
      AppLogger.e('AppStartupService: Non-fatal error during global init', e);
    }

    AppLogger.i('AppStartupService: Global initialization complete');
  }

  /// Checks if we have an active session
  Future<String?> _checkAuthentication() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user?.uid;
    } catch (e) {
      AppLogger.e('AppStartupService: Error checking authentication', e);
      return null;
    }
  }

  /// Initialized session-specific services (Profile, Feature Caches)
  Future<void> _initSession(String userId) async {
    value = StartupStatus(phase: StartupPhase.initializingSession);

    try {
      await _sessionService.startSession(userId);
    } catch (e) {
      AppLogger.e('AppStartupService: Error during session init', e);
    }

    AppLogger.i('AppStartupService: Session initialization complete');
  }
}
