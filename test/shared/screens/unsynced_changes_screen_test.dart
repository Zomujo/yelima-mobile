import 'package:clock/clock.dart';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/managers/mutation_sync_manager.dart';
import 'package:yelima/shared/screens/unsynced_changes_screen.dart';

import '../../helpers/pump_app.dart';

class MockSync extends Mock implements MutationSyncManager {}

void main() {
  late MockSync sync;
  late StreamController<List<PendingMutation>> failed;

  PendingMutation change(
          {required int retryCount,
          String entityType = 'symptom',
          String action = 'create'}) =>
      PendingMutation(
        id: 'mut-1',
        entityType: entityType,
        entityId: 's1',
        action: action,
        payloadJson: '{}',
        createdAt: DateTime(2026, 10, 23, 14, 30),
        retryCount: retryCount,
      );

  setUp(() {
    sync = MockSync();
    failed = StreamController<List<PendingMutation>>();
    when(() => sync.watchFailed()).thenAnswer((_) => failed.stream);
    when(() => sync.retryFailed(any())).thenAnswer((_) async {});
    when(() => sync.discardFailed(any())).thenAnswer((_) async {});
  });

  tearDown(() => failed.close());

  Future<void> show(WidgetTester tester, List<PendingMutation> items) async {
    await tester.pumpApp(UnsyncedChangesScreen(sync: sync));
    failed.add(items);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('says everything was sent when nothing failed', (tester) async {
    await show(tester, []);

    expect(find.text('Everything has been sent.'), findsOneWidget);
  });

  testWidgets('lists a rejected change with what it is and when',
      (tester) async {
    await show(tester, [change(retryCount: 9999)]);

    expect(find.text('Symptom · Fri 23 Oct • 14:30'), findsOneWidget);
    expect(find.text('The server rejected this change.'), findsOneWidget);
  });

  testWidgets('a dose over 2 days old says it is too late, with no Retry',
      (tester) async {
    await withClock(Clock.fixed(DateTime(2026, 10, 26, 15)), () async {
      await show(tester, [
        change(
            retryCount: 9999,
            entityType: 'medication',
            action: 'confirmMedication')
      ]);

      expect(
          find.text(
              'This dose is more than 2 days old, so it can no longer be logged.'),
          findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });

  testWidgets('tells apart a change that ran out of tries', (tester) async {
    await show(tester, [change(retryCount: 3)]);

    expect(find.text("This change couldn't be sent after several tries."),
        findsOneWidget);
  });

  testWidgets('Retry puts the change back in the queue', (tester) async {
    await show(tester, [change(retryCount: 3)]);

    await tester.tap(find.text('Retry'));

    verify(() => sync.retryFailed('mut-1')).called(1);
  });

  testWidgets('Discard asks first, and Cancel keeps the change',
      (tester) async {
    await show(tester, [change(retryCount: 9999)]);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this change?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => sync.discardFailed(any()));
  });

  testWidgets('confirming Discard deletes the change', (tester) async {
    await show(tester, [change(retryCount: 9999)]);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard').last);
    await tester.pumpAndSettle();

    verify(() => sync.discardFailed('mut-1')).called(1);
  });
}
