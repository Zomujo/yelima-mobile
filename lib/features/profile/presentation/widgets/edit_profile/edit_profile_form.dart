import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_dropdown.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../user/presentation/controllers/user_controller.dart';
import '../../controllers/edit_profile_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final controller = context.read<EditProfileController>();
    final user = context.read<UserController>().userEntity;

    _firstNameController =
        TextEditingController(text: controller.state.firstName);
    _lastNameController =
        TextEditingController(text: controller.state.lastName);
    _emailController = TextEditingController(text: user?.email ?? '');

    _firstNameController.addListener(() {
      context
          .read<EditProfileController>()
          .updateForm(firstName: _firstNameController.text);
    });

    _lastNameController.addListener(() {
      context
          .read<EditProfileController>()
          .updateForm(lastName: _lastNameController.text);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          label: context.l10n.firstName,
          hintText: context.l10n.enterFirstName,
          controller: _firstNameController,
        ),
        const SizedBox(height: 24),
        AppFormField(
          label: context.l10n.lastName,
          hintText: context.l10n.enterLastName,
          controller: _lastNameController,
        ),
        const SizedBox(height: 24),
        AppText.labelLarge(
          context.l10n.gender,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6A7282), // Slate 700
        ),
        const SizedBox(height: 8),
        Selector<EditProfileController, String?>(
          selector: (context, controller) => controller.state.gender,
          builder: (context, gender, child) {
            return AppDropdown<String>(
              value: gender,
              hintText: context.l10n.selectGender,
              items: [
                context.l10n.male,
                context.l10n.female,
                context.l10n.otherGender
              ],
              itemLabelBuilder: (item) => item,
              onChanged: (value) {
                context.read<EditProfileController>().updateForm(gender: value);
              },
            );
          },
        ),
        const SizedBox(height: 24),
        AppFormField(
          label: context.l10n.emailAddress,
          hintText: context.l10n.enterEmail,
          controller: _emailController,
          enabled: false,
          keyboardType: TextInputType.emailAddress,
          helperText: context.l10n.emailCannotBeChanged,
        ),
      ],
    );
  }
}
