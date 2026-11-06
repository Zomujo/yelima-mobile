import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/presentation/widgets/history/reading_history_section.dart';
import 'package:yelima/features/vitals/vitals_providers.dart';
import 'package:yelima/shared/widgets/motion/entrance.dart';

import '../../../helpers/pump_app.dart';

class MockRepo extends Mock implements VitalsRepository {}

void main() {
  late StreamController<List<VitalHistoryEntity>> rows;

  VitalHistoryEntity reading(String id, String value, int hour) =>
      VitalHistoryEntity(
          id: id,
          vitalType: 'bloodPressure',
          value: value,
          unit: 'mmHg',
          severity: 'normal',
          vitalName: '',
          recordedAt: DateTime(2026, 11, 2, hour));

  final old = reading('a', '120/80', 9);

  Future<void> open(WidgetTester tester) async {
    final repo = MockRepo();
    rows = StreamController();
    addTearDown(rows.close);
    when(() => repo.watchReadings()).thenAnswer((_) => rows.stream);
    when(() => repo.refresh()).thenAnswer((_) async => right(null));
    await tester.pumpApp(const ReadingHistorySection(),
        overrides: [vitalsRepositoryProvider.overrideWithValue(repo)]);
    rows.add([old]);
    await tester.pumpAndSettle();
  }

  Finder slidingIn(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate((w) => w is Entrance && w.rise < 0));

  testWidgets('a newly saved reading slides in at the top', (tester) async {
    await open(tester);

    rows.add([old, reading('b', '130/85', 10)]);
    await tester.pump(); // the stream's event
    await tester.pump(); // the frame it causes

    expect(slidingIn('130/85 mmHg'), findsOneWidget);
    expect(slidingIn('120/80 mmHg'), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets("the server's copy of a reading doesn't slide in again",
      (tester) async {
    await open(tester);

    rows.add([reading('server-a', '120/80', 9)]);
    await tester.pumpAndSettle();

    expect(slidingIn('120/80 mmHg'), findsNothing);
  });
}
