import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/utils/run_with_loader.dart';
import '../../../../shared/widgets/motion/entrance.dart';
import '../../auth_providers.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_layout.dart';
import '../widgets/email_auth_form.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/terms_and_privacy_text.dart';

/// Sign-in or sign-up: Google, then email and password.
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key, required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isLoading =
        ref.watch(authControllerProvider.select((s) => s.isAuthLoading));
    return AuthLayout(
      title: isSignUp ? l10n.signUpTitle : l10n.signInTitle,
      subtitle: isSignUp ? l10n.signUpSubtitle : l10n.signInSubtitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          spacing: 32,
          children: Entrance.staggered(startAt: AuthLayout.firstItem, [
            SocialAuthButton(
              icon: AppImages.google,
              text: isSignUp ? l10n.signUpWithGoogle : l10n.signInWithGoogle,
              onPressed: isLoading
                  ? null
                  : () => runWithLoader(context,
                      message: l10n.continuingWithGoogle,
                      action: ref
                          .read(authControllerProvider.notifier)
                          .signInWithGoogle),
            ),
            const AuthDivider(),
            EmailAuthForm(isSignUp: isSignUp, isLoading: isLoading),
            AuthFooter(
              text: isSignUp ? l10n.alreadyHaveAccount : l10n.dontHaveAccount,
              actionText: isSignUp ? l10n.signInTitle : l10n.createAccount,
              onActionTap: isLoading
                  ? null
                  : () => context
                      .go(isSignUp ? RoutePaths.signIn : RoutePaths.signUp),
            ),
            const TermsAndPrivacyText(),
          ]),
        ),
      ),
    );
  }
}
