import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../metric_card.dart';
import '../medication_adherence_card.dart';
import 'critical_health_banner.dart';
import '../../controllers/home_metrics_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../../core/utils/app_tutorial_keys.dart';

class HomeMetricsSection extends StatefulWidget {
  const HomeMetricsSection({super.key});

  @override
  State<HomeMetricsSection> createState() => _HomeMetricsSectionState();
}

class _HomeMetricsSectionState extends State<HomeMetricsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeMetricsController>().fetchMetrics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeMetricsController>();
    final state = controller.state;
    final bool isLoading = state.isLoading && state.metrics == null;

    final bp = state.metrics?.bloodPressure ?? '--/--';
    final bg = state.metrics?.bloodGlucose ?? '--';
    final adherence = state.metrics?.adherenceRate ?? 0.0;

    final bpParts = bp.split('/');
    final bpMain = bpParts.isNotEmpty && bpParts[0] != '--' ? bpParts[0] : '--';
    final bpSub = bpParts.length > 1 ? '/${bpParts[1]}' : '';

    final bpSev = state.metrics?.bpSeverity?.toLowerCase() ?? '';
    final bgSev = state.metrics?.bgSeverity?.toLowerCase() ?? '';

    final List<Widget> banners = [];

    if (bpSev == 'critical' || bpSev == 'crisis') {
      banners.add(const CriticalHealthBanner(
        title: 'Critical Blood Pressure',
        message:
            'Repeat measurement promptly; assess for urgent/emergency care.',
        isCritical: true,
      ));
    } else if (bpSev == 'very_high') {
      banners.add(const CriticalHealthBanner(
        title: 'Very High Blood Pressure',
        message: 'Clinical review recommended.',
        isCritical: false,
      ));
    }

    if (bgSev == 'critical') {
      banners.add(const CriticalHealthBanner(
        title: 'Critical Blood Sugar',
        message: 'Prompt clinical assessment required.',
        isCritical: true,
      ));
    } else if (bgSev == 'very_high') {
      banners.add(const CriticalHealthBanner(
        title: 'Very High Blood Sugar',
        message: 'Needs attention, especially if persistent.',
        isCritical: false,
      ));
    } else if (bgSev == 'critically_low') {
      banners.add(const CriticalHealthBanner(
        title: 'Critically Low Blood Sugar',
        message:
            'Clinically significant hypoglycemia. Please seek help immediately.',
        isCritical: true,
      ));
    } else if (bgSev == 'low') {
      banners.add(const CriticalHealthBanner(
        title: 'Low Blood Sugar',
        message: 'Hypoglycemia detected. Consider consuming fast-acting carbs.',
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
