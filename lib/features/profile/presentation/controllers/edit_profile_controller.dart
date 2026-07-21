import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/utils/custom_types.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../states/edit_profile_state.dart';
import '../../../../core/utils/safe_notifier.dart';

class EditProfileController extends ChangeNotifier with SafeNotifier {
  final UserRepository _repository;
  final UserController _userController;

  EditProfileController({
    required UserRepository repository,
    required UserController userController,
  })  : _repository = repository,
        _userController = userController;

  EditProfileState _state = const EditProfileState();
  EditProfileState get state => _state;

  set state(EditProfileState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  String _initialFirstName = '';
  String _initialLastName = '';
  String? _initialGender;

  /// Initializes the controller with the current user's profile data.
  void init(UserEntity? user) {
    if (user == null) return;

    _initialFirstName = user.firstName ?? '';
    _initialLastName = user.lastName ?? '';
    _initialGender = user.gender;

    _state = _state.copyWith(
      firstName: _initialFirstName,
      lastName: _initialLastName,
      gender: _initialGender,
    );
  }

  /// Updates the form state and validates the changes.
  void updateForm({String? firstName, String? lastName, String? gender}) {
    state = state.copyWith(
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      gender: gender ?? state.gender,
    );
    _validateForm();
  }

  void _validateForm() {
    final first = state.firstName.trim();
    final last = state.lastName.trim();

    final hasChanged = first != _initialFirstName ||
        last != _initialLastName ||
        state.gender != _initialGender;

    final isValid = first.isNotEmpty &&
        last.isNotEmpty &&
        state.gender != null &&
        hasChanged;

    state = state.copyWith(
      hasChanged: hasChanged,
      isButtonEnabled: isValid,
    );
  }

  /// Submits the updated profile data to the backend.
  AsyncResponse<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return left('User not authenticated.');
    }

    state = state.copyWith(isSaving: true);

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final currentStatusIndex =
            _userController.userEntity?.registrationStatus.index ?? 0;
        final newStatus =
            currentStatusIndex > 1 // RegistrationStatus.dob is usually 1
                ? _userController.userEntity!.registrationStatus.name
                : 'dob';

        final data = {
          'id': user.uid,
          'email': user.email ?? '',
          'firstName': state.firstName.trim(),
          'lastName': state.lastName.trim(),
          'gender': state.gender,
          'registrationStatus': newStatus,
        };

        return await _repository.updateUserProfile(user.uid, data);
      },
      operationName: 'updateUserProfile',
    );

    return response.fold(
      (failure) {
        state = state.copyWith(isSaving: false);
        return left(failure);
      },
      (_) async {
        // Fetch fresh user data to update global state
        await _userController.refreshProfile(user);

        state = state.copyWith(
          isSaving: false,
          hasChanged: false,
          isButtonEnabled: false,
        );

        // Update initials since it saved successfully
        _initialFirstName = state.firstName;
        _initialLastName = state.lastName;
        _initialGender = state.gender;

        return right(null);
      },
    );
  }
}
