import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

enum RegistrationStatus {
  @JsonValue('personalDetails')
  personalDetails,
  @JsonValue('dob')
  dob,
  @JsonValue('healthConditions')
  healthConditions,
  @JsonValue('complete')
  complete
}

enum HealthConditionCategory { hypertension, diabetes, both }

extension HealthConditionCategoryX on HealthConditionCategory {
  List<String> get toBackendPayload {
    switch (this) {
      case HealthConditionCategory.hypertension:
        return ['hypertension'];
      case HealthConditionCategory.diabetes:
        return ['diabetes'];
      case HealthConditionCategory.both:
        return ['diabetes', 'hypertension'];
    }
  }
}

@freezed
abstract class UserEntity with _$UserEntity {
  const UserEntity._();

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    final name = '$first $last'.trim();
    return name.isEmpty ? 'Unknown User' : name;
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get patientId {
    if (id.length >= 5) {
      return 'YEL-${id.substring(0, 5).toUpperCase()}';
    }
    return 'YEL-${id.toUpperCase()}';
  }

  const factory UserEntity({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    @Default([]) List<String> conditions,
    @Default(false) bool hasConsented,
    @Default(RegistrationStatus.personalDetails)
    RegistrationStatus registrationStatus,
    String? modeOfRegistration, // 'google', 'apple', 'email'
    DateTime? createdAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
