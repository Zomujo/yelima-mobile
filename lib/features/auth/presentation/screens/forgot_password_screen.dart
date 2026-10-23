import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_layout.dart';
import '../widgets/forms/forgot_password_form.dart';
import '../../../../core/router/route_paths.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: context.l10n.resetPassword,
      subtitle: context.l10n.resetPasswordSubtitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const ForgotPasswordForm(),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => context.go(RoutePaths.signIn),
                child: Text(
                  context.l10n.backToSignIn,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
