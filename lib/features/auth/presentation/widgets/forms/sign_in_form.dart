import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/router/route_paths.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_button.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    super.key,
    this.isAuthLoading = false,
  });

  final bool isAuthLoading;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    // Strict validation: must be valid email format and password length >= 6
    final isValid = Validators.isValidEmail(email) && Validators.isValidPassword(password);
    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 24),
        AppFormField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'At least 6 characters',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: Validators.passwordValidator,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(RoutePaths.forgotPassword),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        AppButton(
          text: 'Sign In',
          isDisabled: !_isButtonEnabled || widget.isAuthLoading,
          onPressed: (_isButtonEnabled && !widget.isAuthLoading)
              ? () {
                  FocusScope.of(context).unfocus();
                  context.read<AuthController>().signIn(
                    context,
                    _emailController.text.trim(),
                    _passwordController.text,
                  );
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
