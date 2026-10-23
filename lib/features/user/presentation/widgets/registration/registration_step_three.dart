import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/user/domain/entities/user_entity.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/utils/app_snackbar.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/step_layout.dart';
import 'package:yelima/features/user/presentation/widgets/registration/condition_selection_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/shared/utils/run_with_loader.dart';

/// Registration step 3: conditions and consent to store health data.
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

  @override
  void initState() {
    super.initState();
    final user = context.read<UserController>().userEntity;
    _selectedCondition = HealthConditionCategory.from(user?.conditions ?? []);
    _hasConsented = user?.hasConsented ?? false;
  }

  void _toggleCondition(HealthConditionCategory condition) => setState(() =>
      _selectedCondition = _selectedCondition == condition ? null : condition);

  Future<void> _continue() async {
    final category = _selectedCondition;
    if (category == null) {
      AppSnackBar.showError(context,
          message: context.l10n.pleaseSelectCondition);
      return;
    }
    final users = context.read<UserController>();
    final saved = await runWithLoader(context,
        message: context.l10n.savingHealthConditions,
        action: () => users.updateHealthConditions(
            category: category, consented: _hasConsented));
    if (saved && mounted) widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: context.l10n.whatAreYouLivingWith,
      subtitle: context.l10n.healthConditionsSubtitle,
      isContinueEnabled: _hasConsented,
      onBack: widget.onBack,
      onContinue: _continue,
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
                  side: const BorderSide(color: AppColors.slate300),
                  activeColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText.bodyMedium(
                  context.l10n.healthDataConsent,
                  color: AppColors.slate600,
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
