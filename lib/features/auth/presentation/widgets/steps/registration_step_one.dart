import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../user/presentation/controllers/user_controller.dart';

import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/step_layout.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/app_dropdown.dart';

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
  String? _selectedGender;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _selectedGender != null;
  }

  void _handleContinue() async {
    if (!_isFormValid || _isSubmitting) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final response = await context.read<UserController>().updateBasicInfo(
          context,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          gender: _selectedGender!,
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
      title: 'Let\'s get to know you',
      subtitle: 'Please provide your basic information to get started.',
      continueText: _isSubmitting ? 'Saving...' : 'Continue',
      isContinueEnabled: _isFormValid,
      isSubmitting: _isSubmitting,
      onContinue: _handleContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            controller: _firstNameController,
            label: 'First name',
            hintText: "John",
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          AppFormField(
            controller: _lastNameController,
            label: 'Last name',
            hintText: "Doe",
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          const AppText.labelMedium(
            'Gender',
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
          const SizedBox(height: 8),
          AppDropdown<String>(
            value: _selectedGender,
            hintText: 'Select Gender',
            items: const ['Male', 'Female'],
            itemLabelBuilder: (gender) => gender,
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
