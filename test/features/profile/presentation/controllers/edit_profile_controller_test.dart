import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/profile/presentation/controllers/edit_profile_controller.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

class MockUserController extends Mock implements UserController {}

void main() {
  late MockUserController users;
  late EditProfileController controller;

  setUp(() {
    users = MockUserController();
    when(() => users.updateName(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        gender: any(named: 'gender'))).thenAnswer((_) async => right(null));
    controller = EditProfileController(userController: users)
      ..init(const UserEntity(
          id: 'uid-1',
          email: 'ama@example.com',
          firstName: 'Ama',
          lastName: 'Mensah',
          gender: 'Female'));
  });

  test('saves the trimmed name and gender', () async {
    controller.updateForm(firstName: ' Akua ');

    await controller.saveProfile();

    verify(() => users.updateName(
        firstName: 'Akua', lastName: 'Mensah', gender: 'Female')).called(1);
    expect(controller.state.isButtonEnabled, isFalse);
  });

  test('enables Save only when something changed and the form is valid', () {
    expect(controller.state.isButtonEnabled, isFalse);

    controller.updateForm(lastName: 'Owusu');
    expect(controller.state.isButtonEnabled, isTrue);

    controller.updateForm(lastName: '   ');
    expect(controller.state.isButtonEnabled, isFalse);

    controller.updateForm(lastName: 'Mensah');
    expect(controller.state.isButtonEnabled, isFalse, reason: 'back to start');
  });
}
