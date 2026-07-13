import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/mutation_sync_manager.dart';
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
          return left('Offline user profile not found. Please connect to the internet.');
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
    return ExceptionWrapper.runAsync<void>(
      () async {
        final isConnected = await connectivityService.isConnected;

        // Sync to local SQLite to prevent offline desync
        final currentProfile = await db.userProfilesDao.getProfile(uid);
        if (currentProfile != null) {
          final updatedCompanion = UserProfilesCompanion(
            id: drift.Value(uid),
            email: drift.Value(data['email'] ?? currentProfile.email),
            firstName: data.containsKey('firstName') ? drift.Value(data['firstName']) : drift.Value(currentProfile.firstName),
            lastName: data.containsKey('lastName') ? drift.Value(data['lastName']) : drift.Value(currentProfile.lastName),
            gender: data.containsKey('gender') ? drift.Value(data['gender']) : drift.Value(currentProfile.gender),
            dateOfBirth: data.containsKey('dateOfBirth') ? drift.Value(DateTime.parse(data['dateOfBirth'])) : drift.Value(currentProfile.dateOfBirth),
            conditionsJson: data.containsKey('conditions') ? drift.Value(jsonEncode(data['conditions'])) : drift.Value(currentProfile.conditionsJson),
            hasConsented: data.containsKey('hasConsented') ? drift.Value(data['hasConsented']) : drift.Value(currentProfile.hasConsented),
            registrationStatus: data.containsKey('registrationStatus') ? drift.Value(data['registrationStatus']) : drift.Value(currentProfile.registrationStatus),
          );
          await db.userProfilesDao.insertOrUpdateProfile(updatedCompanion);
        } else {
          // If no local profile exists yet, create a stub with the known data
          final newCompanion = UserProfilesCompanion.insert(
            id: uid,
            email: data['email'] ?? '',
            firstName: data.containsKey('firstName') ? drift.Value(data['firstName']) : const drift.Value.absent(),
            lastName: data.containsKey('lastName') ? drift.Value(data['lastName']) : const drift.Value.absent(),
            gender: data.containsKey('gender') ? drift.Value(data['gender']) : const drift.Value.absent(),
            dateOfBirth: data.containsKey('dateOfBirth') ? drift.Value(DateTime.parse(data['dateOfBirth'])) : const drift.Value.absent(),
            conditionsJson: data.containsKey('conditions') ? drift.Value(jsonEncode(data['conditions'])) : const drift.Value.absent(),
            hasConsented: data.containsKey('hasConsented') ? drift.Value(data['hasConsented']) : const drift.Value.absent(),
            registrationStatus: data.containsKey('registrationStatus') ? drift.Value(data['registrationStatus']) : const drift.Value.absent(),
          );
          await db.userProfilesDao.insertOrUpdateProfile(newCompanion);
        }

        if (!isConnected) {
          await db.pendingMutationsDao.queueMutation(
            entityId: uid,
            entityType: 'user_profile',
            action: 'updateUserProfile',
            payload: data,
          );
          try {
            if (GetIt.instance.isRegistered<MutationSyncManager>()) {
              GetIt.instance<MutationSyncManager>().triggerSync();
            }
          } catch (_) {}
        } else {
          try {
            await remoteDataSource.updateUserProfile(uid, data);
          } catch (e) {
            await db.pendingMutationsDao.queueMutation(
              entityId: uid,
              entityType: 'user_profile',
              action: 'updateUserProfile',
              payload: data,
            );
            if (e is ApiException && (e.code == '401' || e.code == '403')) {
              rethrow;
            }
          }
        }
        
        return right(null);
      },
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
