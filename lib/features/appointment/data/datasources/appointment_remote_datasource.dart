import 'package:yelima/core/api/api_client.dart';
import 'package:yelima/core/exceptions/exceptions.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentListResponseModel> getAppointments({
    required int page,
    required int pageSize,
    required String filter,
  });

  Future<AppointmentModel?> getNearestAppointment();

  Future<void> requestAppointment({required String note});
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final APIClient apiClient;

  AppointmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AppointmentListResponseModel> getAppointments({
    required int page,
    required int pageSize,
    required String filter,
  }) async {
    try {
      final response = await apiClient.get(
        '/api/v1/client/appointments',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'filter': filter,
        },
      );

      return AppointmentListResponseModel.fromJson(response);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Future<AppointmentModel?> getNearestAppointment() async {
    try {
      final response =
          await apiClient.get('/api/v1/client/appointments/nearest');
      if (response['data'] == null) {
        return null;
      }
      return AppointmentModel.fromJson(response['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Future<void> requestAppointment({required String note}) async {
    try {
      await apiClient.post(
        '/api/v1/client/appointment-requests',
        data: {'type': "SCHEDULE", 'note': note},
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
