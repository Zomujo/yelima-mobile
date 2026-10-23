import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yelima/features/auth/presentation/screens/session_expired_screen.dart';

import '../../../../helpers/pump_app.dart';

class MockAuthController extends Mock implements AuthController {}

void main() {
  late MockAuthController auth;

  setUpAll(() => registerFallbackValue(FakeBuildContext()));

  setUp(() {
    auth = MockAuthController();
    when(() => auth.signOut(any())).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester, {required bool password}) async {
    when(() => auth.reauthNeedsPassword).thenReturn(password);
    await tester.pumpApp(
      const SessionExpiredScreen(),
      providers: [ChangeNotifierProvider<AuthController>.value(value: auth)],
    );
  }

  testWidgets('an email user signs in again with their password',
      (tester) async {
    when(() => auth.reauthenticate(password: 'secret1'))
        .thenAnswer((_) async => null);
    await pumpScreen(tester, password: true);

    expect(find.text('Your session expired'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'secret1');
    await tester.tap(find.text('Sign in again'));
    await tester.pump();

    verify(() => auth.reauthenticate(password: 'secret1')).called(1);
    expect(find.textContaining("couldn't sign you in"), findsNothing);
  });

  testWidgets('a Google user gets no password field', (tester) async {
    when(() => auth.reauthenticate(password: '')).thenAnswer((_) async => null);
    await pumpScreen(tester, password: false);

    expect(find.byType(TextFormField), findsNothing);
    await tester.tap(find.text('Sign in again'));
    await tester.pump();

    verify(() => auth.reauthenticate(password: '')).called(1);
  });

  testWidgets('a failed sign-in shows a plain message and stays locked',
      (tester) async {
    when(() => auth.reauthenticate(password: any(named: 'password')))
        .thenAnswer((_) async => 'wrong-password');
    await pumpScreen(tester, password: true);

    await tester.tap(find.text('Sign in again'));
    await tester.pump();

    expect(
        find.text("We couldn't sign you in. Check your details and try again."),
        findsOneWidget);
  });

  testWidgets('log out goes through the normal logout flow', (tester) async {
    when(() => auth.syncBeforeLogout())
        .thenAnswer((_) async => (waiting: 0, failed: 0));
    await pumpScreen(tester, password: true);

    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    verify(() => auth.syncBeforeLogout()).called(1);
    verify(() => auth.signOut(any())).called(1);
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
