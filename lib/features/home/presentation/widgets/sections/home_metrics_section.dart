import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../metric_card.dart';
import '../medication_adherence_card.dart';
import '../../controllers/home_metrics_controller.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: AppText.labelLarge(
            'LAST READINGS',
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
            letterSpacing: 1.2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Blood pressure',
                  mainValue: bpMain,
                  subValue: bpSub,
                  unit: 'mmHg',
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Blood glucose',
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
            percentage: adherence,
            message: adherence >= 0.8
                ? "Keep it up. You're doing great 💪"
                : "Let's improve your adherence 🌟",
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
