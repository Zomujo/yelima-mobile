import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/step_layout.dart';
import 'package:yelima/shared/widgets/forms/app_date_picker_field.dart';
import 'package:yelima/shared/widgets/forms/app_form_field.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:clock/clock.dart';
import 'package:yelima/shared/utils/run_with_loader.dart';
import 'package:yelima/shared/utils/app_snackbar.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';

/// Registration step 2: date of birth, or age.
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
  bool _isEnteringAge = false;
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedDate = context.read<UserController>().userEntity?.dateOfBirth;

    _ageController.addListener(() {
      if (_isEnteringAge) setState(() {});
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  /// The entered date of birth, or one estimated from the entered age.
  DateTime? get _dob {
    if (!_isEnteringAge) return _selectedDate;
    final age = int.tryParse(_ageController.text);
    return age == null ? null : DateTime(clock.now().year - age, 1, 1);
  }

  Future<void> _continue() async {
    final dob = _dob;
    if (dob == null) return;
    if (yearsSince(dob) < 18) {
      AppSnackBar.showError(context,
          message: context.l10n.ageRequirementSnackBar);
      return;
    }
    FocusScope.of(context).unfocus();
    final users = context.read<UserController>();
    final saved = await runWithLoader(context,
        message: context.l10n.savingDob, action: () => users.updateDob(dob));
    if (saved && mounted) widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: context.l10n.whenWereYouBorn,
      subtitle: context.l10n.dobSubtitle,
      isContinueEnabled: _dob != null,
      onBack: widget.onBack,
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEnteringAge = !_isEnteringAge;
                  FocusScope.of(context).unfocus();
                });
              },
              child: AppText.bodyMedium(
                _isEnteringAge
                    ? context.l10n.enterDobInstead
                    : context.l10n.enterAgeInstead,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
