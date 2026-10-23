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
import 'package:clock/clock.dart';

class UserController extends ChangeNotifier with SafeNotifier {
  // --------------------------------------------------------------------------
  // |                                  State & Dependencies                  |
  // --------------------------------------------------------------------------

  final UserRepository _repository;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<UserEntity?>? _userProfileSubscription;

  // --------------------------------------------------------------------------
  // |                               Initialization & Lifecycle                |
  // --------------------------------------------------------------------------

  UserController({
    required UserRepository repository,
    required FirebaseAuth firebaseAuth,
  })  : _repository = repository,
        _firebaseAuth = firebaseAuth {
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
        _firebaseAuth.authStateChanges().listen((user) async {
      final stamp = ++_userEventStamp;

      if (user == null) {
        await _userProfileSubscription?.cancel();
        _userProfileSubscription = null;
        state = state.copyWith(
            userEntity: null, isInitialized: true, profileUnavailable: false);
      } else {
        state = state.copyWith(isInitialized: false);

        UserEntity? resolvedProfile =
            await _repository.getCachedProfile(user.uid);
        if (stamp != _userEventStamp) return;

        var unavailable = false;
        if (resolvedProfile == null) {
          final result = await _repository.getUserProfile(user.uid).timeout(
                const Duration(seconds: 6),
                onTimeout: () => left('Profile fetch timed out'),
              );
          if (stamp != _userEventStamp) return;
          result.fold(
            // Couldn't load it: don't treat a registered user as new.
            (error) => unavailable = true,
            (profile) => resolvedProfile = profile,
          );
        }

        state = state.copyWith(
            userEntity: resolvedProfile,
            isInitialized: true,
            profileUnavailable: unavailable);
        if (!unavailable) refreshProfile(user);
      }
    });
  }

  /// Refreshes the user profile from the network and subscribes to offline changes.

  // --------------------------------------------------------------------------
  // |                                   Actions & Methods                    |
  // --------------------------------------------------------------------------

  Future<void> refreshProfile(User user) async {
    final stamp = _userEventStamp;
    final profileResult = await _repository.getUserProfile(user.uid);
    if (stamp != _userEventStamp) return;
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

  /// Tries loading the profile again after it couldn't be loaded.
  Future<void> retryProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    final stamp = _userEventStamp;
    state = state.copyWith(isLoading: true);
    final result = await _repository.getUserProfile(user.uid);
    if (stamp != _userEventStamp) return;
    result.fold(
      (_) => state = state.copyWith(isLoading: false),
      (profile) {
        state = state.copyWith(
            userEntity: profile, profileUnavailable: false, isLoading: false);
        refreshProfile(user);
      },
    );
  }

  /// Completes once the profile has loaded (or failed to), or after [timeout].
  Future<void> whenInitialized(
      {Duration timeout = const Duration(seconds: 8)}) async {
    if (isInitialized) return;
    final done = Completer<void>();
    void check() {
      if (isInitialized && !done.isCompleted) done.complete();
    }

    addListener(check);
    try {
      await done.future.timeout(timeout, onTimeout: () {});
    } finally {
      removeListener(check);
    }
  }

