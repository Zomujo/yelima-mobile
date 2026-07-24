import 'package:flutter/foundation.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../domain/repositories/medication_repository.dart';

class MedicationAlarmSyncService implements SessionLifecycleHandler {
  final MedicationRepository _repository;

  MedicationAlarmSyncService(this._repository);

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
  Future<void> onSessionEnded() async {
    // Alarms are already wiped in AuthRepositoryImpl during logout,
    // so nothing needs to be done here.
  }
}
