import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/profile_changes.dart';
import '../../domain/entities/user_entity.dart';

/// Profile changes as sent to the server and written to the local table.
extension ProfileChangesData on ProfileChanges {
  /// Only the changed fields, so an edit never resets anything else.
  Map<String, dynamic> toJson() => {
        if (email != null) 'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (gender != null) 'gender': gender,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
        if (conditions != null) 'conditions': conditions,
        if (completedTutorials != null) 'completedTutorials': completedTutorials,
        if (hasConsented != null) 'hasConsented': hasConsented,
        if (registrationStatus != null)
          'registrationStatus': registrationStatus!.name,
        if (facilityId != null) 'facilityId': facilityId,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  /// The changed columns; the others stay absent.
  UserProfilesCompanion toCompanion() => UserProfilesCompanion(
        email: Value.absentIfNull(email),
        firstName: Value.absentIfNull(firstName),
        lastName: Value.absentIfNull(lastName),
        gender: Value.absentIfNull(gender),
        phoneNumber: Value.absentIfNull(phoneNumber),
        dateOfBirth: Value.absentIfNull(dateOfBirth),
        conditionsJson:
            Value.absentIfNull(conditions == null ? null : jsonEncode(conditions)),
        completedTutorialsJson: Value.absentIfNull(
            completedTutorials == null ? null : jsonEncode(completedTutorials)),
        hasConsented: Value.absentIfNull(hasConsented),
        registrationStatus: Value.absentIfNull(registrationStatus?.name),
        facilityId: Value.absentIfNull(facilityId),
        createdAt: Value.absentIfNull(createdAt),
      );
}

/// A full profile as a local row.
extension UserEntityRow on UserEntity {
  UserProfilesCompanion toRow() => UserProfilesCompanion.insert(
        id: id,
        email: email,
        firstName: Value(firstName),
        lastName: Value(lastName),
        gender: Value(gender),
        phoneNumber: Value(phoneNumber),
        dateOfBirth: Value(dateOfBirth),
        conditionsJson: Value(jsonEncode(conditions)),
        completedTutorialsJson: Value(jsonEncode(completedTutorials)),
        hasConsented: Value(hasConsented),
        registrationStatus: Value(registrationStatus.name),
        modeOfRegistration: Value(modeOfRegistration),
        facilityId: Value(facilityId),
        createdAt: Value(createdAt),
      );
}

/// A local row as a profile.
extension UserProfileEntity on UserProfile {
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        conditions: _strings(conditionsJson),
        completedTutorials: _strings(completedTutorialsJson),
        hasConsented: hasConsented,
        registrationStatus: RegistrationStatus.values.firstWhere(
            (s) => s.name == registrationStatus,
            orElse: () => RegistrationStatus.personalDetails),
        modeOfRegistration: modeOfRegistration,
        facilityId: facilityId,
        createdAt: createdAt,
      );

  static List<String> _strings(String json) {
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return const [];
    }
  }
}
