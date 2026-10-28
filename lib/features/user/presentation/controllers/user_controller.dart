import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/entities/profile_changes.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/models/facility_model.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

/// Holds the signed-in patient's profile and saves changes to it.
class UserController extends ChangeNotifier with SafeNotifier {
  UserController({required UserRepository repository})
      : _repository = repository;

  final UserRepository _repository;
  StreamSubscription<UserEntity?>? _watch;
  AuthUser? _user;

  /// Bumped on every login change, so late results for a previous user are dropped.
  int _stamp = 0;

  UserState _state = const UserState();
  UserState get state => _state;
  set state(UserState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  UserEntity? get userEntity => _state.userEntity;
  bool get isInitialized => _state.isInitialized;

  /// The profile couldn't be loaded, so the app offers a retry instead of registration.
  bool get profileUnavailable => _state.profileUnavailable;

  /// Loads the signed-in user's profile, or clears it on sign-out. Called by AuthController.
  Future<void> onUserChanged(AuthUser? user) async {
    final stamp = ++_stamp;
    _user = user;
    if (user == null) {
      await _watch?.cancel();
      _watch = null;
      state = const UserState(isInitialized: true);
      return;
    }
    state = state.copyWith(isInitialized: false);
    var profile = await _repository.getCachedProfile(user.uid);
    if (stamp != _stamp) return;

    var unavailable = false;
    if (profile == null) {
      final result = await _repository.fetchProfile(user.uid).timeout(
          const Duration(seconds: 6),
          onTimeout: () => left(const NetworkFailure()));
      if (stamp != _stamp) return;
      // Not loaded is not the same as new: don't send a registered user to registration.
      result.fold((_) => unavailable = true, (p) => profile = p);
    }
    state = state.copyWith(
        userEntity: profile,
        isInitialized: true,
        profileUnavailable: unavailable);
    if (!unavailable) _refresh(user.uid, stamp);
  }

  /// Tries loading the profile again after it couldn't be loaded.
  Future<void> retryProfile() async {
    final user = _user;
    if (user == null) return;
    final stamp = _stamp;
    state = state.copyWith(isLoading: true);
    final result = await _repository.fetchProfile(user.uid);
    if (stamp != _stamp) return;
    result.fold(
      (_) => state = state.copyWith(isLoading: false),
      (profile) {
        state = state.copyWith(
            userEntity: profile, profileUnavailable: false, isLoading: false);
        _refresh(user.uid, stamp);
      },
    );
  }

  /// Saves the name, gender and phone from registration step one.
  AsyncResult<void> updateBasicInfo({
    required String firstName,
    required String lastName,
    required String gender,
    required String phoneNumber,
  }) =>
      _save(ProfileChanges(
        email: _user?.email ?? '',
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        phoneNumber: phoneNumber,
        registrationStatus: _reached(RegistrationStatus.dob),
      ));

  /// Saves the date of birth.
  AsyncResult<void> updateDob(DateTime dob) => _save(ProfileChanges(
        dateOfBirth: dob,
        registrationStatus: _reached(RegistrationStatus.healthConditions),
      ));

  /// Saves the patient's conditions and consent.
  AsyncResult<void> updateHealthConditions(
          {required HealthConditionCategory category,
          required bool consented}) =>
      _save(ProfileChanges(
        conditions: category.conditions,
        hasConsented: consented,
        registrationStatus: _reached(RegistrationStatus.facilitySelection),
      ));

  /// Saves a profile edit, also for the clinic; the registration status is never touched.
  AsyncResult<void> updateName(
          {required String firstName,
          required String lastName,
          String? gender}) =>
      _save(
          ProfileChanges(
              firstName: firstName, lastName: lastName, gender: gender),
          patient: true);

  /// Records that a tutorial was seen.
  Future<void> markTutorialCompleted(String tutorialId) async {
    final seen = userEntity?.completedTutorials;
    if (seen == null || seen.contains(tutorialId)) return;
    await _save(ProfileChanges(completedTutorials: [...seen, tutorialId]));
  }

  /// Registers the patient with [facilityId], which completes registration.
  AsyncResult<void> submitOnboarding(String facilityId) async {
    final profile = userEntity;
    if (profile == null) return left(const NotFoundFailure());
    final result = await _repository.completeOnboarding(profile, facilityId);
    result.fold((_) {}, (done) => state = state.copyWith(userEntity: done));
    return result;
  }

  /// Health facilities whose name matches [search].
  AsyncResult<List<FacilityModel>> searchFacilities(String search) =>
      _repository.searchFacilities(search);

  RegistrationStatus _reached(RegistrationStatus step) =>
      (userEntity?.registrationStatus ?? RegistrationStatus.personalDetails)
          .atLeast(step);

  AsyncResult<void> _save(ProfileChanges changes,
      {bool patient = false}) async {
    final user = _user;
    if (user == null) return left(const UnauthorizedFailure());
    final result = await (patient
        ? _repository.updatePatientProfile(user.uid, changes)
        : _repository.updateProfile(user.uid, changes));
    if (result.isRight()) {
      final current =
          userEntity ?? UserEntity(id: user.uid, email: user.email ?? '');
      state = state.copyWith(userEntity: changes.applyTo(current));
    }
    return result;
  }

  /// Refreshes from the server, then follows this phone's copy for later changes.
  Future<void> _refresh(String uid, int stamp) async {
    final result = await _repository.fetchProfile(uid);
    if (stamp != _stamp) return;
    result.fold((_) {}, (profile) {
      if (profile != null) state = state.copyWith(userEntity: profile);
    });
    await _watch?.cancel();
    _watch = _repository.watchProfile(uid).listen((profile) {
      if (profile != null || userEntity == null) {
        state = state.copyWith(userEntity: profile);
      }
    });
  }

  @override
  void dispose() {
    _watch?.cancel();
    super.dispose();
  }
}
