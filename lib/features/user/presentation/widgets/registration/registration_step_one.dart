import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/shared/utils/run_with_loader.dart';

import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/step_layout.dart';
import 'package:yelima/shared/widgets/forms/app_form_field.dart';
import 'package:yelima/shared/widgets/forms/app_dropdown.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Registration step 1: name, phone and gender.
class RegistrationStepOne extends StatefulWidget {
  const RegistrationStepOne({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  State<RegistrationStepOne> createState() => _RegistrationStepOneState();
}

class _RegistrationStepOneState extends State<RegistrationStepOne> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();

    final user = context.read<UserController>().userEntity;
    if (user != null) {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      String phone = user.phoneNumber ?? '';
      if (phone.startsWith('+233')) {
        phone = phone.substring(4);
      }
      _phoneController.text = phone;
      if (user.gender != null && user.gender!.isNotEmpty) {
        _selectedGender = user.gender;
      }
    }

    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _selectedGender != null;
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    final users = context.read<UserController>();
    final saved = await runWithLoader(context,
        message: context.l10n.savingDetails,
        action: () => users.updateBasicInfo(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              gender: _selectedGender!,
              phoneNumber: _ghanaPhone(_phoneController.text.trim()),
            ));
    if (saved && mounted) widget.onContinue();
  }

  /// Adds the +233 prefix the backend expects, dropping a leading 0.
  static String _ghanaPhone(String digits) => digits.startsWith('+233')
      ? digits
      : '+233${digits.startsWith('0') ? digits.substring(1) : digits}';

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: context.l10n.letsGetToKnowYou,
      subtitle: context.l10n.provideBasicInfo,
      isContinueEnabled: _isFormValid,
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            controller: _firstNameController,
            label: context.l10n.firstName,
            hintText: context.l10n.firstNameHint,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          AppFormField(
            controller: _lastNameController,
            label: context.l10n.lastName,
            hintText: context.l10n.lastNameHint,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          AppFormField(
            controller: _phoneController,
            label: context.l10n.phoneNumber,
            hintText: context.l10n.enterPhoneNumber,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            prefixWidget: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🇬🇭',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+233',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.slate800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.slate200,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppText.labelMedium(
            context.l10n.genderLabel,
            fontWeight: FontWeight.w500,
            color: AppColors.slate500,
          ),
          const SizedBox(height: 8),
          AppDropdown<String>(
            value: _selectedGender,
            hintText: context.l10n.selectGender,
            items: const ['Male', 'Female'],
            itemLabelBuilder: (gender) {
              if (gender == 'Male') return context.l10n.male;
              if (gender == 'Female') return context.l10n.female;
              return gender;
            },
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
