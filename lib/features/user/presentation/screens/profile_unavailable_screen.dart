import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../auth/presentation/widgets/auth_layout.dart';
import '../../../auth/presentation/widgets/logout_flow.dart';
import '../controllers/user_controller.dart';

/// Shown when a signed-in user's profile couldn't be loaded: retry or log out, never registration.
class ProfileUnavailableScreen extends StatelessWidget {
  const ProfileUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = context.watch<UserController>();
    return AuthLayout(
      title: l10n.profileUnavailableTitle,
      subtitle: l10n.profileUnavailableBody,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              text: l10n.tryAgain,
              isLoading: user.state.isLoading,
              onPressed: user.retryProfile,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => logOutWithSyncCheck(context),
              child: Text(l10n.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
