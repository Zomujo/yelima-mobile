import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/profile/presentation/controllers/edit_profile_controller.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/domain/repositories/user_repository.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

class MockRepo extends Mock implements UserRepository {}

class MockUserController extends Mock implements UserController {}

class MockAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockRepo repo;
  late EditProfileController controller;

  setUpAll(() => registerFallbackValue(MockUser()));

  setUp(() {
    repo = MockRepo();
    final user = MockUser();
    when(() => user.uid).thenReturn('uid-1');
    when(() => user.email).thenReturn('ama@example.com');
    final auth = MockAuth();
    when(() => auth.currentUser).thenReturn(user);
    final users = MockUserController();
    when(() => users.refreshProfile(any())).thenAnswer((_) async {});
    when(() => repo.updateUserProfile(any(), any()))
        .thenAnswer((_) async => right(null));
    controller = EditProfileController(
        repository: repo, userController: users, firebaseAuth: auth)
      ..init(const UserEntity(
        id: 'uid-1',
        email: 'ama@example.com',
        firstName: 'Ama',
        lastName: 'Mensah',
        gender: 'Female',
        registrationStatus: RegistrationStatus.complete,
      ));
  });

  test('ACC-EC-04: saving a profile edit never sends a registration status',
      () async {
    controller.updateForm(firstName: 'Akua');

    await controller.saveProfile();

    final data = verify(() => repo.updateUserProfile('uid-1', captureAny()))
        .captured
        .single as Map<String, dynamic>;
    expect(data['firstName'], 'Akua');
    expect(data.containsKey('registrationStatus'), isFalse);
  });

  test('enables Save only when something changed and the form is valid', () {
    expect(controller.state.isButtonEnabled, isFalse);

    controller.updateForm(lastName: 'Owusu');
    expect(controller.state.isButtonEnabled, isTrue);

    controller.updateForm(lastName: '   ');
    expect(controller.state.isButtonEnabled, isFalse);
  });
}
