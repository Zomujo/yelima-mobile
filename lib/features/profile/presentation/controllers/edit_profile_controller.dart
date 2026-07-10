import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/utils/custom_types.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../states/edit_profile_state.dart';

class EditProfileController extends ChangeNotifier {
  final UserRepository _repository;
  final UserController _userController;

  EditProfileController({
    required UserRepository repository,
    required UserController userController,
  })  : _repository = repository,
        _userController = userController;

  bool _isDisposed = false;
  
  EditProfileState _state = const EditProfileState();
  EditProfileState get state => _state;

  String _initialFirstName = '';
  String _initialLastName = '';
  String? _initialGender;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

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

  void updateForm({String? firstName, String? lastName, String? gender}) {
    _state = _state.copyWith(
      firstName: firstName ?? _state.firstName,
      lastName: lastName ?? _state.lastName,
      gender: gender ?? _state.gender,
    );
    _validateForm();
  }

  void _validateForm() {
    final first = _state.firstName.trim();
    final last = _state.lastName.trim();

    final hasChanged = first != _initialFirstName ||
        last != _initialLastName ||
        _state.gender != _initialGender;

    final isValid = first.isNotEmpty && last.isNotEmpty && _state.gender != null && hasChanged;
    
    _state = _state.copyWith(
      hasChanged: hasChanged,
      isButtonEnabled: isValid,
    );
    
    if (!_isDisposed) notifyListeners();
  }

  AsyncResponse<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return left('User not authenticated.');
    }

    _state = _state.copyWith(isSaving: true);
    if (!_isDisposed) notifyListeners();

    final response = await ExceptionWrapper.runAsync<void>(
      () async {
        final currentStatusIndex = _userController.userEntity?.registrationStatus.index ?? 0;
        final newStatus = currentStatusIndex > 1 // RegistrationStatus.dob is usually 1
            ? _userController.userEntity!.registrationStatus.name
            : 'dob';

        final data = {
          'id': user.uid,
          'email': user.email ?? '',
          'firstName': _state.firstName.trim(),
          'lastName': _state.lastName.trim(),
          'gender': _state.gender,
          'registrationStatus': newStatus,
        };

        return await _repository.updateUserProfile(user.uid, data);
      },
      operationName: 'updateUserProfile',
    );

    return response.fold(
      (failure) {
        _state = _state.copyWith(isSaving: false);
        if (!_isDisposed) notifyListeners();
        return left(failure);
      },
      (_) async {
        // Fetch fresh user data to update global state
        await _userController.refreshProfile(user);
        
        _state = _state.copyWith(
          isSaving: false,
          hasChanged: false,
          isButtonEnabled: false,
        );
        
        // Update initials since it saved successfully
        _initialFirstName = _state.firstName;
        _initialLastName = _state.lastName;
        _initialGender = _state.gender;
        
        if (!_isDisposed) notifyListeners();
        return right(null);
      },
    );
  }
}
