import '../../../../core/api/api_client.dart';
import '../models/symptom_model.dart';

abstract class SymptomsRemoteDataSource {
  Future<String> createSymptom(String description);
  Future<List<SymptomModel>> getSymptoms({int page = 1, int pageSize = 10});
  Future<SymptomModel> getSymptomById(String id);
  Future<void> updateSymptom(String id, String description);
  Future<void> deleteSymptom(String id);
}

class SymptomsRemoteDataSourceImpl implements SymptomsRemoteDataSource {
  final APIClient apiClient;

  SymptomsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> createSymptom(String description) async {
    final response = await apiClient.post(
      '/api/v1/client/symptoms',
      data: {'description': description},
    );
    // Response example: { "data": "id", "statusCode": 0, "message": "string" }
    return response['data'] as String;
  }

  @override
  Future<List<SymptomModel>> getSymptoms({int page = 1, int pageSize = 10}) async {
    final response = await apiClient.get(
      '/api/v1/client/symptoms',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    // Response example: { "data": { "rows": [...] } }
    final data = response['data'];
    final rows = data['rows'] as List;
    return rows.map((e) => SymptomModel.fromJson(e)).toList();
  }

  @override
  Future<SymptomModel> getSymptomById(String id) async {
    final response = await apiClient.get('/api/v1/client/symptoms/$id');
    final data = response['data'];
    return SymptomModel.fromJson(data);
  }

  @override
  Future<void> updateSymptom(String id, String description) async {
    await apiClient.patch(
      '/api/v1/client/symptoms/$id',
      data: {'description': description},
    );
  }

  @override
  Future<void> deleteSymptom(String id) async {
    await apiClient.delete('/api/v1/client/symptoms/$id');
  }
}
