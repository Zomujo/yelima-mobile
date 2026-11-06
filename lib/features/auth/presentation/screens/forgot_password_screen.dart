import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/run_with_loader.dart';
import '../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/motion/entrance.dart';
import '../../auth_providers.dart';
import '../widgets/auth_layout.dart';

/// Sends a password reset link to an email address.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(() {
      final valid = Validators.isValidEmail(_email.text.trim());
      if (valid != _isValid) setState(() => _isValid = valid);
    });
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    final auth = ref.read(authControllerProvider.notifier);
    final sent = await runWithLoader(context,
        message: context.l10n.sendingResetLink,
        successMessage: context.l10n.resetLinkSent,
        action: () => auth.sendPasswordResetEmail(_email.text.trim()));
    if (sent && mounted) context.pop();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthLayout(
      title: l10n.resetPassword,
      subtitle: l10n.resetPasswordSubtitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 24,
          children: Entrance.staggered(startAt: AuthLayout.firstItem, [
            AppFormField(
              controller: _email,
              label: l10n.emailLabel,
              hintText: l10n.emailHint,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => Validators.email(v, l10n),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppButton(
                text: l10n.sendResetLink,
                isDisabled: !_isValid,
                onPressed: _isValid ? _send : null,
                width: double.infinity,
                height: 56,
                backgroundColor: AppColors.primary,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RoutePaths.signIn),
              child: Text(l10n.backToSignIn,
                  style: const TextStyle(
                      color: AppColors.slate500, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
      ),
    );
  }
}
