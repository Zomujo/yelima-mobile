import '../../../../core/api/api_client.dart';
import '../models/appointment_model.dart';

/// The appointment endpoints of the API.
class AppointmentRemoteDataSource {
  AppointmentRemoteDataSource({required this.apiClient});

  final APIClient apiClient;

  /// One page of appointments for [filter] (`upcoming` or `past`).
  Future<AppointmentListResponseModel> getAppointments(
          {required int page,
          required int pageSize,
          required String filter}) async =>
      AppointmentListResponseModel.fromJson(await apiClient
          .get('/api/v1/client/appointments', queryParameters: {
        'page': page,
        'pageSize': pageSize,
        'filter': filter
      }));

  /// The next appointment, or null if there is none.
  Future<AppointmentModel?> getNearestAppointment() async {
    final data =
        (await apiClient.get('/api/v1/client/appointments/nearest'))['data'];
    return data == null ? null : AppointmentModel.fromJson(data);
  }
}
