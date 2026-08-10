import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../user/domain/entities/user_entity.dart';
import '../../../../user/presentation/controllers/user_controller.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/step_layout.dart';
import '../condition_selection_card.dart';
import '../../../../../core/extensions/l10n_extension.dart';

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
      AppSnackBar.showError(context,
          message: context.l10n.pleaseSelectCondition);
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
      title: context.l10n.whatAreYouLivingWith,
      subtitle: context.l10n.healthConditionsSubtitle,
      continueText: _isSubmitting ? context.l10n.completingText : context.l10n.continueText,
      isContinueEnabled: _hasConsented,
      isSubmitting: _isSubmitting,
      onBack: widget.onBack,
      onContinue: _handleContinue,
      child: Column(
        children: [
          ConditionSelectionCard(
            title: context.l10n.hypertension,
            subtitle: context.l10n.highBloodPressure,
            isSelected:
                _selectedCondition == HealthConditionCategory.hypertension,
            onTap: () => _toggleCondition(HealthConditionCategory.hypertension),
          ),
          const SizedBox(height: 16),
          ConditionSelectionCard(
            title: context.l10n.diabetes,
            subtitle: context.l10n.sugars,
            isSelected: _selectedCondition == HealthConditionCategory.diabetes,
            onTap: () => _toggleCondition(HealthConditionCategory.diabetes),
          ),
          const SizedBox(height: 16),
          ConditionSelectionCard(
            title: context.l10n.bothConditions,
            subtitle: context.l10n.bothConditionsSubtitle,
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
              Expanded(
                child: AppText.bodyMedium(
                  context.l10n.healthDataConsent,
                  color: const Color(0xFF475569),
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
