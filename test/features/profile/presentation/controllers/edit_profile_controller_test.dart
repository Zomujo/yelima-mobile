import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/profile/presentation/controllers/edit_profile_controller.dart';
import 'package:yelima/features/profile/presentation/states/edit_profile_state.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

class MockUserController extends Notifier<UserState>
    with Mock
    implements UserController {
  @override
  UserState build() => const UserState(
      userEntity: UserEntity(
          id: 'uid-1',
          email: 'ama@example.com',
          firstName: 'Ama',
          lastName: 'Mensah',
          gender: 'Female'));
}

void main() {
  late MockUserController users;
  late ProviderContainer container;

  setUp(() {
    users = MockUserController();
    when(() => users.updateName(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        gender: any(named: 'gender'))).thenAnswer((_) async => right(null));
    container = ProviderContainer(
        overrides: [userControllerProvider.overrideWith(() => users)]);
    addTearDown(container.dispose);
    // Keeps the screen-scoped controller alive, as the open screen does.
    container.listen(editProfileControllerProvider, (_, __) {});
  });

  EditProfileController controller() =>
      container.read(editProfileControllerProvider.notifier);
  EditProfileState state() => container.read(editProfileControllerProvider);

  test('starts filled from the profile', () {
    expect(state().firstName, 'Ama');
    expect(state().gender, 'Female');
  });

  test('saves the trimmed name and gender', () async {
    controller().updateForm(firstName: ' Akua ');

    await controller().saveProfile();

    verify(() => users.updateName(
        firstName: 'Akua', lastName: 'Mensah', gender: 'Female')).called(1);
    expect(state().isButtonEnabled, isFalse);
  });

  test('enables Save only when something changed and the form is valid', () {
    expect(state().isButtonEnabled, isFalse);

    controller().updateForm(lastName: 'Owusu');
    expect(state().isButtonEnabled, isTrue);

    controller().updateForm(lastName: '   ');
    expect(state().isButtonEnabled, isFalse);

    controller().updateForm(lastName: 'Mensah');
    expect(state().isButtonEnabled, isFalse, reason: 'back to start');
  });
}
