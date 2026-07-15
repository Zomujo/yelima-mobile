import '../../../../core/api/api_client.dart';
import '../models/medication_adherence_model.dart';
import '../models/medication_count_model.dart';
import '../models/medication_model.dart';
import '../models/medication_list_response_model.dart';
import '../models/medication_history_model.dart';
import '../models/create_medication_model.dart';
import '../models/update_medication_model.dart';
import '../models/medication_detail_model.dart';
import '../models/seeded_medication_list_response_model.dart';

abstract class MedicationRemoteDataSource {
  Future<MedicationAdherenceModel> getAdherence({required bool showWeekdays});
  Future<MedicationCountModel> getMedicationCounts();
  Future<List<MedicationModel>> getMedicationsBySection(String section);
  Future<String> confirmMedication(String medicationId, String section, {String? date});
  Future<MedicationListResponseModel> getAllMedications({int page = 1, int pageSize = 10});
  Future<MedicationHistoryModel> getMedicationHistory(String medicationId, {required String date});
  Future<String> createMedication(CreateMedicationModel data);
  Future<MedicationDetailModel> getMedicationById(String id);
  Future<String> updateMedication(String id, UpdateMedicationModel data);
  Future<SeededMedicationListResponseModel> getPreloadedMedications({int page = 1, int limit = 10, String? search});
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final APIClient apiClient;

  MedicationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MedicationAdherenceModel> getAdherence({required bool showWeekdays}) async {
    final response = await apiClient.get(
      '/api/v1/client/medication-adherence',
      queryParameters: {'showWeekdays': showWeekdays.toString()},
    );
    return MedicationAdherenceModel.fromJson(response['data']);
  }

  @override
  Future<MedicationCountModel> getMedicationCounts() async {
    final response = await apiClient.get('/api/v1/client/medications/today/count');
    return MedicationCountModel.fromJson(response['data']);
  }

  @override
  Future<List<MedicationModel>> getMedicationsBySection(String section) async {
    final response = await apiClient.get(
      '/api/v1/client/medications/today',
      queryParameters: {'section': section},
    );
    
    final List<dynamic> data = response['data'];
    return data.map((json) => MedicationModel.fromJson(json)).toList();
  }

  @override
  Future<String> confirmMedication(String medicationId, String section, {String? date}) async {
    final queryParams = {'section': section};
    if (date != null) queryParams['date'] = date;
    
    final response = await apiClient.put(
      '/api/v1/client/medications/$medicationId/confirm',
      queryParameters: queryParams,
    );
    return response['message'] as String? ?? 'Confirmed';
  }

  @override
  Future<MedicationListResponseModel> getAllMedications({int page = 1, int pageSize = 10}) async {
    final response = await apiClient.get(
      '/api/v1/client/medications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return MedicationListResponseModel.fromJson(response['data']);
  }

  @override
  Future<MedicationHistoryModel> getMedicationHistory(String medicationId, {required String date}) async {
    final response = await apiClient.get(
      '/api/v1/client/medications/$medicationId/adherence',
      queryParameters: {'date': date},
    );
    return MedicationHistoryModel.fromJson(response['data']);
  }

  @override
  Future<String> createMedication(CreateMedicationModel data) async {
    final response = await apiClient.post(
      '/api/v1/client/medications',
      data: data.toJson(),
    );
    // ApiUpsertSuccessResponseDto carries the new medication's id in `data`,
    // not `message` - callers (sync's offline-id mapping) depend on this
    // being the real id, not a human-readable message.
    return response['data'] as String;
  }

  @override
  Future<MedicationDetailModel> getMedicationById(String id) async {
    final response = await apiClient.get('/api/v1/client/medications/$id');
    return MedicationDetailModel.fromJson(response['data']);
  }

  @override
  Future<String> updateMedication(String id, UpdateMedicationModel data) async {
    final response = await apiClient.patch(
      '/api/v1/client/medications/$id',
      data: data.toJson(),
    );
    return response['message'] as String? ?? 'Updated successfully';
  }

  @override
  Future<SeededMedicationListResponseModel> getPreloadedMedications({int page = 1, int limit = 10, String? search}) async {
    final Map<String, dynamic> query = {'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    final response = await apiClient.get(
      '/api/v1/client/medications/preloaded',
      queryParameters: query,
    );
    return SeededMedicationListResponseModel.fromJson(response['data']);
  }
}
