import 'package:freezed_annotation/freezed_annotation.dart';

part 'facility_model.freezed.dart';
part 'facility_model.g.dart';

@freezed
abstract class FacilityModel with _$FacilityModel {
  const factory FacilityModel({
    required String id,
    required String name,
    String? phoneNumber,
    String? createdAt,
    String? updatedAt,
  }) = _FacilityModel;

  factory FacilityModel.fromJson(Map<String, dynamic> json) =>
      _$FacilityModelFromJson(json);
}

@freezed
abstract class FacilityListResponse with _$FacilityListResponse {
  const factory FacilityListResponse({
    required List<FacilityModel> rows,
    required int total,
    required int pageSize,
    required int page,
    int? nextPage,
    int? prevPage,
    required int totalPages,
  }) = _FacilityListResponse;

  factory FacilityListResponse.fromJson(Map<String, dynamic> json) =>
      _$FacilityListResponseFromJson(json);
}
