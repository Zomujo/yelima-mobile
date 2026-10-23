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

  testWidgets('sign-up needs a password of 8 characters', (tester) async {
    expect(await buttonEnabled(tester, isSignUp: true, password: '1234567'),
        isFalse);
    expect(find.text('At least 8 characters'), findsWidgets);
    expect(await buttonEnabled(tester, isSignUp: true, password: '12345678'),
        isTrue);
  });

  testWidgets('sign-in still accepts an older 6-character password',
      (tester) async {
    expect(await buttonEnabled(tester, isSignUp: false, password: '123456'),
        isTrue);
  });
}
