import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/db/app_database.dart';
import '../domain/entities/medication_adherence.dart';
import '../domain/entities/medication_entity.dart';
import '../data/models/create_medication_model.dart';
import '../data/models/update_medication_model.dart';
import '../data/models/dosing_schedule_model.dart';

mixin MedicationOptimisticSyncHelpers {
  AppDatabase get db;

  Future<void> queueOptimisticConfirm(String medicationId, String section, String effectiveDate) async {
    final pendingAll = await db.pendingMutationsDao.getAllPendingMutations();
    final alreadyConfirming = pendingAll.any((p) =>
        p.entityId == medicationId &&
        p.action == 'confirm' &&
        jsonDecode(p.payloadJson)['section'] == section &&
        jsonDecode(p.payloadJson)['date'] == effectiveDate);

    if (!alreadyConfirming) {
      await db.pendingMutationsDao.addPendingMutation(
        PendingMutationsCompanion.insert(
          id: const Uuid().v4(),
          entityType: 'medication',
          entityId: medicationId,
          action: 'confirm',
          payloadJson: jsonEncode({'medicationId': medicationId, 'section': section, 'date': effectiveDate}),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<String> createMedicationOffline(CreateMedicationModel data) async {
    final localId = 'offline_${const Uuid().v4()}';
    await saveOfflineMedication(localId, data.name, data.dosage, data.notes, data.morning, data.afternoon, data.evening, 'pending_create', 'create_medication', data.toJson());
    return localId;
  }

  Future<String> updateMedicationOffline(String id, UpdateMedicationModel data) async {
    final localMeds = await db.medicationsDao.getAllMedications();
    final local = localMeds.where((m) => m.id == id).firstOrNull;
    if (local == null) throw Exception('Medication not found locally');

    await saveOfflineMedication(id, local.name, data.dosage ?? local.dosage, data.notes ?? local.purpose, data.morning, data.afternoon, data.evening, local.syncStatus == 'pending_create' ? 'pending_create' : 'pending_update', 'update_medication', data.toJson());
    return id;
  }

  Future<void> saveOfflineMedication(String id, String name, String dosage, String? purpose, DosingScheduleModel? m, DosingScheduleModel? a, DosingScheduleModel? e, String syncStatus, String action, Map<String, dynamic> payload) async {
    final companion = MedicationsCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      dosage: drift.Value(dosage),
      purpose: drift.Value(purpose ?? ''),
      morningSchedule: drift.Value(m != null ? jsonEncode(m.toJson()) : null),
      afternoonSchedule: drift.Value(a != null ? jsonEncode(a.toJson()) : null),
      eveningSchedule: drift.Value(e != null ? jsonEncode(e.toJson()) : null),
      syncStatus: drift.Value(syncStatus),
      lastModifiedAt: drift.Value(DateTime.now()),
    );
    await db.transaction(() async {
      await db.medicationsDao.insertOrUpdateMedication(companion);
      await db.pendingMutationsDao.addPendingMutation(
          PendingMutationsCompanion.insert(
              id: const Uuid().v4(),
              entityType: 'medication',
              entityId: id,
              action: action,
              payloadJson: jsonEncode(payload),
              createdAt: DateTime.now()));
    });
  }

  Future<List<MedicationEntity>> applyPendingMutationsToRemoteResult(List<MedicationEntity> remoteResult, {String? sectionFilter}) async {
    try {
      final pendingAll = await db.pendingMutationsDao.getAllPendingMutations();
      final confirms = pendingAll.where((p) => p.entityType == 'medication' && p.action == 'confirm').toList();
      if (confirms.isEmpty) return remoteResult;

      List<MedicationEntity> result = List.from(remoteResult);
      for (var pending in confirms) {
        final index = result.indexWhere((m) => m.id == pending.entityId);
        if (index != -1) {
          try {
            final confirmDate = jsonDecode(pending.payloadJson)['date'] as String?;
            if (confirmDate == null || result[index].toBeTakenAt.toIso8601String().startsWith(confirmDate)) {
              result[index] = result[index].copyWith(taken: true);
            }
          } catch (_) {
            result[index] = result[index].copyWith(taken: true);
          }
        }
      }
      return result;
    } catch (_) {
      return remoteResult;
    }
  }

  Future<MedicationAdherence> applyPendingMutationsToAdherenceResult(MedicationAdherence remoteResult) async {
    try {
      final pendingAll = await db.pendingMutationsDao.getAllPendingMutations();
      final confirms = pendingAll.where((p) => p.entityType == 'medication' && p.action == 'confirm').toList();
      if (confirms.isEmpty) return remoteResult;

      double newRate = remoteResult.rate;
      List<AdherenceDay> newDays = List.from(remoteResult.days);

      for (var pending in confirms) {
        try {
          final dateStr = jsonDecode(pending.payloadJson)['date'] as String? ?? DateTime.now().toIso8601String().substring(0, 10);
          for (int i = 0; i < newDays.length; i++) {
            if (newDays[i].takenAt.toIso8601String().startsWith(dateStr) && !newDays[i].taken) {
              newDays[i] = AdherenceDay(id: newDays[i].id, taken: true, takenAt: newDays[i].takenAt);
              newRate = (newRate + 5).clamp(0, 100).toDouble();
            }
          }
        } catch (_) {}
      }
      return MedicationAdherence(rate: newRate, days: newDays);
    } catch (_) {
      return remoteResult;
    }
  }
}
