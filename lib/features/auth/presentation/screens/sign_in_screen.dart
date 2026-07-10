import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/constants/app_images.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_footer.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/forms/sign_in_form.dart';
import '../widgets/terms_and_privacy_text.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Sign In',
      subtitle: 'Sign in to Yelima to support your patients.',
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
                  text: 'Sign in with Google',
                  onPressed: isLoading
                      ? null
                      : () => authController.signInWithGoogle(context),
                ),
                const SizedBox(height: 16),
                // SocialAuthButton(
                //   icon: AppImages.apple,
                //   text: 'Sign in with Apple',
                //   onPressed: () {},
                // ),
                const SizedBox(height: 16),
                const AuthDivider(),
                const SizedBox(height: 32),
                SignInForm(isAuthLoading: isLoading),
                const SizedBox(height: 32),
                AuthFooter(
                  text: 'Don\'t have an account? ',
                  actionText: 'Create an account',
                  onActionTap: isLoading ? null : () => context.go(RoutePaths.signUp),
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
