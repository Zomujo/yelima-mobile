import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/modals/app_modal.dart';
import '../../../../core/router/route_paths.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
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
      title: context.l10n.logOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium(
            context.l10n.logOutConfirmation,
            color: Colors.black54,
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: context.l10n.cancel,
                  backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                  foregroundColor: const Color(0xFF475569), // Slate 600
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: context.l10n.logOut,
                  backgroundColor: const Color(0xFFEF4444), // Red 500
                  onPressed: () {
                    final controller = context.read<AuthController>();
                    Navigator.of(context).pop(); // dismiss modal
                    context.go(RoutePaths.signIn); // clear deep link intent
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
