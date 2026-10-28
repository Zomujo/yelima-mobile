import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/reading_save_button.dart';

import '../../../helpers/pump_app.dart';

class MockRepo extends Mock implements VitalsRepository {}

void main() {
  late MockRepo repo;

  setUpAll(() => registerFallbackValue(ReadingForm(
      kind: VitalKind.bloodSugar,
      systolic: 0,
      diastolic: 0,
      sugarLevel: 0,
      recordedAt: DateTime(2026))));

  setUp(() {
    repo = MockRepo();
    when(() => repo.watchReadings()).thenAnswer((_) => Stream.value([]));
    when(() => repo.refresh()).thenAnswer((_) async => right(null));
  });

  /// Saves a sugar reading that the repository grades [grade].
  Future<void> saveGraded(WidgetTester tester, VitalSeverity grade) async {
    when(() => repo.saveReading(any())).thenAnswer((_) async => right(grade));
    final controller = ReadingLoggingController(repository: repo)
      ..init()
      ..setKind(VitalKind.bloodSugar)
      ..setSugarLevel(1.0);
    await tester.pumpApp(
      const ReadingSaveButton(),
      providers: [ChangeNotifierProvider.value(value: controller)],
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('a critically low sugar shows what to do at once',
      (tester) async {
    await saveGraded(tester, VitalSeverity.criticallyLow);

    expect(find.text('Critically Low Blood Sugar'), findsOneWidget);
    expect(find.text('Reading saved successfully'), findsNothing);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('Critically Low Blood Sugar'), findsNothing);
  });

  testWidgets('a normal reading just says it was saved', (tester) async {
    await saveGraded(tester, VitalSeverity.normal);

    expect(find.text('Reading saved successfully'), findsOneWidget);
    expect(find.text('Got it'), findsNothing);
  });
}
