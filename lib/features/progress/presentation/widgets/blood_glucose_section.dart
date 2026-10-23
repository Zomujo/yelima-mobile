import 'package:flutter/material.dart';
import 'trend_view.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/vital_trends.dart';
import '../controllers/progress_controller.dart';
import '../screens/full_screen_graph_view.dart';
import 'graphs/glucose_graph.dart';
import 'progress_graph_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The blood sugar chart card.
class BloodGlucoseSection extends StatelessWidget {
  final String durationLabel;

  const BloodGlucoseSection({super.key, required this.durationLabel});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressController>(
      builder: (context, controller, child) {
        return ProgressGraphCard(
          title: context.l10n.bloodGlucose,
          latestValue: _getLatestGlucose(controller.glucoseTrendState.data),
          latestSubtext: context.l10n.mmolL,
          description: context.l10n.bloodGlucoseTrend,
          graph: _buildGlucoseGraph(context, controller),
          onExpand: () => _openFullScreen(context, controller, 'glucose'),
        );
      },
    );
  }

  String _getLatestGlucose(VitalTrend? data) {
    if (data == null) return '--';
    if (data.latestValue != null) return data.latestValue!.toStringAsFixed(1);
    final valid = data.values.where((v) => v != null).toList();
    if (valid.isEmpty) return '--';
    return valid.last!.toStringAsFixed(1);
  }

  Widget _buildGlucoseGraph(
          BuildContext context, ProgressController controller) =>
      TrendView(
          state: controller.glucoseTrendState,
          chart: (d) => GlucoseGraph(data: d));

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
