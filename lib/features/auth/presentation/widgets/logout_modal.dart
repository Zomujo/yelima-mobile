import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/modals/app_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../core/router/router.dart';
import 'logout_flow.dart';

/// Asks the user to confirm logging out.
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
                  backgroundColor: AppColors.slate100,
                  foregroundColor: AppColors.slate600,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: context.l10n.logOut,
                  backgroundColor: AppColors.red500,
                  onPressed: () {
                    final host = rootNavigatorKey.currentContext ?? context;
                    Navigator.of(context).pop();
                    logOutWithSyncCheck(host);
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
