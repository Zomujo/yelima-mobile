import '../../domain/entities/medication_entity.dart';
import 'medication_model.dart';

class MedicationListResponseModel extends MedicationListResponse {
  const MedicationListResponseModel({
    required super.rows,
    required super.total,
    required super.pageSize,
    required super.page,
    required super.totalPages,
  });

  factory MedicationListResponseModel.fromJson(Map<String, dynamic> json) {
    var rowsList = <MedicationModel>[];
    if (json['rows'] != null) {
      json['rows'].forEach((v) {
        rowsList.add(MedicationModel.fromJson(v));
      });
    }
    return MedicationListResponseModel(
      rows: rowsList,
      total: json['total'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
