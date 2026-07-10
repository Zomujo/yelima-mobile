import 'package:equatable/equatable.dart';
import 'appointment_entity.dart';

class AppointmentListResponse extends Equatable {
  final List<AppointmentEntity> rows;
  final int total;
  final int pageSize;
  final int page;
  final int totalPages;
  final int? nextPage;

  const AppointmentListResponse({
    required this.rows,
    required this.total,
    required this.pageSize,
    required this.page,
    required this.totalPages,
    this.nextPage,
  });

  @override
  List<Object?> get props => [rows, total, pageSize, page, totalPages, nextPage];
}
