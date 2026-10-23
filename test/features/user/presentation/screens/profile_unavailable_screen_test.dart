import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/features/user/presentation/controllers/user_state.dart';
import 'package:yelima/features/user/presentation/screens/profile_unavailable_screen.dart';

import '../../../../helpers/pump_app.dart';

class MockUserController extends Mock implements UserController {}

class MockAuthController extends Mock implements AuthController {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockUserController users;
  late MockAuthController auth;

  setUpAll(() => registerFallbackValue(FakeBuildContext()));

  setUp(() {
    users = MockUserController();
    auth = MockAuthController();
    when(() => users.state)
        .thenReturn(const UserState(profileUnavailable: true));
    when(() => users.retryProfile()).thenAnswer((_) async {});
    when(() => auth.syncBeforeLogout())
        .thenAnswer((_) async => (waiting: 0, failed: 0));
    when(() => auth.signOut(any())).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester) => tester.pumpApp(
        const ProfileUnavailableScreen(),
        providers: [
          ChangeNotifierProvider<UserController>.value(value: users),
          ChangeNotifierProvider<AuthController>.value(value: auth),
        ],
      );

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

    verify(() => auth.signOut(any())).called(1);
  });
}
