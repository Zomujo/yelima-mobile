import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../user/user_providers.dart';
import '../states/edit_profile_state.dart';

part 'edit_profile_controller.g.dart';

/// Holds the edit-profile form and saves it through the user controller.
@riverpod
class EditProfileController extends _$EditProfileController {
  EditProfileState _initial = const EditProfileState();
  bool _disposed = false;

  /// Fills the form from the signed-in user's profile.
  @override
  EditProfileState build() {
    ref.onDispose(() => _disposed = true);
    final user = ref.read(userControllerProvider).userEntity;
    if (user == null) return const EditProfileState();
    return _initial = EditProfileState(
        firstName: user.firstName ?? '',
        lastName: user.lastName ?? '',
        gender: user.gender);
  }

  /// Listeners hear only real changes, as before.
  @override
  bool updateShouldNotify(EditProfileState previous, EditProfileState next) =>
      previous != next;

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
    final result = await ref.read(userControllerProvider.notifier).updateName(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        gender: state.gender);
    if (result.isRight() && !_disposed) {
      _initial = EditProfileState(
          firstName: state.firstName.trim(),
          lastName: state.lastName.trim(),
          gender: state.gender);
      state = state.copyWith(hasChanged: false, isButtonEnabled: false);
    }
    return result;
  }
}
