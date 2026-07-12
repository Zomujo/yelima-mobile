import 'dart:async';
import 'package:flutter/material.dart';

import '../utils/logger.dart';
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

  AppStartupService()
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

      // Startup is complete, let the AuthController & Router handle auth state
      value = StartupStatus(phase: StartupPhase.ready);
    } catch (e, stack) {
      AppLogger.e('AppStartupService: Startup failure', e, stack);
      value = StartupStatus(phase: StartupPhase.error);
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
}
