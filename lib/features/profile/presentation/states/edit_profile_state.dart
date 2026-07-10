import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_profile_state.freezed.dart';

@freezed
abstract class EditProfileState with _$EditProfileState {
  const factory EditProfileState({
    @Default('') String firstName,
    @Default('') String lastName,
    String? gender,
    @Default(false) bool isSaving,
    @Default(false) bool hasChanged,
    @Default(false) bool isButtonEnabled,
  }) = _EditProfileState;
}
