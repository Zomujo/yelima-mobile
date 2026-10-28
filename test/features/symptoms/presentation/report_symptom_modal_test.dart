import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/symptoms/presentation/widgets/report_symptom_modal.dart';

import '../../../helpers/pump_app.dart';

void main() {
  /// Opens the modal from a button, as the symptoms screen does.
  Future<void> open(WidgetTester tester) async {
    await tester.pumpApp(Builder(
      builder: (context) => TextButton(
        onPressed: () => ReportSymptomModal.show(context),
        child: const Text('open'),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  }

  testWidgets('shows how much of the 1000 characters is used', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextFormField), 'Headache');
    await tester.pump();

    expect(find.text('8/1000'), findsOneWidget);
  });

  testWidgets('closes at once when nothing was written', (tester) async {
    await open(tester);
    await close(tester);

    expect(find.byType(ReportSymptomModal), findsNothing);
  });

  testWidgets('asks before dropping a written note', (tester) async {
    await open(tester);
    await tester.enterText(
        find.byType(TextFormField), 'Headache since morning');
    await close(tester);

    expect(find.text('Keep Editing'), findsOneWidget);
    await tester.tap(find.text('Keep Editing'));
    await tester.pumpAndSettle();
    expect(find.text('Headache since morning'), findsOneWidget);

    await close(tester);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportSymptomModal), findsNothing);
  });
}
