import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/utils/run_with_loader.dart';
import '../../../user/user_providers.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../widgets/edit_profile/edit_profile_form.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Edits the name and gender.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppHeader(
        title: context.l10n.editProfile,
        onBackPressed: () => context.pop(),
        backgroundColor: Colors.transparent,
      ),
      // The button scrolls with the form, so the keyboard never hides a field behind it.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: UserAvatar(
                      user: ref.watch(userControllerProvider).userEntity)),
              const SizedBox(height: 48),
              const EditProfileForm(),
              const SizedBox(height: 32),
              const _SaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Saves the form, then goes back.
class _SaveButton extends ConsumerWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref
        .watch(editProfileControllerProvider.select((s) => s.isButtonEnabled));
    return AppButton(
      text: context.l10n.saveChanges,
      isDisabled: !enabled,
      onPressed: () async {
        FocusScope.of(context).unfocus();
        final saved = await runWithLoader(context,
            message: context.l10n.savingChanges,
            successMessage: context.l10n.profileUpdatedSuccessfully,
            action:
                ref.read(editProfileControllerProvider.notifier).saveProfile);
        if (saved && context.mounted) context.pop();
      },
      width: double.infinity,
    );
  }
}
