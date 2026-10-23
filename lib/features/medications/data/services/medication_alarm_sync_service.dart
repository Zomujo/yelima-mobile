import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../domain/repositories/medication_repository.dart';

/// Reschedules medication reminders when a session starts or the language
/// changes, and clears them when the session ends.
class MedicationAlarmSyncService implements SessionLifecycleHandler {
  MedicationAlarmSyncService(
      this._repository, this._notifications, this._language);

  final MedicationRepository _repository;
  final NotificationService _notifications;
  final Listenable _language;
  StreamSubscription<(String, String)>? _remapSub;

  Future<void> _syncAlarms() async {
    try {
      await _repository.syncLocalAlarms();
    } catch (e) {
      debugPrint('MedicationAlarmSyncService: Alarm sync failed: $e');
    }
  }

  void _moveReminders((String, String) ids) =>
      _repository.moveReminders(ids.$1, ids.$2).catchError((Object e) {
        debugPrint('MedicationAlarmSyncService: Failed to move reminders: $e');
      });

  @override
  String get serviceName => 'MedicationAlarmSyncService';

  @override
  Future<void> onSessionStarted(String userId) async {
    _remapSub ??= _repository.onIdChanged.listen(_moveReminders);
    _language
      ..removeListener(_syncAlarms)
      ..addListener(_syncAlarms);
    await _syncAlarms();
  }

  /// Cancels every reminder on any session end, forced logouts included, so
  /// drug names never show on the next user's lock screen.
  @override
  Future<void> onSessionEnded() async {
    _language.removeListener(_syncAlarms);
    await _remapSub?.cancel();
    _remapSub = null;
    try {
      await _notifications.cancelAllReminders();
    } catch (e) {
      debugPrint('MedicationAlarmSyncService: Failed to cancel reminders: $e');
    }
  }
}
