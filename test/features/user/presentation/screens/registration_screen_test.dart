import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/presentation/screens/registration_screen.dart';

import '../../../../helpers/pump_app.dart';

class MockUserController extends Notifier<UserState>
    with Mock
    implements UserController {
  @override
  UserState build() => const UserState(
        userEntity: UserEntity(
            id: 'u1',
            email: 'ama@example.com',
            registrationStatus: RegistrationStatus.dob),
      );
}

void main() {
  testWidgets('Android back on step 2 returns to step 1, not out of the app',
      (tester) async {
    await tester.pumpApp(
      const RegistrationScreen(),
      overrides: [userControllerProvider.overrideWith(MockUserController.new)],
    );
    await tester.pumpAndSettle();
    expect(find.text('When were you born?'), findsOneWidget);
    expect(find.text('2 of 4'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue, reason: 'the screen kept the back press');
    expect(find.text("Let's get to know you"), findsOneWidget);
    expect(find.text('1 of 4'), findsOneWidget);
  });
}
