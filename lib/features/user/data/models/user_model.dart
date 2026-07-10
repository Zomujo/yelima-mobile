import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    @Default([]) List<String> conditions,
    @Default(false) bool hasConsented,
    @Default(RegistrationStatus.personalDetails) RegistrationStatus registrationStatus,
    String? modeOfRegistration,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Mapper to convert from Data Layer to Domain Layer
  UserEntity toDomain() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      conditions: conditions,
      hasConsented: hasConsented,
      registrationStatus: registrationStatus,
      modeOfRegistration: modeOfRegistration,
      createdAt: createdAt,
    );
  }

  /// Mapper from Domain Layer to Data Layer
  factory UserModel.fromDomain(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      gender: entity.gender,
      dateOfBirth: entity.dateOfBirth,
      conditions: entity.conditions,
      hasConsented: entity.hasConsented,
      registrationStatus: entity.registrationStatus,
      modeOfRegistration: entity.modeOfRegistration,
      createdAt: entity.createdAt,
    );
  }
}
