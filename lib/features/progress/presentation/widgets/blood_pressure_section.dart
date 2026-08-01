import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../domain/entities/vital_trends.dart';
import '../controllers/progress_controller.dart';
import '../screens/full_screen_graph_view.dart';
import 'graphs/bp_graph.dart';
import 'progress_graph_card.dart';
import 'progress_legend_item.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

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
          badgeText: context.l10n.improving,
          badgeIcon: Icons.check,
          badgeColor: const Color(0xFFDCFCE7),
          badgeTextColor: const Color(0xFF166534),
          description: context.l10n.bloodPressureTrend,
          graph: _buildBPGraph(controller),
          onExpand: () => _openFullScreen(context, controller, 'bp'),
          legend: Row(
            children: [
              ProgressLegendItem(color: const Color(0xFFEF4444), label: context.l10n.systolic),
              const SizedBox(width: 16),
              ProgressLegendItem(color: const Color(0xFF3B82F6), label: context.l10n.diastolic),
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

  Widget _buildBPGraph(ProgressController controller) {
    if (controller.bpTrendState.isLoading) {
      return Center(child: AppShimmer.box(width: double.infinity, height: 180));
    }
    if (controller.bpTrendState.error != null) {
      return Center(child: Text(controller.bpTrendState.error!));
    }
    if (controller.bpTrendState.data == null) {
      return const Center(child: Text('No data available'));
    }
    return BPGraph(data: controller.bpTrendState.data!);
  }

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
