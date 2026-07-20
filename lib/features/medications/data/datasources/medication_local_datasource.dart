import '../../../../core/utils/custom_types.dart';
import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../models/create_medication_model.dart';
import '../models/update_medication_model.dart';
import '../models/medication_detail_model.dart';

abstract class MedicationLocalDataSource {
  Stream<MedicationCount> watchMedicationCounts();
  Stream<List<MedicationEntity>> watchMedicationsBySection(String section);
  Stream<List<MedicationEntity>> watchAllMedications();
  Stream<MedicationAdherence> watchAdherence();

  AsyncResponse<MedicationAdherence> getCachedAdherence();
  Future<void> cacheAdherence(MedicationAdherence result);

  AsyncResponse<MedicationCount> getCachedMedicationCounts();

  AsyncResponse<List<MedicationEntity>> getCachedMedicationsBySection(
      String section);
  Future<void> cacheMedicationsBySection(
      String section, List<MedicationEntity> result);

  AsyncResponse<MedicationListResponse> getCachedAllMedications(
      int page, int pageSize);
  Future<void> cacheAllMedications(List<MedicationEntity> result);

  Future<void> markMedicationTaken(
      String medicationId, String section, String effectiveDate);
  Future<void> queueOptimisticConfirm(
      String medicationId, String section, String effectiveDate);
  Future<void> optimisticallyUpdateAdherence(String targetDate);

  Future<void> cacheMedicationHistory(
      String medicationId, String date, MedicationHistoryEntity history);
  Future<void> updateMedicationHistoryLog(
      String medicationId, String date, DateTime now);
  AsyncResponse<MedicationHistoryEntity> getCachedMedicationHistory(
      String medicationId, String date);

  Future<String> createMedicationOffline(CreateMedicationModel data);
  Future<String> updateMedicationOffline(String id, UpdateMedicationModel data);

  AsyncResponse<MedicationDetailModel> getMedicationById(String id);

  Future<List<MedicationEntity>> applyPendingMutationsToRemoteResult(
      List<MedicationEntity> remoteResult,
      {String? sectionFilter});
  Future<MedicationAdherence> applyPendingMutationsToAdherenceResult(
      MedicationAdherence remoteResult);
}
