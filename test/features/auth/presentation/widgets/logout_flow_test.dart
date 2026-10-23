import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yelima/features/auth/presentation/widgets/logout_flow.dart';

import '../../../../helpers/pump_app.dart';

class MockAuthController extends Mock implements AuthController {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockAuthController auth;
  late List<({int waiting, int failed})> results;

  setUpAll(() => registerFallbackValue(FakeBuildContext()));

  setUp(() {
    auth = MockAuthController();
    when(() => auth.signOut(any())).thenAnswer((_) async {});
    when(() => auth.syncBeforeLogout())
        .thenAnswer((_) async => results.removeAt(0));
  });

  Future<void> startLogout(WidgetTester tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => logOutWithSyncCheck(context),
          child: const Text('start'),
        ),
      ),
      providers: [ChangeNotifierProvider<AuthController>.value(value: auth)],
    );
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
  }

  testWidgets('everything synced: logs out with no warning', (tester) async {
    results = [(waiting: 0, failed: 0)];

    await startLogout(tester);

    expect(find.text('Changes not sent'), findsNothing);
    verify(() => auth.signOut(any())).called(1);
  });

  testWidgets(
      'unsent changes: warns with the count, and the rejected ones separately',
      (tester) async {
    results = [(waiting: 2, failed: 1)];

    await startLogout(tester);

    expect(
        find.text(
            "3 changes haven't been sent yet. If you log out now, they will be lost."),
        findsOneWidget);
    expect(
        find.text(
            "1 of them was rejected by the server, so trying again won't send it."),
        findsOneWidget);
    verifyNever(() => auth.signOut(any()));
  });

  testWidgets('"Log out anyway" logs out', (tester) async {
    results = [(waiting: 1, failed: 0)];
    await startLogout(tester);

    await tester.tap(find.text('Log out anyway'));
    await tester.pumpAndSettle();

    verify(() => auth.signOut(any())).called(1);
  });

  testWidgets('"Try again" syncs again and logs out once nothing is left',
      (tester) async {
    results = [(waiting: 1, failed: 0), (waiting: 0, failed: 0)];
    await startLogout(tester);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    verify(() => auth.syncBeforeLogout()).called(2);
    verify(() => auth.signOut(any())).called(1);
  });
}
