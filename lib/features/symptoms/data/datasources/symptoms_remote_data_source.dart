import '../../../../core/api/api_client.dart';
import '../models/symptom_model.dart';

/// The symptom endpoints of the API.
class SymptomsRemoteDataSource {
  SymptomsRemoteDataSource({required this.apiClient});

  final APIClient apiClient;
  static const _path = '/api/v1/client/symptoms';

  /// Reports a symptom and returns its server id.
  Future<String> createSymptom(String description) async =>
      (await apiClient.post(_path, data: {'description': description}))['data']
          as String;

  /// The latest 100 symptoms.
  Future<List<SymptomModel>> getSymptoms() async {
    final response = await apiClient
        .get(_path, queryParameters: {'page': 1, 'pageSize': 100});
    return [
      for (final row in response['data']['rows'] as List)
        SymptomModel.fromJson(row)
    ];
  }
}
