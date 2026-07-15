import '../../../../core/utils/custom_types.dart';
import '../entities/medication_adherence.dart';
import '../entities/medication_count.dart';
import '../entities/medication_entity.dart';
import '../entities/medication_history_entity.dart';
import '../../data/models/create_medication_model.dart';
import '../../data/models/update_medication_model.dart';
import '../../data/models/medication_detail_model.dart';
import '../../data/models/seeded_medication_list_response_model.dart';

abstract class MedicationRepository {
  AsyncResponse<MedicationAdherence> getAdherence({required bool showWeekdays});
  AsyncResponse<MedicationAdherence> getCachedAdherence({required bool showWeekdays});
  
  AsyncResponse<MedicationCount> getMedicationCounts();
  AsyncResponse<MedicationCount> getCachedMedicationCounts();
  
  AsyncResponse<List<MedicationEntity>> getMedicationsBySection(String section);
  AsyncResponse<List<MedicationEntity>> getCachedMedicationsBySection(String section);
  
  AsyncResponse<void> confirmMedication(String medicationId, String section, {String? date});

  AsyncResponse<String> createMedication(CreateMedicationModel data);
  AsyncResponse<MedicationDetailModel> getMedicationById(String id);
  AsyncResponse<String> updateMedication(String id, UpdateMedicationModel data);
  AsyncResponse<SeededMedicationListResponseModel> getPreloadedMedications({int page = 1, int limit = 10, String? search});

  AsyncResponse<MedicationListResponse> getAllMedications({int page = 1, int pageSize = 10, bool forceRefresh = false});
  AsyncResponse<MedicationListResponse> getCachedAllMedications();

  Stream<List<MedicationEntity>> watchAllMedications();
  
  AsyncResponse<MedicationHistoryEntity> getMedicationHistory(String medicationId, {required String date});

  void invalidateCache();
}
