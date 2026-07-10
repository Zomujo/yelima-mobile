import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/forms/app_text_field.dart';
import '../../../../shared/widgets/modals/app_modal.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class DeleteAccountModal extends StatefulWidget {
  const DeleteAccountModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => OverlayModal(
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        onDismiss: () => Navigator.of(context).pop(),
        child: const DeleteAccountModal(),
      ),
    );
  }

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final _passwordController = TextEditingController();
  bool _isPasswordProvider = false;
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _isPasswordProvider =
        user?.providerData.any((p) => p.providerId == 'password') ?? false;

    if (_isPasswordProvider) {
      _isButtonEnabled = false;
      _passwordController.addListener(() {
        setState(() {
          _isButtonEnabled = _passwordController.text.isNotEmpty;
        });
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      title: 'Delete Account',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppText.titleMedium(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
            color: Colors.black54,
          ),
          if (_isPasswordProvider) ...[
            const SizedBox(height: 24),
            AppTextField(
              labelText: 'Password',
              hintText: 'Enter your password to confirm',
              controller: _passwordController,
              isPassword: true,
            ),
          ],
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                  foregroundColor: const Color(0xFF475569), // Slate 600
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'Delete',
                  backgroundColor: _isButtonEnabled
                      ? const Color(0xFFEF4444)
                      : Colors.grey, // Red 500
                  onPressed: _isButtonEnabled
                      ? () async {
                          final controller = context.read<AuthController>();
                          final nav = Navigator.of(context);

                          nav.pop(); // dismiss modal

                          await controller.deleteAccount(
                            context,
                            password: _isPasswordProvider
                                ? _passwordController.text
                                : null,
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
