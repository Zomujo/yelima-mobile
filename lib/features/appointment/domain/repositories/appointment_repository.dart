import 'package:yelima/core/utils/custom_types.dart';
import '../entities/appointment_entity.dart';
import '../entities/appointment_list_response.dart';

abstract class AppointmentRepository {
  AsyncResponse<AppointmentListResponse> getAppointments({
    required int page,
    required int pageSize,
    required String filter,
  });

  AsyncResponse<AppointmentListResponse> getLocalAppointments({
    required int page,
    required int pageSize,
    required String filter,
  });

  AsyncResponse<AppointmentEntity?> getNearestAppointment();

  AsyncResponse<AppointmentEntity?> getLocalNearestAppointment();

  AsyncResponse<void> requestAppointment({required String note});
}
