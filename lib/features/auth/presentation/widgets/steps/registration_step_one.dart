import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../user/presentation/controllers/user_controller.dart';

import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/step_layout.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_dropdown.dart';
import '../../../../../core/extensions/l10n_extension.dart';

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
  bool _isSubmitting = false;

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

  void _handleContinue() async {
    if (!_isFormValid || _isSubmitting) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    String phone = _phoneController.text.trim();
    if (!phone.startsWith('+233')) {
      if (phone.startsWith('0')) {
        phone = '+233${phone.substring(1)}';
      } else {
        phone = '+233$phone';
      }
    }

    final response = await context.read<UserController>().updateBasicInfo(
          context,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          gender: _selectedGender!,
          phoneNumber: phone,
        );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (response.isRight()) {
        widget.onContinue();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: context.l10n.letsGetToKnowYou,
      subtitle: context.l10n.provideBasicInfo,
      continueText:
          _isSubmitting ? context.l10n.savingText : context.l10n.continueText,
      isContinueEnabled: _isFormValid,
      isSubmitting: _isSubmitting,
      onContinue: _handleContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            controller: _firstNameController,
            label: context.l10n.firstName,
            hintText: "John",
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          AppFormField(
            controller: _lastNameController,
            label: context.l10n.lastName,
            hintText: "Doe",
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
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppText.labelMedium(
            context.l10n.genderLabel,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
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
