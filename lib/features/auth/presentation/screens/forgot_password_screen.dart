import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/auth_layout.dart';
import '../widgets/forms/forgot_password_form.dart';
import '../../../../core/router/route_paths.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Reset Password',
      subtitle:
          'Enter your email and we\'ll send you a link to reset your password.',
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
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(
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
