import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_two.dart';

import '../../../../helpers/pump_app.dart';

class MockUserController extends Mock implements UserController {}

void main() {
  late MockUserController users;
  var continued = false;

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    continued = false;
    users = MockUserController();
    when(() => users.userEntity).thenReturn(null);
    when(() => users.updateDob(any())).thenAnswer((_) async => right(null));
  });

  Future<void> enterAge(WidgetTester tester, String age) async {
    await tester.pumpApp(
      RegistrationStepTwo(onBack: () {}, onContinue: () => continued = true),
      providers: [ChangeNotifierProvider<UserController>.value(value: users)],
    );
    await tester.tap(find.text('Enter age instead'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), age);
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
  }

  testWidgets('an under-18 is told why and nothing is saved', (tester) async {
    await enterAge(tester, '15');

    expect(find.text('You must be at least 18 years old to register'),
        findsOneWidget);
    verifyNever(() => users.updateDob(any()));
    expect(continued, isFalse);
  });

  testWidgets('an adult\'s age is saved as a date of birth', (tester) async {
    await enterAge(tester, '40');
    await tester.pump();

    verify(() => users.updateDob(any())).called(1);
    expect(continued, isTrue);
  });
}
