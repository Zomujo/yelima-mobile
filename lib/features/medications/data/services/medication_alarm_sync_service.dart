import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../domain/repositories/medication_repository.dart';

class MedicationAlarmSyncService implements SessionLifecycleHandler {
  final MedicationRepository _repository;
  final NotificationService _notifications;

  MedicationAlarmSyncService(this._repository, this._notifications);

  @override
  String get serviceName => 'MedicationAlarmSyncService';

  @override
  Future<void> onSessionStarted(String userId) async {
    try {
      debugPrint(
          'MedicationAlarmSyncService: Syncing local alarms on startup...');
      await _repository.syncLocalAlarms();
      debugPrint('MedicationAlarmSyncService: Alarm sync complete.');
    } catch (e) {
      debugPrint('MedicationAlarmSyncService: Alarm sync failed: $e');
    }
  }

  @override

  /// Cancels every reminder on any session end, forced logouts included, so
  /// drug names never show on the next user's lock screen.
  Future<void> onSessionEnded() async {
    try {
      await _notifications.cancelAllReminders();
    } catch (e) {
      debugPrint('MedicationAlarmSyncService: Failed to cancel reminders: $e');
    }
  }
}
