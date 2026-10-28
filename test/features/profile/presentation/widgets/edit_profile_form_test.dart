import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/profile/presentation/controllers/edit_profile_controller.dart';
import 'package:yelima/features/profile/presentation/widgets/edit_profile/edit_profile_form.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

import '../../../../helpers/pump_app.dart';

class MockUserController extends Mock implements UserController {}

void main() {
  testWidgets('a cleared name says it is required', (tester) async {
    const user = UserEntity(
        id: 'uid-1',
        email: 'ama@example.com',
        firstName: 'Ama',
        lastName: 'Mensah',
        gender: 'Female');
    final users = MockUserController();
    when(() => users.userEntity).thenReturn(user);
    final controller = EditProfileController(userController: users)..init(user);

    await tester.pumpApp(
      const SingleChildScrollView(child: EditProfileForm()),
      providers: [
        ChangeNotifierProvider<UserController>.value(value: users),
        ChangeNotifierProvider.value(value: controller),
      ],
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Ama'), '  ');
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    expect(controller.state.isButtonEnabled, isFalse);
  });
}
