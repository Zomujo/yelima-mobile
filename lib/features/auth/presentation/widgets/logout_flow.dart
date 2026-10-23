import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/router/router.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/loaders/global_async_loader.dart';
import '../../../../shared/widgets/modals/app_modal.dart';
import '../controllers/auth_controller.dart';
import 'package:yelima/shared/utils/app_snackbar.dart';

/// What the user picked in the "changes not sent" warning.
enum UnsyncedChoice { tryAgain, logOutAnyway, cancel }

/// Logs out after trying to send queued changes, warning first if any would be lost.
Future<void> logOutWithSyncCheck(BuildContext context) async {
  final auth = context.read<AuthController>();
  final l10n = context.l10n;
  // The caller (often a modal) may be gone by the time sync finishes.
  BuildContext host() => rootNavigatorKey.currentContext ?? context;

  while (true) {
    GlobalAsyncLoader.show(host(), message: l10n.sendingChanges);
    final unsynced = await auth.syncBeforeLogout();
    GlobalAsyncLoader.hide();
    if (unsynced.waiting + unsynced.failed == 0) break;

    final choice = await UnsyncedChangesDialog.show(host(),
        waiting: unsynced.waiting, failed: unsynced.failed);
    if (choice == UnsyncedChoice.logOutAnyway) break;
    if (choice != UnsyncedChoice.tryAgain) return;
  }
  GlobalAsyncLoader.show(host(), message: l10n.signingOut);
  final signedOut = await auth.signOut();
  GlobalAsyncLoader.hide();
  if (signedOut) {
    AppSnackBar.showSuccess(null, message: l10n.signedOut);
  } else {
    AppSnackBar.showError(null, message: l10n.logoutFailed);
  }
}

/// Warns that a logout would lose [waiting] + [failed] unsynced changes.
class UnsyncedChangesDialog extends StatelessWidget {
  const UnsyncedChangesDialog(
      {super.key, required this.waiting, required this.failed});

  final int waiting;
  final int failed;

  static Future<UnsyncedChoice> show(BuildContext context,
      {required int waiting, required int failed}) async {
    final choice = await showAppDialog<UnsyncedChoice>(
        context, UnsyncedChangesDialog(waiting: waiting, failed: failed),
        dismissValue: UnsyncedChoice.cancel);
    return choice ?? UnsyncedChoice.cancel;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void pick(UnsyncedChoice c) => Navigator.of(context).pop(c);
    return ModalContainer(
      title: l10n.unsyncedTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium(l10n.unsyncedBody(waiting + failed),
              color: Colors.black54),
          if (failed > 0) ...[
            const SizedBox(height: 8),
            AppText.bodyMedium(l10n.unsyncedRejected(failed),
                color: Colors.black54),
          ],
          const SizedBox(height: 28),
          AppButton(
            text: l10n.tryAgain,
            onPressed: () => pick(UnsyncedChoice.tryAgain),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: l10n.logOutAnyway,
            backgroundColor: AppColors.red500,
            onPressed: () => pick(UnsyncedChoice.logOutAnyway),
          ),
        ],
      ),
    );
  }
}
