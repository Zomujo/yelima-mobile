import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_dropdown.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../user/presentation/controllers/user_controller.dart';
import '../../controllers/edit_profile_controller.dart';

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

    _firstNameController = TextEditingController(text: controller.state.firstName);
    _lastNameController = TextEditingController(text: controller.state.lastName);
    _emailController = TextEditingController(text: user?.email ?? '');

    _firstNameController.addListener(() {
      context.read<EditProfileController>().updateForm(firstName: _firstNameController.text);
    });

    _lastNameController.addListener(() {
      context.read<EditProfileController>().updateForm(lastName: _lastNameController.text);
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
    final controller = context.watch<EditProfileController>();
    final gender = controller.state.gender;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFormField(
          label: 'First Name',
          hintText: 'Enter your first name',
          controller: _firstNameController,
        ),
        const SizedBox(height: 24),
        AppFormField(
          label: 'Last Name',
          hintText: 'Enter your last name',
          controller: _lastNameController,
        ),
        const SizedBox(height: 24),
        const AppText.labelLarge(
          'Gender',
          fontWeight: FontWeight.w400,
          color: Color(0xFF6A7282), // Slate 700
        ),
        const SizedBox(height: 8),
        AppDropdown<String>(
          value: gender,
          hintText: 'Select gender',
          items: const ['Male', 'Female', 'Other'],
          itemLabelBuilder: (item) => item,
          onChanged: (value) {
            context.read<EditProfileController>().updateForm(gender: value);
          },
        ),
        const SizedBox(height: 24),
        AppFormField(
          label: 'Email Address',
          hintText: 'Enter your email',
          controller: _emailController,
          enabled: false,
          keyboardType: TextInputType.emailAddress,
          helperText: 'Your email address cannot be changed.',
        ),
      ],
    );
  }
}
