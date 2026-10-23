import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/shared/widgets/layout/pending_changes_badge.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late StreamController<int> waiting;
  late StreamController<int> failed;

  setUp(() {
    waiting = StreamController<int>();
    failed = StreamController<int>();
  });

  tearDown(() async {
    await waiting.close();
    await failed.close();
  });

  /// Delivers stream events, then rebuilds.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  Future<void> pumpBadge(WidgetTester tester, {VoidCallback? onTap}) =>
      tester.pumpApp(PendingChangesBadge(
          waiting: waiting.stream, failed: failed.stream, onTap: onTap));

  testWidgets('shows nothing when everything is synced', (tester) async {
    await pumpBadge(tester);
    waiting.add(0);
    failed.add(0);
    await settle(tester);

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('one summary for waiting changes, with plurals', (tester) async {
    await pumpBadge(tester);

    waiting.add(1);
    await settle(tester);
    expect(find.text('1 change waiting to sync'), findsOneWidget);

    waiting.add(3);
    await settle(tester);
    expect(find.text('3 changes waiting to sync'), findsOneWidget);
  });

  testWidgets('failed changes take priority and can be tapped', (tester) async {
    var tapped = false;
    await pumpBadge(tester, onTap: () => tapped = true);

    waiting.add(4);
    failed.add(2);
    await settle(tester);

    expect(find.text("2 changes couldn't sync"), findsOneWidget);
    expect(find.textContaining('waiting'), findsNothing);
    await tester.tap(find.text("2 changes couldn't sync"));
    expect(tapped, isTrue);
  });

  testWidgets('disappears once the queue empties', (tester) async {
    await pumpBadge(tester);
    waiting.add(2);
    await settle(tester);

    waiting.add(0);
    await settle(tester);

    expect(find.textContaining('waiting'), findsNothing);
  });
}
