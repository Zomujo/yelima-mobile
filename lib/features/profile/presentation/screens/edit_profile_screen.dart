import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../controllers/edit_profile_controller.dart';
import '../widgets/edit_profile/edit_profile_avatar.dart';
import '../widgets/edit_profile/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditProfileController>(
      create: _initializeController,
      child: const _EditProfileView(),
    );
  }

  EditProfileController _initializeController(BuildContext context) {
    final user = context.read<UserController>().userEntity;
    return sl<EditProfileController>()..init(user);
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppHeader(
        title: 'Edit Profile',
        onBackPressed: () => context.pop(),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditProfileAvatar(),
                    SizedBox(height: 48),
                    EditProfileForm(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Consumer<EditProfileController>(
                builder: (context, controller, child) {
                  return AppButton(
                    text: controller.state.isSaving ? 'Saving...' : 'Save Changes',
                    isDisabled: !controller.state.isButtonEnabled || controller.state.isSaving,
                    isLoading: controller.state.isSaving,
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final response = await controller.saveProfile();
                      
                      if (context.mounted) {
                        response.fold(
                          (failure) => AppSnackBar.showError(context, message: failure),
                          (_) {
                            AppSnackBar.showSuccess(context, message: 'Profile updated successfully');
                            context.pop();
                          },
                        );
                      }
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
