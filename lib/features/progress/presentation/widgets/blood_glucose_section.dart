import 'package:flutter/material.dart';
import 'trend_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vital_trends.dart';
import '../controllers/progress_controller.dart';
import '../screens/full_screen_graph_view.dart';
import 'graphs/glucose_graph.dart';
import 'progress_graph_card.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The blood sugar chart card.
class BloodGlucoseSection extends ConsumerWidget {
  final String durationLabel;

  const BloodGlucoseSection({super.key, required this.durationLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref
        .watch(progressControllerProvider.select((s) => s.glucoseTrendState));
    return ProgressGraphCard(
      title: context.l10n.bloodGlucose,
      latestValue: _getLatestGlucose(trend.data),
      latestSubtext: context.l10n.mmolL,
      description: context.l10n.bloodGlucoseTrend,
      graph: TrendView(state: trend, chart: (d) => GlucoseGraph(data: d)),
      onExpand: () => _openFullScreen(context, 'glucose'),
    );
  }

  String _getLatestGlucose(VitalTrend? data) {
    if (data == null) return '--';
    if (data.latestValue != null) return data.latestValue!.toStringAsFixed(1);
    final valid = data.values.where((v) => v != null).toList();
    if (valid.isEmpty) return '--';
    return valid.last!.toStringAsFixed(1);
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
