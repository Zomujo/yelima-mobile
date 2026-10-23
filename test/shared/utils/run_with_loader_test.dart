import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/shared/utils/run_with_loader.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<bool> run(WidgetTester tester, Either<AppFailure, void> result) async {
    await tester.pumpApp(const SizedBox());
    final context = tester.element(find.byType(SizedBox));
    final ok = await runWithLoader<void>(context,
        message: 'Saving', action: () async => result);
    await tester.pump();
    return ok;
  }

  testWidgets('a failure shows its translated message', (tester) async {
    expect(await run(tester, left(const NetworkFailure())), isFalse);
    expect(find.text("You're offline. Check your connection and try again."),
        findsOneWidget);
  });

  testWidgets('a cancelled action shows nothing', (tester) async {
    expect(await run(tester, left(const CancelledFailure())), isFalse);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('success reports true', (tester) async {
    expect(await run(tester, right(null)), isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });
}
