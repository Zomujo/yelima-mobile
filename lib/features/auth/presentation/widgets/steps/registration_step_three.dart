import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../user/domain/entities/user_entity.dart';
import '../../../../user/presentation/controllers/user_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/step_layout.dart';
import '../condition_selection_card.dart';

class RegistrationStepThree extends StatefulWidget {
  const RegistrationStepThree({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<RegistrationStepThree> createState() => _RegistrationStepThreeState();
}

class _RegistrationStepThreeState extends State<RegistrationStepThree> {
  HealthConditionCategory? _selectedCondition;
  bool _hasConsented = false;
  bool _isSubmitting = false;

  void _toggleCondition(HealthConditionCategory condition) {
    setState(() {
      if (_selectedCondition == condition) {
        _selectedCondition = null;
      } else {
        _selectedCondition = condition;
      }
    });
  }

  void _handleContinue() async {
    if (!_hasConsented || _isSubmitting) return;

    if (_selectedCondition == null) {
      AppSnackBar.showError(context, message: 'Please select a condition to continue.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final controller = context.read<UserController>();

    final response = await controller.updateHealthConditions(
      context,
      category: _selectedCondition,
      consented: _hasConsented,
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
      title: 'What are you living with?',
      subtitle:
          'To personalize your medication tracking and provide relevant health insights, please tell us what conditions you are living with.',
      continueText: _isSubmitting ? 'Completing...' : 'Continue',
      isContinueEnabled: _hasConsented,
      isSubmitting: _isSubmitting,
      onBack: widget.onBack,
      onContinue: _handleContinue,
      child: Column(
        children: [
          ConditionSelectionCard(
            title: 'Hypertension',
            subtitle: 'High Blood Pressure',
            isSelected:
                _selectedCondition == HealthConditionCategory.hypertension,
            onTap: () => _toggleCondition(HealthConditionCategory.hypertension),
          ),
          const SizedBox(height: 16),
          ConditionSelectionCard(
            title: 'Diabetes',
            subtitle: 'Sugars',
            isSelected: _selectedCondition == HealthConditionCategory.diabetes,
            onTap: () => _toggleCondition(HealthConditionCategory.diabetes),
          ),
          const SizedBox(height: 16),
          ConditionSelectionCard(
            title: 'Both',
            subtitle: 'High Blood Pressure and Sugars',
            isSelected: _selectedCondition == HealthConditionCategory.both,
            onTap: () => _toggleCondition(HealthConditionCategory.both),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _hasConsented,
                  onChanged: (value) {
                    setState(() {
                      _hasConsented = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: AppText.bodyMedium(
                  'I consent to Yelima processing my health data for the purposes of managing my care and personalizing my experience.',
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
