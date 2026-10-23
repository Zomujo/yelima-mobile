import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/shared/widgets/forms/app_form_field.dart';
import 'package:yelima/shared/widgets/modals/discard_changes_modal.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('a password field hides its text until shown', (tester) async {
    await tester
        .pumpApp(const AppFormField(label: 'Password', isPassword: true));
    EditableText field() => tester.widget(find.byType(EditableText));

    expect(field().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  testWidgets('the discard dialog answers which button was tapped',
      (tester) async {
    bool? answer;
    await tester.pumpApp(Builder(
      builder: (context) => TextButton(
        onPressed: () async => answer = await DiscardChangesModal.show(context),
        child: const Text('open'),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(answer, isTrue);
    expect(find.text('Discard'), findsNothing, reason: 'the dialog closed');
  });
}
