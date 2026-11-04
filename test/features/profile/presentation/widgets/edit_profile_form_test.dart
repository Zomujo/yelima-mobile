import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/profile/presentation/controllers/edit_profile_controller.dart';
import 'package:yelima/features/profile/presentation/widgets/edit_profile/edit_profile_form.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

import '../../../../helpers/pump_app.dart';

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
  testWidgets('a cleared name says it is required', (tester) async {
    await tester.pumpApp(
      const SingleChildScrollView(child: EditProfileForm()),
      overrides: [userControllerProvider.overrideWith(MockUserController.new)],
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Ama'), '  ');
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(EditProfileForm)));
    expect(
        container.read(editProfileControllerProvider).isButtonEnabled, isFalse);
  });
}
