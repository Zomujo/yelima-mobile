// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasConsented: json['hasConsented'] as bool? ?? false,
      registrationStatus: $enumDecodeNullable(
              _$RegistrationStatusEnumMap, json['registrationStatus']) ??
          RegistrationStatus.personalDetails,
      modeOfRegistration: json['modeOfRegistration'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      if (instance.firstName case final value?) 'firstName': value,
      if (instance.lastName case final value?) 'lastName': value,
      if (instance.gender case final value?) 'gender': value,
      if (instance.dateOfBirth?.toIso8601String() case final value?)
        'dateOfBirth': value,
      'conditions': instance.conditions,
      'hasConsented': instance.hasConsented,
      'registrationStatus':
          _$RegistrationStatusEnumMap[instance.registrationStatus]!,
      if (instance.modeOfRegistration case final value?)
        'modeOfRegistration': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
    };

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.personalDetails: 'personalDetails',
  RegistrationStatus.dob: 'dob',
  RegistrationStatus.healthConditions: 'healthConditions',
  RegistrationStatus.complete: 'complete',
};
