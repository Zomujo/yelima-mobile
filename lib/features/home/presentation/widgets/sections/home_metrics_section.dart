import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../metric_card.dart';
import '../medication_adherence_card.dart';
import 'critical_health_banner.dart';
import '../../controllers/home_metrics_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';

/// Blood pressure, blood sugar and adherence cards, with warnings for dangerous readings.
class HomeMetricsSection extends StatelessWidget {
  const HomeMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeMetricsController>();
    final state = controller.state;
    final isLoading = state.vitals == null;

    final bp = state.vitals?.bloodPressure?.value ?? '--/--';
    final bg = state.vitals?.bloodSugar?.value ?? '--';
    final adherence = state.adherence ?? 0.0;

    final bpParts = bp.split('/');
    final bpMain = bpParts.isNotEmpty && bpParts[0] != '--' ? bpParts[0] : '--';
    final bpSub = bpParts.length > 1 ? '/${bpParts[1]}' : '';

    final bpSev = state.vitals?.bloodPressure?.grade ?? VitalSeverity.unknown;
    final bgSev = state.vitals?.bloodSugar?.grade ?? VitalSeverity.unknown;

    final List<Widget> banners = [];

    if (bpSev == VitalSeverity.critical) {
      banners.add(CriticalHealthBanner(
        title: context.l10n.criticalBloodPressureTitle,
        message: context.l10n.criticalBloodPressureMessage,
        isCritical: true,
      ));
    } else if (bpSev == VitalSeverity.veryHigh) {
      banners.add(CriticalHealthBanner(
        title: context.l10n.veryHighBloodPressureTitle,
        message: context.l10n.veryHighBloodPressureMessage,
        isCritical: false,
      ));
    }

    if (bgSev == VitalSeverity.critical) {
      banners.add(CriticalHealthBanner(
        title: context.l10n.criticalBloodSugarTitle,
        message: context.l10n.criticalBloodSugarMessage,
        isCritical: true,
      ));
    } else if (bgSev == VitalSeverity.veryHigh) {
      banners.add(CriticalHealthBanner(
        title: context.l10n.veryHighBloodSugarTitle,
        message: context.l10n.veryHighBloodSugarMessage,
        isCritical: false,
      ));
    } else if (bgSev == VitalSeverity.criticallyLow) {
      banners.add(CriticalHealthBanner(
        title: context.l10n.criticallyLowBloodSugarTitle,
        message: context.l10n.criticallyLowBloodSugarMessage,
        isCritical: true,
      ));
    } else if (bgSev == VitalSeverity.low) {
      banners.add(CriticalHealthBanner(
        title: context.l10n.lowBloodSugarTitle,
        message: context.l10n.lowBloodSugarMessage,
        isCritical: false,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...banners,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: AppText.labelLarge(
            context.l10n.lastReadings,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
            letterSpacing: 1.2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            key: AppTutorialKeys.homeMetricsKey,
            children: [
              Expanded(
                child: MetricCard(
                  title: context.l10n.bloodPressure,
                  mainValue: bpMain,
                  subValue: bpSub,
                  unit: 'mmHg',
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: context.l10n.bloodGlucose,
                  mainValue: bg,
                  unit: 'mmol/L',
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: MedicationAdherenceCard(
            key: AppTutorialKeys.homeAdherenceKey,
            percentage: adherence,
            message: adherence >= 0.8
                ? context.l10n.adherenceGreat
                : context.l10n.adherenceImprove,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
