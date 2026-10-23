import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:clock/clock.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

/// Registration steps in order; the profile is usable once [complete].
enum RegistrationStatus {
  @JsonValue('personalDetails')
  personalDetails,
  @JsonValue('dob')
  dob,
  @JsonValue('healthConditions')
  healthConditions,
  @JsonValue('facilitySelection')
  facilitySelection,
  @JsonValue('complete')
  complete
}

extension RegistrationStatusX on RegistrationStatus {
  /// This status, or [step] if that is further along: registration never goes backwards.
  RegistrationStatus atLeast(RegistrationStatus step) =>
      index >= step.index ? this : step;
}

/// The chronic conditions a patient can register with.
enum HealthConditionCategory {
  hypertension(['hypertension']),
  diabetes(['diabetes']),
  both(['diabetes', 'hypertension']);

  const HealthConditionCategory(this.conditions);

  /// The condition names the backend stores.
  final List<String> conditions;

  /// The category matching stored [names], or null if there are none.
  static HealthConditionCategory? from(List<String> names) =>
      switch ((names.contains('hypertension'), names.contains('diabetes'))) {
        (true, true) => both,
        (true, false) => hypertension,
        (false, true) => diabetes,
        _ => null,
      };
}

/// Whole years between [date] and today.
int yearsSince(DateTime date) {
  final today = clock.now();
  final hadBirthday = today.month > date.month ||
      (today.month == date.month && today.day >= date.day);
  return today.year - date.year - (hadBirthday ? 0 : 1);
}

/// A patient's profile.
@freezed
abstract class UserEntity with _$UserEntity {
  const UserEntity._();

  /// First and last name, or empty if neither is set.
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  /// The first letter of the name, for avatars; empty if there is no name.
  String get initial => fullName.isEmpty ? '' : fullName[0].toUpperCase();

  int? get age => dateOfBirth == null ? null : yearsSince(dateOfBirth!);

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
    String? phoneNumber,
    DateTime? dateOfBirth,
    @Default([]) List<String> conditions,
    @Default([]) List<String> completedTutorials,
    @Default(false) bool hasConsented,
    @Default(RegistrationStatus.personalDetails)
    RegistrationStatus registrationStatus,
    String? modeOfRegistration,
    String? facilityId,
    DateTime? createdAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
