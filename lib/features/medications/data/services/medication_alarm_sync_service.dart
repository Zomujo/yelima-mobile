import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../domain/repositories/medication_repository.dart';

/// Reschedules medication reminders when a session starts and clears them when it ends.
class MedicationAlarmSyncService implements SessionLifecycleHandler {
  MedicationAlarmSyncService(this._repository, this._notifications);

  final MedicationRepository _repository;
  final NotificationService _notifications;
  StreamSubscription<(String, String)>? _remapSub;

  void _moveReminders((String, String) ids) =>
      _repository.moveReminders(ids.$1, ids.$2).catchError((Object e) {
        debugPrint('MedicationAlarmSyncService: Failed to move reminders: $e');
      });

  @override
  String get serviceName => 'MedicationAlarmSyncService';

  @override
  Future<void> onSessionStarted(String userId) async {
    _remapSub ??= _repository.onIdChanged.listen(_moveReminders);
    try {
      await _repository.syncLocalAlarms();
    } catch (e) {
      debugPrint('MedicationAlarmSyncService: Alarm sync failed: $e');
    }
  }

  /// Cancels every reminder on any session end, forced logouts included, so
  /// drug names never show on the next user's lock screen.
  @override
  Future<void> onSessionEnded() async {
    await _remapSub?.cancel();
    _remapSub = null;
    try {
      await _notifications.cancelAllReminders();
    } catch (e) {
      debugPrint('MedicationAlarmSyncService: Failed to cancel reminders: $e');
    }
  }
}
