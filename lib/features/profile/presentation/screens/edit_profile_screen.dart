import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/utils/run_with_loader.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import '../widgets/edit_profile/edit_profile_form.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Edits the name and gender.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditProfileController>(
      create: (context) {
        final users = context.read<UserController>();
        return EditProfileController(userController: users)
          ..init(users.userEntity);
      },
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppHeader(
        title: context.l10n.editProfile,
        onBackPressed: () => context.pop(),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: UserAvatar(
                            user: context.watch<UserController>().userEntity)),
                    const SizedBox(height: 48),
                    const EditProfileForm(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Consumer<EditProfileController>(
                builder: (context, controller, child) {
                  return AppButton(
                    text: context.l10n.saveChanges,
                    isDisabled: !controller.state.isButtonEnabled,
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final saved = await runWithLoader(context,
                          message: context.l10n.savingChanges,
                          successMessage:
                              context.l10n.profileUpdatedSuccessfully,
                          action: controller.saveProfile);
                      if (saved && context.mounted) context.pop();
                    },
                    width: double.infinity,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
