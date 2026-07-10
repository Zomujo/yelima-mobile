// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seeded_medication_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SeededMedicationListResponseModel _$SeededMedicationListResponseModelFromJson(
        Map<String, dynamic> json) =>
    _SeededMedicationListResponseModel(
      rows: (json['rows'] as List<dynamic>?)
              ?.map((e) =>
                  SeededMedicationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SeededMedicationListResponseModelToJson(
        _SeededMedicationListResponseModel instance) =>
    <String, dynamic>{
      'rows': instance.rows.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'pageSize': instance.pageSize,
      'page': instance.page,
      'totalPages': instance.totalPages,
    };
