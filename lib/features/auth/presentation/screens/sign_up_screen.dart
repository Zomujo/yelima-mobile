import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:yelima/features/auth/presentation/widgets/auth_layout.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/router/route_paths.dart';
import '../widgets/auth_footer.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/forms/sign_up_form.dart';
import '../widgets/terms_and_privacy_text.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create your account',
      subtitle: 'Join Yelima to support your patients.',
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          final isLoading = authController.isAuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                SocialAuthButton(
                  icon: AppImages.google,
                  text: 'Sign up with Google',
                  onPressed: isLoading
                      ? null
                      : () => authController.signInWithGoogle(context),
                ),
                const SizedBox(height: 16),
                const AuthDivider(),
                const SizedBox(height: 32),
                SignUpForm(isAuthLoading: isLoading),
                const SizedBox(height: 32),
                AuthFooter(
                  text: 'Already have an account? ',
                  actionText: 'Sign in',
                  onActionTap:
                      isLoading ? null : () => context.go(RoutePaths.signIn),
                ),
                const SizedBox(height: 32),
                const TermsAndPrivacyText(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
