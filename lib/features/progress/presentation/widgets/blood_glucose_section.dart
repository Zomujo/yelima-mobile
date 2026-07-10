import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../domain/entities/vital_trends.dart';
import '../controllers/progress_controller.dart';
import '../screens/full_screen_graph_view.dart';
import 'graphs/glucose_graph.dart';
import 'progress_graph_card.dart';

class BloodGlucoseSection extends StatelessWidget {
  final String durationLabel;

  const BloodGlucoseSection({super.key, required this.durationLabel});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressController>(
      builder: (context, controller, child) {
        return ProgressGraphCard(
          title: 'Blood Glucose',
          latestValue: _getLatestGlucose(controller.glucoseTrendState.data),
          latestSubtext: 'mmol/L',
          badgeText: 'In good range',
          badgeIcon: Icons.check,
          badgeColor: const Color(0xFFDCFCE7),
          badgeTextColor: const Color(0xFF166534),
          badgeTrailingIcon: Icons.arrow_downward,
          description: 'Your blood glucose trend over this period.',
          graph: _buildGlucoseGraph(controller),
          onExpand: () => _openFullScreen(context, controller, 'glucose'),
        );
      },
    );
  }

  String _getLatestGlucose(VitalTrend? data) {
    if (data == null) return '--';
    final valid = data.values.where((v) => v != null).toList();
    if (valid.isEmpty) return '--';
    return valid.last!.toStringAsFixed(1);
  }

  Widget _buildGlucoseGraph(ProgressController controller) {
    if (controller.glucoseTrendState.isLoading) {
      return Center(child: AppShimmer.box(width: double.infinity, height: 180));
    }
    if (controller.glucoseTrendState.error != null) {
      return Center(child: Text(controller.glucoseTrendState.error!));
    }
    if (controller.glucoseTrendState.data == null) {
      return const Center(child: Text('No data available'));
    }
    return GlucoseGraph(data: controller.glucoseTrendState.data!);
  }

  void _openFullScreen(BuildContext context, ProgressController controller, String tab) {
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
