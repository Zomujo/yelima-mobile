import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:fpdart/fpdart.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/custom_types.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final AppDatabase db;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.db,
  });

  @override
  Stream<UserEntity?> watchUserProfile(String uid) {
    return db.userProfilesDao.watchProfile(uid).map((profile) {
      if (profile == null) return null;
      return _localProfileToEntity(profile);
    });
  }

  @override
  Future<UserEntity?> getCachedProfile(String uid) async {
    try {
      final profile = await db.userProfilesDao.getProfile(uid);
      if (profile == null) return null;
      return _localProfileToEntity(profile);
    } catch (_) {
      return null;
    }
  }

  @override
  AsyncResponse<UserEntity?> getUserProfile(String uid) {
    return ExceptionWrapper.runAsync<UserEntity?>(
      () async {
        try {
          if (!await connectivityService.isConnected) {
            throw const NetworkException();
          }
          final model = await remoteDataSource.getUserProfile(uid);

          if (model != null) {
            /// Save to local cache.
            await db.userProfilesDao.insertOrUpdateProfile(
              UserProfilesCompanion.insert(
                id: model.id,
                email: model.email,
                firstName: drift.Value(model.firstName),
                lastName: drift.Value(model.lastName),
                gender: drift.Value(model.gender),
                dateOfBirth: drift.Value(model.dateOfBirth),
                conditionsJson: drift.Value(jsonEncode(model.conditions)),
                hasConsented: drift.Value(model.hasConsented),
                registrationStatus: drift.Value(model.registrationStatus.name),
                modeOfRegistration: drift.Value(model.modeOfRegistration),
                createdAt: drift.Value(model.createdAt),
              )
            );
            return right(model.toDomain());
          }
          /// Check local cache if remote profile missing.
          final localProfile = await db.userProfilesDao.getProfile(uid);
          if (localProfile != null) {
            return right(_localProfileToEntity(localProfile));
          }
        } catch (_) {
          /// Fall back to local cache on error to preserve user status.
          final localProfile = await db.userProfilesDao.getProfile(uid);
          if (localProfile != null) {
            return right(_localProfileToEntity(localProfile));
          }
          /// Rethrow if no local cache exists.
          rethrow;
        }
        return right(null);
      },
      operationName: 'UserRepositoryImpl.getUserProfile',
    );
  }

  /// Converts a local DB profile row into a [UserEntity].
  UserEntity _localProfileToEntity(dynamic localProfile) {
    List<String> conditionsList = [];
    try {
      conditionsList = (jsonDecode(localProfile.conditionsJson) as List).cast<String>();
    } catch (_) {}
    return UserEntity(
      id: localProfile.id,
      email: localProfile.email,
      firstName: localProfile.firstName,
      lastName: localProfile.lastName,
      gender: localProfile.gender,
      dateOfBirth: localProfile.dateOfBirth,
      conditions: conditionsList,
      hasConsented: localProfile.hasConsented,
      registrationStatus: RegistrationStatus.values.firstWhere(
        (e) => e.name == localProfile.registrationStatus,
        orElse: () => RegistrationStatus.personalDetails,
      ),
      modeOfRegistration: localProfile.modeOfRegistration,
      createdAt: localProfile.createdAt,
    );
  }

  @override
  AsyncResponse<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.updateUserProfile(uid, data);
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'UserRepositoryImpl.updateUserProfile',
    );
  }

  @override
  AsyncResponse<void> onboardUser(Map<String, dynamic> data) {
    return ExceptionWrapper.runAsyncWithNetworkCheck<void>(
      () async {
        await remoteDataSource.onboardUser(data);
        return right(null);
      },
      connectivityService: connectivityService,
      operationName: 'UserRepositoryImpl.onboardUser',
    );
  }
}
