import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String title;
  final DateTime appointmentDate;
  final HostPersonnelEntity hostPersonnel;

  const AppointmentEntity({
    required this.id,
    required this.title,
    required this.appointmentDate,
    required this.hostPersonnel,
  });

  @override
  List<Object?> get props => [id, title, appointmentDate, hostPersonnel];
}

class HostPersonnelEntity extends Equatable {
  final String id;
  final String userName;
  final FacilityEntity facility;

  const HostPersonnelEntity({
    required this.id,
    required this.userName,
    required this.facility,
  });

  @override
  List<Object?> get props => [id, userName, facility];
}

class FacilityEntity extends Equatable {
  final String name;

  const FacilityEntity({
    required this.name,
  });

  @override
  List<Object?> get props => [name];
}
