import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/run_with_loader.dart';
import '../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../controllers/auth_controller.dart';

/// Email and password fields that sign in or create an account.
class EmailAuthForm extends StatefulWidget {
  const EmailAuthForm(
      {super.key, required this.isSignUp, required this.isLoading});

  final bool isSignUp;
  final bool isLoading;

  @override
  State<EmailAuthForm> createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<EmailAuthForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(_validate);
    _password.addListener(_validate);
  }

  void _validate() {
    final valid = Validators.isValidEmail(_email.text.trim()) &&
        Validators.isValidPassword(_password.text);
    if (valid != _isValid) setState(() => _isValid = valid);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthController>();
    final email = _email.text.trim();
    runWithLoader(context,
        message: widget.isSignUp
            ? context.l10n.creatingAccount
            : context.l10n.signingIn,
        action: () => widget.isSignUp
            ? auth.register(email, _password.text)
            : auth.signIn(email, _password.text));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = _isValid && !widget.isLoading;
    return Column(
      children: [
        AppFormField(
          controller: _email,
          label: l10n.emailLabel,
          hintText: l10n.emailHint,
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: Validators.emailValidator,
        ),
        const SizedBox(height: 24),
        AppFormField(
          controller: _password,
          label: l10n.passwordLabel,
          hintText: l10n.passwordHint,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: Validators.passwordValidator,
        ),
        if (!widget.isSignUp)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(RoutePaths.forgotPassword),
              child: Text(l10n.forgotPassword,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ),
          ),
        const SizedBox(height: 32),
        AppButton(
          text: widget.isSignUp ? l10n.createAccount : l10n.signInTitle,
          isDisabled: !enabled,
          onPressed: enabled ? _submit : null,
          width: double.infinity,
          height: 56,
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }
}
