import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../user/presentation/controllers/user_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/step_layout.dart';
import '../../../../../shared/widgets/forms/app_date_picker_field.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../core/extensions/l10n_extension.dart';

class RegistrationStepTwo extends StatefulWidget {
  const RegistrationStepTwo({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<RegistrationStepTwo> createState() => _RegistrationStepTwoState();
}

class _RegistrationStepTwoState extends State<RegistrationStepTwo> {
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _isEnteringAge = false;
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    final user = context.read<UserController>().userEntity;
    if (user != null && user.dateOfBirth != null) {
      _selectedDate = user.dateOfBirth;
      _isEnteringAge = false;
    }

    _ageController.addListener(() {
      if (_isEnteringAge) setState(() {});
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    if (_isEnteringAge) {
      final ageText = _ageController.text;
      if (ageText.isEmpty) return false;
      final age = int.tryParse(ageText);
      if (age == null) return false;
      return age >= 18;
    } else {
      if (_selectedDate == null) return false;

      // 18+ Age validation
      final today = DateTime.now();
      var age = today.year - _selectedDate!.year;
      if (today.month < _selectedDate!.month ||
          (today.month == _selectedDate!.month &&
              today.day < _selectedDate!.day)) {
        age--;
      }

      return age >= 18;
    }
  }

  void _handleContinue() async {
    if (!_isFormValid || _isSubmitting) {
      if (!_isEnteringAge && _selectedDate != null) {
        // Form is invalid despite having a date, meaning they are under 18
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.l10n.ageRequirementSnackBar)),
        );
      } else if (_isEnteringAge && _ageController.text.isNotEmpty) {
        final age = int.tryParse(_ageController.text);
        if (age != null && age < 18) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(context.l10n.ageRequirementSnackBar)),
          );
        }
      }
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    DateTime finalDob;
    if (_isEnteringAge) {
      final age = int.parse(_ageController.text);
      // Create a mock DOB so the user is exactly 'age' years old
      finalDob = DateTime(DateTime.now().year - age, 1, 1);
    } else {
      finalDob = _selectedDate!;
    }

    final response = await context.read<UserController>().updateDob(
          context,
          dob: finalDob,
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
      title: context.l10n.whenWereYouBorn,
      subtitle: context.l10n.dobSubtitle,
      continueText: _isSubmitting ? context.l10n.savingText : context.l10n.continueText,
      isContinueEnabled: _isFormValid,
      isSubmitting: _isSubmitting,
      onBack: widget.onBack,
      onContinue: _handleContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isEnteringAge = false;
                    FocusScope.of(context).unfocus();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isEnteringAge
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: !_isEnteringAge
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: AppText.bodyMedium(context.l10n.dateOfBirthTab,
                        color: !_isEnteringAge
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isEnteringAge = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isEnteringAge
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _isEnteringAge
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: AppText.bodyMedium(context.l10n.enterAgeTab,
                        color: _isEnteringAge
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (!_isEnteringAge)
            AppDatePickerField(
              label: context.l10n.dateOfBirthLabel,
              hintText: context.l10n.dobHint,
              isRequired: true,
              initialDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            )
          else
            AppFormField(
              controller: _ageController,
              label: context.l10n.ageLabel,
              hintText: context.l10n.enterAgeHint,
              isRequired: true,
              keyboardType: TextInputType.number,
            ),
        ],
      ),
    );
  }
}