  /// The profile couldn't be loaded, so the app shows a retry screen instead of registration.
  bool get profileUnavailable => _state.profileUnavailable;

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }

  void _showError(BuildContext context, String message) {
    AppSnackBar.showError(context, message: message);
  }

  /// Marks a tutorial as completed by the user
  Future<void> markTutorialCompleted(String tutorialId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || state.userEntity == null) return;

    final currentTutorials =
        List<String>.from(state.userEntity!.completedTutorials);
    if (currentTutorials.contains(tutorialId)) return;

    currentTutorials.add(tutorialId);

    // Update state immediately for fast UI feedback
    state = state.copyWith(
      userEntity: state.userEntity!.copyWith(
        completedTutorials: currentTutorials,
      ),
    );

    // Persist to backend and local DB
    final data = {
      'completedTutorials': currentTutorials,
    };
    await _repository.updateUserProfile(user.uid, data);
  }

  /// Updates the user's basic information such as name and gender.
  AsyncResponse<void> updateBasicInfo(
    BuildContext context, {
    required String firstName,
    required String lastName,
    required String gender,
    required String phoneNumber,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return left('User not authenticated');

    GlobalAsyncLoader.show(context, message: "Saving details...");

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final newStatus = (state.userEntity?.registrationStatus ??
                RegistrationStatus.personalDetails)
            .atLeast(RegistrationStatus.dob);

        final data = {
          'id': user.uid,
          'email': user.email ?? '',
          'firstName': firstName,
          'lastName': lastName,
          'gender': gender,
          'phoneNumber': phoneNumber,
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
        final newStatus = (state.userEntity?.registrationStatus ??
                RegistrationStatus.personalDetails)
            .atLeast(RegistrationStatus.dob);

        final currentEntity = state.userEntity ??
            UserEntity(id: user.uid, email: user.email ?? '');

        state = state.copyWith(
          userEntity: currentEntity.copyWith(
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            phoneNumber: phoneNumber,
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
    final user = _firebaseAuth.currentUser;
    if (user == null) return left('User not authenticated');

    GlobalAsyncLoader.show(context, message: "Saving date of birth...");

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final newStatus = (state.userEntity?.registrationStatus ??
                RegistrationStatus.personalDetails)
            .atLeast(RegistrationStatus.healthConditions);

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
        final newStatus = (state.userEntity?.registrationStatus ??
                RegistrationStatus.personalDetails)
            .atLeast(RegistrationStatus.healthConditions);

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
  /// Saves health conditions and transitions to facility selection.
  AsyncResponse<void> updateHealthConditions(
    BuildContext context, {
    required HealthConditionCategory? category,
    required bool consented,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || state.userEntity == null || category == null) {
      return left('Invalid user state or missing category');
    }

    GlobalAsyncLoader.show(context, message: "Saving health conditions...");

    final conditionsPayload = category.toBackendPayload;

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final newStatus = (state.userEntity?.registrationStatus ??
                RegistrationStatus.personalDetails)
            .atLeast(RegistrationStatus.facilitySelection);

        final data = {
          'conditions': conditionsPayload,
          'hasConsented': consented,
          'registrationStatus': newStatus.name,
        };

        return await _repository.updateUserProfile(user.uid, data);
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
        final newStatus = (state.userEntity?.registrationStatus ??
                RegistrationStatus.personalDetails)
            .atLeast(RegistrationStatus.facilitySelection);

        state = state.copyWith(
          userEntity: state.userEntity!.copyWith(
            conditions: conditionsPayload,
            hasConsented: consented,
            registrationStatus: newStatus,
          ),
        );
        return right(null);
      },
    );
  }

  /// Finalizes onboarding by updating the user's facility and calling the onboard API.
  AsyncResponse<void> submitOnboarding(
    BuildContext context, {
    required String facilityId,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || state.userEntity == null) {
      return left('Invalid user state');
    }

    GlobalAsyncLoader.show(context, message: "Completing profile...");

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final onboardData = {
          "firstname": state.userEntity!.firstName ?? '',
          "lastname": state.userEntity!.lastName ?? '',
          "gender":
              state.userEntity!.gender?.toLowerCase() ?? 'prefer_not_to_say',
          "dateOfBirth":
              state.userEntity!.dateOfBirth?.toUtc().toIso8601String() ??
                  clock.now().toUtc().toIso8601String(),
          "age": state.userEntity!.age ?? 0,
          "chronicConditions":
              state.userEntity!.conditions.map((c) => c.toLowerCase()).toList(),
          "facilityId": facilityId,
          "phoneNumber": state.userEntity!.phoneNumber ?? '',
        };

        final onboardResult = await _repository.onboardUser(onboardData);

        return await onboardResult.fold(
          (error) async {
            // Treat 409 Conflict as success (user already onboarded)
            final msg = error.message?.toLowerCase() ?? '';
            if (msg.contains('409') || msg.contains('already exists')) {
              final data = {
                'facilityId': facilityId,
                'registrationStatus': RegistrationStatus.complete.name,
                'createdAt': clock.now().toIso8601String(),
              };
              return await _repository.updateUserProfile(user.uid, data);
            }
            return left(error.message ?? 'Failed to onboard');
          },
          (_) async {
            final data = {
              'facilityId': facilityId,
              'registrationStatus': RegistrationStatus.complete.name,
              'createdAt': clock.now().toIso8601String(),
            };

            return await _repository.updateUserProfile(user.uid, data);
          },
        );
      },
      operationName: 'submitOnboarding',
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
            facilityId: facilityId,
            registrationStatus: RegistrationStatus.complete,
            createdAt: clock.now(),
          ),
        );
        return right(null);
      },
    );
  }
}
