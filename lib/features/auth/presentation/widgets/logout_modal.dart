import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/modals/app_modal.dart';
import '../controllers/auth_controller.dart';

class LogoutModal extends StatelessWidget {
  const LogoutModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => OverlayModal(
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        onDismiss: () => Navigator.of(context).pop(),
        child: const LogoutModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      title: 'Log Out',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppText.titleMedium(
            'Are you sure you want to log out of your account?',
            color: Colors.black54,
          ),
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
                  text: 'Log Out',
                  backgroundColor: const Color(0xFFEF4444), // Red 500
                  onPressed: () {
                    final controller = context.read<AuthController>();
                    Navigator.of(context).pop(); // dismiss modal
                    controller.signOut(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
