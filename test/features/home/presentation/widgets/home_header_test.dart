import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/home/presentation/widgets/home_header.dart';
import 'package:yelima/shared/widgets/layout/pending_changes_badge.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows date and greeting', (tester) async {
    await tester.pumpApp(
        const HomeHeader(date: 'Friday, 23 October', greeting: 'Welcome, Ama'));

    expect(find.text('Friday, 23 October'), findsOneWidget);
    expect(find.text('Welcome, Ama'), findsOneWidget);
  });

  testWidgets('shows the unsynced-changes badge under the greeting',
      (tester) async {
    final waiting = StreamController<int>();
    addTearDown(waiting.close);

    await tester.pumpApp(HomeHeader(
      date: 'Friday, 23 October',
      greeting: 'Welcome, Ama',
      status: PendingChangesBadge(
          waiting: waiting.stream, failed: const Stream.empty()),
    ));
    waiting.add(2);
    await tester.pump();
    await tester.pump();

    expect(find.text('2 changes waiting to sync'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('2 changes waiting to sync')).dy,
      greaterThan(tester.getTopLeft(find.text('Welcome, Ama')).dy),
    );
  });
}
