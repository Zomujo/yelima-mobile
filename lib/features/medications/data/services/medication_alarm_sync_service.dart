import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../domain/repositories/medication_repository.dart';

class MedicationAlarmSyncService implements SessionLifecycleHandler {
  final MedicationRepository _repository;
  final NotificationService _notifications;

  /// The sync manager's events; `remap:medication:<old>:<new>` moves reminders.
  final Stream<String> _syncEvents;
  StreamSubscription<String>? _remapSub;

  MedicationAlarmSyncService(
      this._repository, this._notifications, this._syncEvents);

  void _onSyncEvent(String event) {
    final parts = event.split(':');
    if (parts.length == 4 && parts[0] == 'remap' && parts[1] == 'medication') {
      _repository.moveReminders(parts[2], parts[3]).catchError((Object e) {
        debugPrint('MedicationAlarmSyncService: Failed to move reminders: $e');
      });
    }
  }

  @override
  String get serviceName => 'MedicationAlarmSyncService';

  @override
  Future<void> onSessionStarted(String userId) async {
    _remapSub ??= _syncEvents.listen(_onSyncEvent);
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
    await _remapSub?.cancel();
    _remapSub = null;
    try {
      await _notifications.cancelAllReminders();
    } catch (e) {
      debugPrint('MedicationAlarmSyncService: Failed to cancel reminders: $e');
    }
  }
}
