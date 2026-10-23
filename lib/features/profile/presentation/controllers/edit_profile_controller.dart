import 'package:flutter/foundation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../states/edit_profile_state.dart';

/// Holds the edit-profile form and saves it through [UserController].
class EditProfileController extends ChangeNotifier with SafeNotifier {
  EditProfileController({required UserController userController})
      : _users = userController;

  final UserController _users;
  EditProfileState _initial = const EditProfileState();

  EditProfileState _state = const EditProfileState();
  EditProfileState get state => _state;
  set state(EditProfileState value) {
    if (_state == value) return;
    _state = value;
    notifyListeners();
  }

  /// Fills the form from [user].
  void init(UserEntity? user) {
    if (user == null) return;
    _initial = EditProfileState(
        firstName: user.firstName ?? '',
        lastName: user.lastName ?? '',
        gender: user.gender);
    _state = _initial;
  }

  /// Updates the form and whether it can be saved.
  void updateForm({String? firstName, String? lastName, String? gender}) {
    final first = (firstName ?? state.firstName);
    final last = (lastName ?? state.lastName);
    final g = gender ?? state.gender;
    final changed = first.trim() != _initial.firstName ||
        last.trim() != _initial.lastName ||
        g != _initial.gender;
    state = state.copyWith(
      firstName: first,
      lastName: last,
      gender: g,
      hasChanged: changed,
      isButtonEnabled: changed &&
          first.trim().isNotEmpty &&
          last.trim().isNotEmpty &&
          g != null,
    );
  }

  /// Saves the form.
  AsyncResult<void> saveProfile() async {
    final result = await _users.updateName(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        gender: state.gender);
    if (result.isRight()) {
      _initial = EditProfileState(
          firstName: state.firstName.trim(),
          lastName: state.lastName.trim(),
          gender: state.gender);
      state = state.copyWith(hasChanged: false, isButtonEnabled: false);
    }
    return result;
  }
}
