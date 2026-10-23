import 'package:equatable/equatable.dart';

/// A dose in today's list.
class MedicationEntity extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String purpose;
  final DateTime toBeTakenAt;
  final bool taken;

  const MedicationEntity({
    required this.id,
    required this.name,
    required this.dosage,
    required this.purpose,
    required this.toBeTakenAt,
    required this.taken,
  });

  @override
  List<Object?> get props => [id, name, dosage, purpose, toBeTakenAt, taken];
}

/// A page of medications.
class MedicationListResponse extends Equatable {
  final List<MedicationEntity> rows;
  final int total;
  final int pageSize;
  final int page;
  final int totalPages;

  const MedicationListResponse({
    required this.rows,
    required this.total,
    required this.pageSize,
    required this.page,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [rows, total, pageSize, page, totalPages];
}
