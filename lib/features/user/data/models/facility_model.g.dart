// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FacilityModel _$FacilityModelFromJson(Map<String, dynamic> json) =>
    _FacilityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$FacilityModelToJson(_FacilityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      if (instance.phoneNumber case final value?) 'phoneNumber': value,
      if (instance.createdAt case final value?) 'createdAt': value,
      if (instance.updatedAt case final value?) 'updatedAt': value,
    };

_FacilityListResponse _$FacilityListResponseFromJson(
        Map<String, dynamic> json) =>
    _FacilityListResponse(
      rows: (json['rows'] as List<dynamic>)
          .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      nextPage: (json['nextPage'] as num?)?.toInt(),
      prevPage: (json['prevPage'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$FacilityListResponseToJson(
        _FacilityListResponse instance) =>
    <String, dynamic>{
      'rows': instance.rows.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'pageSize': instance.pageSize,
      'page': instance.page,
      if (instance.nextPage case final value?) 'nextPage': value,
      if (instance.prevPage case final value?) 'prevPage': value,
      'totalPages': instance.totalPages,
    };
