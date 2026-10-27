import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/core/router/route_paths.dart';
import 'package:yelima/shared/widgets/layout/back_to_home.dart';

void main() {
  late GoRouter router;

  Future<void> pumpRouter(WidgetTester tester) async {
    router = GoRouter(initialLocation: RoutePaths.home, routes: [
      GoRoute(path: RoutePaths.home, builder: (_, __) => const Text('home')),
      GoRoute(
        path: RoutePaths.medications,
        builder: (_, __) => const BackToHome(child: Text('meds')),
      ),
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  }

  testWidgets('back goes home when the screen was opened on its own',
      (tester) async {
    await pumpRouter(tester);
    router.go(RoutePaths.medications); // as a notification tap does
    await tester.pumpAndSettle();

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue, reason: 'the app must not close');
    expect(find.text('home'), findsOneWidget);
    expect(find.text('meds'), findsNothing);
  });

  testWidgets('back pops normally when opened from home', (tester) async {
    await pumpRouter(tester);
    router.push(RoutePaths.medications);
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });
}
