import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_list_response.dart';
import 'package:clock/clock.dart';

/// An appointment as the server sends it.
class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.title,
    required super.appointmentDate,
    required super.hostPersonnel,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      appointmentDate: json['appointmentDate'] != null
          ? DateTime.parse(json['appointmentDate']).toLocal()
          : clock.now(),
      hostPersonnel: HostPersonnelModel.fromJson(json['hostPersonnel'] ?? {}),
    );
  }
}

/// The clinician as the server sends it.
class HostPersonnelModel extends HostPersonnelEntity {
  const HostPersonnelModel({
    required super.id,
    required super.userName,
    required super.facility,
  });

  factory HostPersonnelModel.fromJson(Map<String, dynamic> json) {
    return HostPersonnelModel(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      facility: FacilityModel.fromJson(json['facility'] ?? {}),
    );
  }
}

/// The facility as the server sends it.
class FacilityModel extends FacilityEntity {
  const FacilityModel({
    required super.name,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      name: json['name'] as String? ?? '',
    );
  }
}

/// A page of appointments as the server sends it.
class AppointmentListResponseModel extends AppointmentListResponse {
  const AppointmentListResponseModel({
    required super.rows,
    required super.total,
    required super.pageSize,
    required super.page,
    required super.totalPages,
    super.nextPage,
  });

  factory AppointmentListResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return AppointmentListResponseModel(
      // Cancelled visits aren't shown; the server still lists them.
      rows: [
        for (final e in (data['rows'] as List<dynamic>? ?? []))
          if ((e as Map<String, dynamic>)['status'] != 'cancelled')
            AppointmentModel.fromJson(e),
      ],
      total: data['total'] as int? ?? 0,
      pageSize: data['pageSize'] as int? ?? 10,
      page: data['page'] as int? ?? 1,
      totalPages: data['totalPages'] as int? ?? 1,
      nextPage: data['nextPage'] as int?,
    );
  }
}
