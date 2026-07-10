import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_list_response.dart';

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
          ? DateTime.parse(json['appointmentDate'])
          : DateTime.now(),
      hostPersonnel: HostPersonnelModel.fromJson(json['hostPersonnel'] ?? {}),
    );
  }
}

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
      rows: (data['rows'] as List<dynamic>?)
              ?.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: data['total'] as int? ?? 0,
      pageSize: data['pageSize'] as int? ?? 10,
      page: data['page'] as int? ?? 1,
      totalPages: data['totalPages'] as int? ?? 1,
      nextPage: data['nextPage'] as int?,
    );
  }
}
