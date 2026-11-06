import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_state.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/presentation/screens/profile_unavailable_screen.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';

import '../../../../helpers/pump_app.dart';

class MockUserController extends Notifier<UserState>
    with Mock
    implements UserController {
  @override
  UserState build() => const UserState(profileUnavailable: true);
}

class MockAuthController extends Notifier<AuthState>
    with Mock
    implements AuthController {
  @override
  AuthState build() => const AuthState();
}

void main() {
  late MockUserController users;
  late MockAuthController auth;

  setUp(() {
    users = MockUserController();
    auth = MockAuthController();
    when(() => users.retryProfile()).thenAnswer((_) async {});
    when(() => auth.syncBeforeLogout())
        .thenAnswer((_) async => (waiting: 0, failed: 0));
    when(() => auth.signOut()).thenAnswer((_) async => true);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpApp(
      const ProfileUnavailableScreen(),
      overrides: [
        userControllerProvider.overrideWith(() => users),
        authControllerProvider.overrideWith(() => auth),
      ],
    );
    await tester.pumpAndSettle(); // let the entrance finish
  }

  testWidgets('explains the problem and retries the profile', (tester) async {
    await pumpScreen(tester);

    expect(find.text("We couldn't load your profile"), findsOneWidget);
    await tester.tap(find.text('Try again'));

    verify(() => users.retryProfile()).called(1);
  });

  testWidgets('offers logging out instead', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    verify(() => auth.signOut()).called(1);
  });
}
