import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/shared/widgets/loaders/global_async_loader.dart';

import '../../helpers/pump_app.dart';

void main() {
  tearDown(GlobalAsyncLoader.hide);

  testWidgets('shows over the app and hides', (tester) async {
    await tester.pumpApp(Builder(
      builder: (context) => TextButton(
        onPressed: () => GlobalAsyncLoader.show(context, message: 'Wait'),
        child: const Text('go'),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('Wait'), findsOneWidget);

    GlobalAsyncLoader.hide();
    await tester.pump();
    expect(find.text('Wait'), findsNothing);
  });

  testWidgets('works from the root navigator\'s own context, as logout uses it',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const SizedBox()));

    GlobalAsyncLoader.show(navigator.currentContext!, message: 'Wait');
    await tester.pump();
    expect(find.text('Wait'), findsOneWidget);

    GlobalAsyncLoader.hide();
    await tester.pump();
    expect(find.text('Wait'), findsNothing);
  });

  testWidgets('hiding after the app was torn down does not throw',
      (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
        MaterialApp(navigatorKey: navigator, home: const SizedBox()));
    GlobalAsyncLoader.show(navigator.currentContext!, message: 'Wait');
    await tester.pumpWidget(const SizedBox());

    GlobalAsyncLoader.hide();
    expect(tester.takeException(), isNull);
  });
}
