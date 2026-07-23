import '../../../../core/db/app_database.dart';

abstract class MedicationLocalDataSource {
  // Adherence
  Future<AdherenceGlobal?> getGlobalAdherenceRate(String typeId);
  Future<List<AdherenceGlobalDay>> getGlobalAdherenceDays();
  Future<void> saveGlobalAdherence(String typeId, double rate, List<AdherenceGlobalDay> driftDays);
  Future<void> markMedicationLogAsTakenOffline(String logId, String medicationId, DateTime date);
  Future<void> markGlobalDayAsTakenOffline(String dateStr);
  Future<void> saveMedicationLogs(List<MedicationLog> logs);
  Future<List<MedicationLog>> getLogsForMedication(String medicationId);

  // Medications
  Stream<List<Medication>> watchMedicationsBySection(String section);
  Stream<List<Medication>> watchAllMedications();
  Future<List<Medication>> getAllMedications();
  Future<List<Medication>> getMedicationById(String id);
  Future<void> deleteMedication(String id);
  Future<void> insertMedications(List<Medication> meds);
  Future<void> updateMedication(Medication med);
  Future<List<PreloadedMedication>> searchPreloadedMedications(String search);

  // Pending Mutations
  Future<List<PendingMutation>> getAllPendingMutations();
  Future<void> addPendingMutation(PendingMutationsCompanion mutation);
  Future<bool> hasPendingMutationsForEntity(String entityId);
  Future<bool> hasPendingMutationsForType(String type);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  final AppDatabase db;

  MedicationLocalDataSourceImpl({required this.db});

  @override
  Future<AdherenceGlobal?> getGlobalAdherenceRate(String typeId) {
    return db.adherenceDao.getGlobalAdherenceRate(typeId);
  }

  @override
  Future<List<AdherenceGlobalDay>> getGlobalAdherenceDays() {
    return db.adherenceDao.getGlobalAdherenceDays();
  }

  @override
  Future<void> saveGlobalAdherence(String typeId, double rate, List<AdherenceGlobalDay> driftDays) {
    return db.adherenceDao.saveGlobalAdherence(typeId, rate, driftDays);
  }

  @override
  Future<void> markMedicationLogAsTakenOffline(String logId, String medicationId, DateTime date) {
    return db.adherenceDao.markMedicationLogAsTakenOffline(logId, medicationId, date);
  }

  @override
  Future<void> markGlobalDayAsTakenOffline(String dateStr) {
    return db.adherenceDao.markGlobalDayAsTakenOffline(dateStr);
  }

  @override
  Future<void> saveMedicationLogs(List<MedicationLog> logs) {
    return db.adherenceDao.saveMedicationLogs(logs);
  }

  @override
  Future<List<MedicationLog>> getLogsForMedication(String medicationId) {
    return db.adherenceDao.getLogsForMedication(medicationId);
  }

  @override
  Stream<List<Medication>> watchMedicationsBySection(String section) {
    return db.medicationsDao.watchMedicationsBySection(section);
  }

  @override
  Stream<List<Medication>> watchAllMedications() {
    return db.medicationsDao.watchAllMedications();
  }

  @override
  Future<List<Medication>> getAllMedications() {
    return db.medicationsDao.getAllMedications();
  }

  @override
  Future<List<Medication>> getMedicationById(String id) {
    return db.medicationsDao.getMedicationById(id);
  }

  @override
  Future<void> deleteMedication(String id) {
    return db.medicationsDao.deleteMedication(id);
  }

  @override
  Future<void> insertMedications(List<Medication> meds) {
    return db.medicationsDao.insertMedications(meds);
  }

  @override
  Future<void> updateMedication(Medication med) {
    return db.medicationsDao.updateMedication(med);
  }

  @override
  Future<List<PreloadedMedication>> searchPreloadedMedications(String search) {
    return db.medicationsDao.searchPreloadedMedications(search);
  }

  @override
  Future<List<PendingMutation>> getAllPendingMutations() {
    return db.pendingMutationsDao.getAllPendingMutations();
  }

  @override
  Future<void> addPendingMutation(PendingMutationsCompanion mutation) {
    return db.pendingMutationsDao.addPendingMutation(mutation);
  }

  @override
  Future<bool> hasPendingMutationsForEntity(String entityId) async {
    final list = await (db.select(db.pendingMutations)..where((t) => t.entityId.equals(entityId))).get();
    return list.isNotEmpty;
  }

  @override
  Future<bool> hasPendingMutationsForType(String type) async {
    final list = await (db.select(db.pendingMutations)..where((t) => t.entityType.equals(type))).get();
    return list.isNotEmpty;
  }
}
