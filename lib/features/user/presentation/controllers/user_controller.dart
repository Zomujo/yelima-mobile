import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../shared/widgets/loaders/global_async_loader.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../../core/utils/custom_types.dart';
import '../../../../core/exceptions/exceptions.dart';
import 'user_state.dart';
import '../../../../core/utils/safe_notifier.dart';

class UserController extends ChangeNotifier with SafeNotifier {
  final UserRepository _repository;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<UserEntity?>? _userProfileSubscription;

  UserController({
    required UserRepository repository,
  }) : _repository = repository {
    _initializeAuthStateListener();
  }

  UserState _state = const UserState();
  UserState get state => _state;

  set state(UserState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  UserEntity? get userEntity => _state.userEntity;
  bool get isInitialized => _state.isInitialized;

  int _userEventStamp = 0;

  void _initializeAuthStateListener() {
    _authStateSubscription?.cancel();
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      final stamp = ++_userEventStamp;

      if (user == null) {
        state = state.copyWith(userEntity: null, isInitialized: true);
      } else {
        state = state.copyWith(isInitialized: false);

        UserEntity? resolvedProfile =
            await _repository.getCachedProfile(user.uid);
        if (stamp != _userEventStamp) return;

        if (resolvedProfile == null) {
          final result = await _repository.getUserProfile(user.uid).timeout(
                const Duration(seconds: 6),
                onTimeout: () => left('Profile fetch timed out'),
              );
          if (stamp != _userEventStamp) return;
          result.fold(
            (error) {},
            (profile) => resolvedProfile = profile,
          );
        }

        state =
            state.copyWith(userEntity: resolvedProfile, isInitialized: true);
        refreshProfile(user);
      }
    });
  }

  /// Refreshes the user profile from the network and subscribes to offline changes.
  Future<void> refreshProfile(User user) async {
    final profileResult = await _repository.getUserProfile(user.uid);
    profileResult.fold(
      (error) {},
      (profile) {
        if (profile != null && profile != state.userEntity) {
          state = state.copyWith(userEntity: profile);
        }
      },
    );

    _userProfileSubscription?.cancel();
    _userProfileSubscription =
        _repository.watchUserProfile(user.uid).listen((entity) {
      if (entity != null || state.userEntity == null) {
        state = state.copyWith(userEntity: entity);
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }

  void _showError(BuildContext context, String message) {
    AppSnackBar.showError(context, message: message);
  }

  /// Updates the user's basic information such as name and gender.
  AsyncResponse<void> updateBasicInfo(
    BuildContext context, {
    required String firstName,
    required String lastName,
    required String gender,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return left('User not authenticated');

    GlobalAsyncLoader.show(context, message: "Saving details...");

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final currentStatusIndex =
            state.userEntity?.registrationStatus.index ?? 0;
        final newStatus = currentStatusIndex > RegistrationStatus.dob.index
            ? state.userEntity!.registrationStatus
            : RegistrationStatus.dob;

        final data = {
          'id': user.uid,
          'email': user.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'gender': gender,
          'registrationStatus': newStatus.name,
        };

        return await _repository.updateUserProfile(user.uid, data);
      },
      operationName: 'updateBasicInfo',
    );

    GlobalAsyncLoader.hide();

    return response.fold(
      (error) {
        _showError(context, error);
        return left(error);
      },
      (_) {
        final currentStatusIndex =
            state.userEntity?.registrationStatus.index ?? 0;
        final newStatus = currentStatusIndex > RegistrationStatus.dob.index
            ? state.userEntity!.registrationStatus
            : RegistrationStatus.dob;

        final currentEntity = state.userEntity ??
            UserEntity(id: user.uid, email: user.email ?? '');

        state = state.copyWith(
          userEntity: currentEntity.copyWith(
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            registrationStatus: newStatus,
          ),
        );
        return right(null);
      },
    );
  }

  /// Updates the user's date of birth.
  AsyncResponse<void> updateDob(BuildContext context,
      {required DateTime dob}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return left('User not authenticated');

    GlobalAsyncLoader.show(context, message: "Saving date of birth...");

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final currentStatusIndex =
            state.userEntity?.registrationStatus.index ?? 0;
        final newStatus =
            currentStatusIndex > RegistrationStatus.healthConditions.index
                ? state.userEntity!.registrationStatus
                : RegistrationStatus.healthConditions;

        final data = {
          'dateOfBirth': dob.toIso8601String(),
          'registrationStatus': newStatus.name,
        };

        return await _repository.updateUserProfile(user.uid, data);
      },
      operationName: 'updateDob',
    );

    GlobalAsyncLoader.hide();

    return response.fold(
      (error) {
        _showError(context, error);
        return left(error);
      },
      (_) {
        final currentStatusIndex =
            state.userEntity?.registrationStatus.index ?? 0;
        final newStatus =
            currentStatusIndex > RegistrationStatus.healthConditions.index
                ? state.userEntity!.registrationStatus
                : RegistrationStatus.healthConditions;

        if (state.userEntity != null) {
          state = state.copyWith(
            userEntity: state.userEntity!.copyWith(
              dateOfBirth: dob,
              registrationStatus: newStatus,
            ),
          );
        }
        return right(null);
      },
    );
  }

  /// Finalizes onboarding by updating the user's health conditions and consent.
  AsyncResponse<void> updateHealthConditions(
    BuildContext context, {
    required HealthConditionCategory? category,
    required bool consented,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || state.userEntity == null || category == null) {
      return left('Invalid user state or missing category');
    }

    GlobalAsyncLoader.show(context, message: "Completing profile...");

    final conditionsPayload = category.toBackendPayload;

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final onboardData = {
          "firstname": state.userEntity!.firstName ?? '',
          "lastname": state.userEntity!.lastName ?? '',
          "gender":
              state.userEntity!.gender?.toLowerCase() ?? 'prefer_not_to_say',
          "dateOfBirth":
              state.userEntity!.dateOfBirth?.toUtc().toIso8601String() ??
                  DateTime.now().toUtc().toIso8601String(),
          "age": state.userEntity!.age ?? 0,
          "chronicConditions":
              conditionsPayload.map((c) => c.toLowerCase()).toList(),
        };

        final onboardResult = await _repository.onboardUser(onboardData);

        return await onboardResult.fold(
          (error) async {
            // Treat 409 Conflict as success (user already onboarded)
            final msg = error.message?.toLowerCase() ?? '';
            if (msg.contains('409') || msg.contains('already exists')) {
              final data = {
                'conditions': conditionsPayload,
                'hasConsented': consented,
                'registrationStatus': RegistrationStatus.complete.name,
                'createdAt': DateTime.now().toIso8601String(),
              };
              return await _repository.updateUserProfile(user.uid, data);
            }
            return left(error.message ?? 'Failed to onboard');
          },
          (_) async {
            final data = {
              'conditions': conditionsPayload,
              'hasConsented': consented,
              'registrationStatus': RegistrationStatus.complete.name,
              'createdAt': DateTime.now().toIso8601String(),
            };

            return await _repository.updateUserProfile(user.uid, data);
          },
        );
      },
      operationName: 'updateHealthConditions',
    );

    GlobalAsyncLoader.hide();

    return response.fold(
      (error) {
        _showError(context, error);
        return left(error);
      },
      (_) {
        state = state.copyWith(
          userEntity: state.userEntity!.copyWith(
            conditions: conditionsPayload,
            hasConsented: consented,
            registrationStatus: RegistrationStatus.complete,
            createdAt: DateTime.now(),
          ),
        );
        return right(null);
      },
    );
  }
}
