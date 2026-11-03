import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/user/domain/models/facility_model.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/features/user/presentation/widgets/registration/registration_step_four.dart';

import '../../../../helpers/pump_app.dart';

class MockUserController extends Mock implements UserController {}

void main() {
  late MockUserController users;

  setUp(() => users = MockUserController());

  Future<void> search(WidgetTester tester,
      Either<AppFailure, List<FacilityModel>> answer) async {
    when(() => users.searchFacilities(any())).thenAnswer((_) async => answer);
    await tester.pumpApp(
      RegistrationStepFour(onBack: () {}, onContinue: () {}),
      providers: [ChangeNotifierProvider<UserController>.value(value: users)],
    );
    await tester.enterText(find.byType(TextFormField), 'Korle');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  testWidgets('offline, the search says so instead of "no facilities"',
      (tester) async {
    await search(tester, left(const NetworkFailure()));

    expect(find.text("You're offline. Check your connection and try again."),
        findsOneWidget);
    expect(find.text('No facilities found.'), findsNothing);
  });

  testWidgets('a search with no match says no facilities', (tester) async {
    await search(tester, right(const []));

    expect(find.text('No facilities found.'), findsOneWidget);
  });
}
