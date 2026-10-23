import '../../../../core/api/api_client.dart';
import '../../domain/models/create_medication_model.dart';
import '../../domain/models/medication_detail_model.dart';
import '../../domain/models/seeded_medication_list_response_model.dart';
import '../../domain/models/update_medication_model.dart';
import '../models/medication_adherence_model.dart';
import '../models/medication_history_model.dart';
import '../models/medication_list_response_model.dart';
import '../models/medication_model.dart';

/// The medication endpoints of the API.
class MedicationRemoteDataSource {
  MedicationRemoteDataSource({required this.apiClient});

  final APIClient apiClient;
  static const _base = '/api/v1/client/medications';

  /// This week's (or month's) adherence.
  Future<MedicationAdherenceModel> getAdherence(
          {required bool showWeekdays}) async =>
      MedicationAdherenceModel.fromJson((await apiClient.get(
          '/api/v1/client/medication-adherence',
          queryParameters: {'showWeekdays': '$showWeekdays'}))['data']);

  /// Today's doses in [section].
  Future<List<MedicationModel>> getMedicationsBySection(String section) async {
    final response = await apiClient
        .get('$_base/today', queryParameters: {'section': section});
    return [
      for (final json in response['data'] as List) MedicationModel.fromJson(json)
    ];
  }

  /// Confirms the [section] dose of [scheduledFor] (yyyy-MM-dd, at most 48 h ago), or of today.
  Future<void> confirmMedication(String medicationId, String section,
          {String? scheduledFor}) =>
      apiClient.put('$_base/$medicationId/confirm', queryParameters: {
        'section': section,
        if (scheduledFor != null) 'scheduledFor': scheduledFor,
      });

  /// One page of all medications.
  Future<MedicationListResponseModel> getAllMedications(
          {int page = 1, int pageSize = 10}) async =>
      MedicationListResponseModel.fromJson((await apiClient.get(_base,
          queryParameters: {'page': page, 'pageSize': pageSize}))['data']);

  /// Doses of [medicationId] in the month of [date] (yyyy-MM-15).
  Future<MedicationHistoryModel> getMedicationHistory(String medicationId,
          {required String date}) async =>
      MedicationHistoryModel.fromJson((await apiClient.get(
          '$_base/$medicationId/adherence',
          queryParameters: {'date': date}))['data']);

  /// Creates a medication and returns its server id; [idempotencyKey] is its local id.
  Future<String> createMedication(CreateMedicationModel data,
      {required String idempotencyKey}) async {
    final created = (await apiClient.post(_base,
        data: _withEmptySlots(data.toJson()),
        options: APIClient.idempotent(idempotencyKey)))['data'];
    return created is Map
        ? (created['id'] ?? created['_id']).toString()
        : created.toString();
  }

  /// Full details of one medication.
  Future<MedicationDetailModel> getMedicationById(String id) async =>
      MedicationDetailModel.fromJson((await apiClient.get('$_base/$id'))['data']);

  /// Updates a medication.
  Future<void> updateMedication(String id, UpdateMedicationModel data) =>
      apiClient.patch('$_base/$id', data: _withEmptySlots(data.toJson()));

  /// Deletes a medication.
  Future<void> deleteMedication(String id) => apiClient.delete('$_base/$id');

  /// One page of the preloaded medication list.
  Future<SeededMedicationListResponseModel> getPreloadedMedications(
          {int page = 1, int pageSize = 10}) async =>
      SeededMedicationListResponseModel.fromJson((await apiClient.get(
          '$_base/preloaded',
          queryParameters: {'page': page, 'pageSize': pageSize}))['data']);

  /// The server wants every slot present: a removed slot is sent as null.
  static Map<String, dynamic> _withEmptySlots(Map<String, dynamic> json) => {
        'morning': null,
        'afternoon': null,
        'evening': null,
        'notes': '',
        ...json,
      };
}
