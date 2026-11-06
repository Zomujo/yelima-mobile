import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_dropdown.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/motion/entrance.dart';
import '../../../../user/user_providers.dart';
import '../../controllers/edit_profile_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/utils/names.dart';

/// Name and gender fields of the edit-profile screen.
class EditProfileForm extends ConsumerStatefulWidget {
  const EditProfileForm({super.key});

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(editProfileControllerProvider);
    final user = ref.read(userControllerProvider).userEntity;

    _firstNameController = TextEditingController(text: form.firstName);
    _lastNameController = TextEditingController(text: form.lastName);
    _emailController = TextEditingController(text: user?.email ?? '');

    _firstNameController.addListener(
        () => _form.updateForm(firstName: _firstNameController.text));
    _lastNameController.addListener(
        () => _form.updateForm(lastName: _lastNameController.text));
  }

  EditProfileController get _form =>
      ref.read(editProfileControllerProvider.notifier);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Says why Save is off when a name is cleared.
  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? context.l10n.requiredField : null;

  @override
  Widget build(BuildContext context) {
    final gender =
        ref.watch(editProfileControllerProvider.select((s) => s.gender));
    // Starts after the screen's avatar, which is item 0.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: Entrance.staggered(startAt: 1, [
        AppFormField(
          label: context.l10n.firstName,
          hintText: context.l10n.enterFirstName,
          controller: _firstNameController,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [NameInputFormatter()],
          validator: _required,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        AppFormField(
          label: context.l10n.lastName,
          hintText: context.l10n.enterLastName,
          controller: _lastNameController,
          textCapitalization: TextCapitalization.words,
          inputFormatters: const [NameInputFormatter()],
          validator: _required,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            AppText.labelLarge(
              context.l10n.gender,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6A7282),
            ),
            AppDropdown<String>(
              value: gender,
              hintText: context.l10n.selectGender,
              // Stored in English like registration; only the label is translated.
              items: const ['Male', 'Female', 'Other'],
              itemLabelBuilder: context.l10n.genderName,
              onChanged: (value) => _form.updateForm(gender: value),
            ),
          ],
        ),
        AppFormField(
          label: context.l10n.emailAddress,
          hintText: context.l10n.enterEmail,
          controller: _emailController,
          enabled: false,
          keyboardType: TextInputType.emailAddress,
          helperText: context.l10n.emailCannotBeChanged,
        ),
      ]),
    );
  }
}
