import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/auth/presentation/widgets/email_auth_form.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Future<bool> buttonEnabled(WidgetTester tester,
      {required bool isSignUp, required String password}) async {
    await tester.pumpApp(EmailAuthForm(isSignUp: isSignUp, isLoading: false));
    await tester.enterText(find.byType(TextFormField).first, 'ama@clinic.gh');
    await tester.enterText(find.byType(TextFormField).last, password);
    await tester.pump();
    return tester.widget<AppButton>(find.byType(AppButton)).onPressed != null;
  }

  testWidgets('sign-up needs a password of 6 characters', (tester) async {
    expect(await buttonEnabled(tester, isSignUp: true, password: '12345'),
        isFalse);
    expect(find.text('At least 6 characters'), findsWidgets);
    expect(await buttonEnabled(tester, isSignUp: true, password: '123456'),
        isTrue);
  });

  testWidgets('sign-in only needs the password filled in', (tester) async {
    expect(
        await buttonEnabled(tester, isSignUp: false, password: '1234'), isTrue);
  });

  testWidgets('sign-in shows asterisks where the password goes',
      (tester) async {
    await tester
        .pumpApp(const EmailAuthForm(isSignUp: false, isLoading: false));

    expect(find.text('********'), findsOneWidget);
  });
}
