import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_button.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final isValid = Validators.isValidEmail(email);
    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          controller: _emailController,
          label: 'Email',
          hintText: 'you@example.com',
          prefixIcon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: Validators.emailValidator,
        ),
        const SizedBox(height: 32),
        AppButton(
          text: 'Send Reset Link',
          isDisabled: !_isButtonEnabled,
          onPressed: _isButtonEnabled
              ? () async {
                  FocusScope.of(context).unfocus();
                  final success = await context
                      .read<AuthController>()
                      .sendPasswordResetEmail(
                        context,
                        _emailController.text.trim(),
                      );
                  if (success && context.mounted) {
                    context.pop();
                  }
                }
              : null,
          width: double.infinity,
          height: 56,
          backgroundColor: AppColors.primary,
        ),
      ],
    );
  }
}
