import 'package:yelima/core/theme/app_colors.dart';
import 'trend_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vital_trends.dart';
import '../controllers/progress_controller.dart';
import '../screens/full_screen_graph_view.dart';
import 'graphs/bp_graph.dart';
import 'progress_graph_card.dart';
import 'progress_legend_item.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The blood pressure chart card.
class BloodPressureSection extends ConsumerWidget {
  final String durationLabel;

  const BloodPressureSection({super.key, required this.durationLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend =
        ref.watch(progressControllerProvider.select((s) => s.bpTrendState));
    return ProgressGraphCard(
      title: context.l10n.bloodPressure,
      latestValue: _getLatestBP(trend.data),
      latestSubtext: context.l10n.latestReading,
      description: context.l10n.bloodPressureTrend,
      graph: TrendView(state: trend, chart: (d) => BPGraph(data: d)),
      onExpand: () => _openFullScreen(context, 'bp'),
      legend: Row(
        children: [
          ProgressLegendItem(
              color: AppColors.red500, label: context.l10n.systolic),
          const SizedBox(width: 16),
          ProgressLegendItem(
              color: AppColors.blue500, label: context.l10n.diastolic),
        ],
      ),
    );
  }

  String _getLatestBP(BPTrend? data) {
    if (data == null) return '--/--';
    final sysValues = data.systolic.where((v) => v != null).toList();
    final diaValues = data.diastolic.where((v) => v != null).toList();
    if (sysValues.isEmpty || diaValues.isEmpty) return '--/--';
    return '${sysValues.last?.toInt()}/${diaValues.last?.toInt()}';
  }

  void _openFullScreen(BuildContext context, String tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenGraphView(
          activeTab: tab,
          durationLabel: durationLabel,
        ),
      ),
    );
  }
}
