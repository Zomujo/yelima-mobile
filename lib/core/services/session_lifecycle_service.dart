import 'dart:collection';
import '../utils/logger.dart';

/// Abstract contract every feature module must implement to participate in
/// the session lifecycle.
abstract class SessionLifecycleHandler {
  /// A human-readable name for the service to display during initialization.
  String get serviceName;

  /// Called when a user session starts (sign-in / auth-state-becomes-non-null).
  /// [userId] is the UID of the authenticated user.
  Future<void> onSessionStarted(String userId);

  /// Called when a user session ends (sign-out / auth-state-becomes-null).
  Future<void> onSessionEnded();
}

/// Coordinates ordered, concurrent execution of [SessionLifecycleHandler]s.
///
/// Handlers are grouped by [priority] (lower number = runs first).
/// Within each priority group, handlers are run concurrently via [Future.wait].
/// Groups themselves are run sequentially.
///
/// - [startSession] runs groups in ascending priority order.
/// - [endSession] runs groups in descending priority order (reverse of start).
class SessionLifecycleService {
  final SplayTreeMap<int, List<SessionLifecycleHandler>> _handlers =
      SplayTreeMap();

  /// Registers a [handler] at the given [priority].
  /// Lower [priority] values run first.
  void register(SessionLifecycleHandler handler, {int priority = 50}) {
    _handlers.putIfAbsent(priority, () => []).add(handler);
  }

  /// Runs all handlers' [onSessionStarted] in ascending priority order.
  Future<void> startSession(String userId) async {
    AppLogger.i('SessionLifecycleService: starting session for user $userId');
    for (final entry in _handlers.entries) {
      AppLogger.d(
          'SessionLifecycleService: running onSessionStarted (priority ${entry.key})');
      await Future.wait(
        entry.value.map((h) async {
          try {
            await h.onSessionStarted(userId);
          } catch (e) {
            AppLogger.e(
                'Error in onSessionStarted for handler ${h.runtimeType}: $e');
          }
        }),
      );
    }
  }

  /// Runs all handlers' [onSessionEnded] in descending priority order.
  Future<void> endSession() async {
    AppLogger.i('SessionLifecycleService: ending session');
    for (final entry in _handlers.entries.toList().reversed) {
      AppLogger.d(
          'SessionLifecycleService: running onSessionEnded (priority ${entry.key})');
      await Future.wait(
        entry.value.map((h) async {
          try {
            await h.onSessionEnded();
          } catch (e) {
            AppLogger.e(
                'Error in onSessionEnded for handler ${h.runtimeType}: $e');
          }
        }),
      );
    }
  }
}
