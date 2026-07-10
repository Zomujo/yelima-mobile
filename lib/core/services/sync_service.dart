import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/services/connectivity_service.dart';
import 'package:yelima/core/services/session_lifecycle_service.dart';
import 'package:yelima/core/utils/logger.dart';
import 'package:yelima/features/medications/data/datasources/medication_remote_datasource.dart';
import 'package:yelima/features/chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:yelima/features/medications/data/models/create_medication_model.dart';
import 'package:yelima/features/medications/data/models/dosing_schedule_model.dart';
import 'package:yelima/features/medications/data/models/update_medication_model.dart';

class SyncService implements SessionLifecycleHandler {
  final AppDatabase _db;
  final ConnectivityService _connectivityService;
  final MedicationRemoteDataSource _medicationRemoteDataSource;
  final AiChatRemoteDataSource _aiChatRemoteDataSource;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;
  bool _isSessionActive = false;

  SyncService(
    this._db, 
    this._connectivityService,
    this._medicationRemoteDataSource,
    this._aiChatRemoteDataSource,
  );

  @override
  String get serviceName => 'Background Sync Queue';

  @override
  Future<void> onSessionStarted(String userId) async {
    _isSessionActive = true;
    _connectivitySub?.cancel();
    _connectivitySub = _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected && _isSessionActive) {
        _flushPendingMutations();
      }
    });
    // Attempt an immediate flush if connected
    if (await _connectivityService.isConnected) {
      _flushPendingMutations();
    }
  }

  @override
  Future<void> onSessionEnded() async {
    _isSessionActive = false;
    _connectivitySub?.cancel();
    _isSyncing = false;
  }

  Future<void> _flushPendingMutations() async {
    if (_isSyncing || !_isSessionActive) return;
    _isSyncing = true;
    
    try {
      final pendingMutations = await _db.pendingMutationsDao.getAllPendingMutations();
      if (pendingMutations.isEmpty) {
        _isSyncing = false;
        return;
      }

      AppLogger.i('SyncService: Found ${pendingMutations.length} pending mutations. Syncing silently...');

      final Map<String, String> idMappings = {};

      for (final mutation in pendingMutations) {
        try {
          final payload = jsonDecode(mutation.payloadJson) as Map<String, dynamic>;

          bool handled = true;
          if (mutation.entityType == 'medication' && mutation.action == 'confirm') {
            final rawMedicationId = payload['medicationId'] as String;
            final medicationId = idMappings[rawMedicationId] ?? rawMedicationId;
            final section = payload['section'] as String? ?? 'MORNING';
            await _medicationRemoteDataSource.confirmMedication(medicationId, section);
          } else if (mutation.entityType == 'medication' && mutation.action == 'create_medication') {
            final model = CreateMedicationModel.fromJson(payload);
            final newId = await _medicationRemoteDataSource.createMedication(model);
            idMappings[mutation.entityId] = newId;

            // Replace the offline placeholder with a row under the real
            // server id, so the medication doesn't vanish from the local
            // cache if we go offline again before the next full list fetch.
            await _db.medicationsDao.deleteMedication(mutation.entityId);
            await _db.medicationsDao.insertOrUpdateMedication(MedicationsCompanion(
              id: drift.Value(newId),
              name: drift.Value(model.name),
              dosage: drift.Value(model.dosage),
              purpose: drift.Value(model.notes ?? ''),
              toBeTakenAt: drift.Value(_resolveToBeTakenAt(model.morning ?? model.afternoon ?? model.evening)),
              taken: const drift.Value(false),
            ));
          } else if (mutation.entityType == 'medication' && mutation.action == 'update_medication') {
            final rawMedicationId = mutation.entityId;
            final medicationId = idMappings[rawMedicationId] ?? rawMedicationId;
            final model = UpdateMedicationModel.fromJson(payload);
            await _medicationRemoteDataSource.updateMedication(medicationId, model);
          } else if (mutation.entityType == 'chat' && mutation.action == 'sendMessage') {
            final message = payload['message'] as String;
            final localChatId = payload['localChatId'] as String?;
            await _aiChatRemoteDataSource.sendMessage(message, localChatId: localChatId);
          } else if (mutation.entityType == 'chat' && mutation.action == 'sendAudioMessage') {
            final filePath = payload['filePath'] as String;
            final localChatId = payload['localChatId'] as String?;
            await _aiChatRemoteDataSource.sendAudioMessage(filePath: filePath, localChatId: localChatId);
          } else {
            // Not one of the types this service owns - leave it queued for
            // whichever mechanism does own it, instead of dropping it.
            handled = false;
          }

          if (!handled) continue;
          await _db.pendingMutationsDao.removePendingMutation(mutation.id);
        } catch (e) {
          AppLogger.e('SyncService: Failed mutation ${mutation.id}: $e');
          // Basic poison pill logic: increment retry and delete if > 3
          final newRetryCount = mutation.retryCount + 1;
          if (newRetryCount > 3) {
            AppLogger.w('SyncService: Dropping poison pill mutation ${mutation.id}');
            await _db.pendingMutationsDao.removePendingMutation(mutation.id);
          } else {
            // Update retry count in DB
            final updatedMutation = mutation.copyWith(retryCount: newRetryCount);
            await _db.pendingMutationsDao.updatePendingMutation(updatedMutation);
          }
        }
      }
      
      AppLogger.i('SyncService: Finished syncing pending mutations.');
    } catch (e) {
      AppLogger.e('SyncService: Failed to flush pending mutations: $e');
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  // The Medications table only models a single toBeTakenAt per row, so an
  // offline-created medication with multiple dosing sections collapses onto
  // whichever section is provided first (morning > afternoon > evening).
  DateTime _resolveToBeTakenAt(DosingScheduleModel? schedule) {
    final now = DateTime.now();
    if (schedule == null) return now;

    final time = schedule.time;
    var hour24 = time.hour % 12;
    if (time.timeDesignators.toUpperCase() == 'PM') hour24 += 12;
    return DateTime(now.year, now.month, now.day, hour24, time.minutes);
  }
}
