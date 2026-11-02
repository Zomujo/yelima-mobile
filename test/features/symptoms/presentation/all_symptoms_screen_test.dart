import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/features/symptoms/domain/entities/symptom_entity.dart';
import 'package:yelima/features/symptoms/domain/repositories/symptoms_repository.dart';
import 'package:yelima/features/symptoms/presentation/controllers/symptoms_controller.dart';
import 'package:yelima/features/symptoms/presentation/screens/all_symptoms_screen.dart';
import 'package:yelima/shared/widgets/layout/app_shimmer.dart';

import '../../../helpers/pump_app.dart';

class MockRepo extends Mock implements SymptomsRepository {}

void main() {
  late MockRepo repo;
  late Completer<Either<AppFailure, void>> server;

  setUp(() => repo = MockRepo());

  /// Opens the screen with [onPhone] saved and the server not yet answering.
  Future<void> open(WidgetTester tester, List<SymptomEntity> onPhone) async {
    server = Completer(); // made inside the test so pump() completes it
    when(() => repo.refresh(force: any(named: 'force')))
        .thenAnswer((_) => server.future);
    when(() => repo.watchSymptoms()).thenAnswer((_) => Stream.value(onPhone));
    await tester.pumpApp(const AllSymptomsScreen(), providers: [
      ChangeNotifierProvider(
          create: (_) => SymptomsController(repository: repo)),
    ]);
    await tester.pump();
  }

  testWidgets('shimmers, not "no symptoms", while the server is asked',
      (tester) async {
    await open(tester, const []);

    expect(find.byType(AppShimmer), findsWidgets);
    expect(find.text('No symptoms reported yet.'), findsNothing);

    server.complete(right(null));
    await tester.pumpAndSettle();

    expect(find.byType(AppShimmer), findsNothing);
    expect(find.text('No symptoms reported yet.'), findsOneWidget);
  });

  testWidgets('symptoms on the phone show at once', (tester) async {
    await open(tester, [
      SymptomEntity(
          id: 'a',
          description: 'Headache',
          onsetDate: DateTime(2026, 11, 1, 9)),
    ]);

    expect(find.text('Headache'), findsOneWidget);
    expect(find.byType(AppShimmer), findsNothing);
    server.complete(right(null));
  });
}
