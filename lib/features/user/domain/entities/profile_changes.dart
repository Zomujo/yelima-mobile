import 'user_entity.dart';

/// Profile fields to change; null fields are left as they are.
class ProfileChanges {
  const ProfileChanges({
    this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.phoneNumber,
    this.dateOfBirth,
    this.conditions,
    this.completedTutorials,
    this.hasConsented,
    this.registrationStatus,
    this.facilityId,
    this.createdAt,
  });

  final String? email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final List<String>? conditions;
  final List<String>? completedTutorials;
  final bool? hasConsented;
  final RegistrationStatus? registrationStatus;
  final String? facilityId;
  final DateTime? createdAt;

  /// [profile] with these changes applied.
  UserEntity applyTo(UserEntity profile) => profile.copyWith(
        email: email ?? profile.email,
        firstName: firstName ?? profile.firstName,
        lastName: lastName ?? profile.lastName,
        gender: gender ?? profile.gender,
        phoneNumber: phoneNumber ?? profile.phoneNumber,
        dateOfBirth: dateOfBirth ?? profile.dateOfBirth,
        conditions: conditions ?? profile.conditions,
        completedTutorials: completedTutorials ?? profile.completedTutorials,
        hasConsented: hasConsented ?? profile.hasConsented,
        registrationStatus: registrationStatus ?? profile.registrationStatus,
        facilityId: facilityId ?? profile.facilityId,
        createdAt: createdAt ?? profile.createdAt,
      );
}
