import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/utils/run_with_loader.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_layout.dart';
import '../widgets/email_auth_form.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/terms_and_privacy_text.dart';

/// Sign-in or sign-up: Google, then email and password.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = context.select((AuthController a) => a.isAuthLoading);
    return AuthLayout(
      title: isSignUp ? l10n.signUpTitle : l10n.signInTitle,
      subtitle: isSignUp ? l10n.signUpSubtitle : l10n.signInSubtitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SocialAuthButton(
              icon: AppImages.google,
              text: isSignUp ? l10n.signUpWithGoogle : l10n.signInWithGoogle,
              onPressed: isLoading
                  ? null
                  : () => runWithLoader(context,
                      message: l10n.continuingWithGoogle,
                      action: context.read<AuthController>().signInWithGoogle),
            ),
            const SizedBox(height: 32),
            const AuthDivider(),
            const SizedBox(height: 32),
            EmailAuthForm(isSignUp: isSignUp, isLoading: isLoading),
            const SizedBox(height: 32),
            AuthFooter(
              text: isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
              actionText: isSignUp ? l10n.signInTitle : l10n.createAccount,
              onActionTap: isLoading
                  ? null
                  : () => context
                      .go(isSignUp ? RoutePaths.signIn : RoutePaths.signUp),
            ),
            const SizedBox(height: 32),
            const TermsAndPrivacyText(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
