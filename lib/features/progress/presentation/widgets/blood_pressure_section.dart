import 'package:yelima/core/theme/app_colors.dart';
import 'trend_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/vital_trends.dart';
import '../controllers/progress_controller.dart';
import '../screens/full_screen_graph_view.dart';
import 'graphs/bp_graph.dart';
import 'progress_graph_card.dart';
import 'progress_legend_item.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The blood pressure chart card.
class BloodPressureSection extends StatelessWidget {
  final String durationLabel;

  const BloodPressureSection({super.key, required this.durationLabel});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressController>(
      builder: (context, controller, child) {
        return ProgressGraphCard(
          title: context.l10n.bloodPressure,
          latestValue: _getLatestBP(controller.bpTrendState.data),
          latestSubtext: context.l10n.latestReading,
          description: context.l10n.bloodPressureTrend,
          graph: _buildBPGraph(context, controller),
          onExpand: () => _openFullScreen(context, controller, 'bp'),
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
      },
    );
  }

  String _getLatestBP(BPTrend? data) {
    if (data == null) return '--/--';
    final sysValues = data.systolic.where((v) => v != null).toList();
    final diaValues = data.diastolic.where((v) => v != null).toList();
    if (sysValues.isEmpty || diaValues.isEmpty) return '--/--';
    return '${sysValues.last?.toInt()}/${diaValues.last?.toInt()}';
  }

  Widget _buildBPGraph(BuildContext context, ProgressController controller) =>
      TrendView(state: controller.bpTrendState, chart: (d) => BPGraph(data: d));

  void _openFullScreen(
      BuildContext context, ProgressController controller, String tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<ProgressController>.value(
          value: controller,
          child: FullScreenGraphView(
            activeTab: tab,
            durationLabel: durationLabel,
          ),
        ),
      ),
    );
  }
}
