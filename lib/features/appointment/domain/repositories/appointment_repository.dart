import '../../../../core/failures/app_failure.dart';
import '../entities/appointment_entity.dart';
import '../entities/appointment_list_response.dart';

/// Clinic appointments, cached on the phone for offline viewing.
abstract class AppointmentRepository {
  /// A page from the server (cached here), or from the phone when that fails.
  AsyncResult<AppointmentListResponse> getAppointments(
      {required int page,
      required int pageSize,
      required AppointmentFilter filter});

  /// A page from the phone only, for showing straight away.
  AsyncResult<AppointmentListResponse> getCachedAppointments(
      {required int page,
      required int pageSize,
      required AppointmentFilter filter});

  /// The next appointment from the server, or from the phone when that fails.
  AsyncResult<AppointmentEntity?> getNearestAppointment();

  /// The next appointment saved on the phone.
  AsyncResult<AppointmentEntity?> getCachedNearestAppointment();
}
