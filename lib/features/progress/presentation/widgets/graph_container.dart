import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../controllers/progress_controller.dart';
import '../screens/full_screen_graph_view.dart';
import 'graphs/bp_graph.dart';
import 'graphs/glucose_graph.dart';

class GraphContainer extends StatelessWidget {
  final String activeTab;
  final String durationLabel;

  const GraphContainer({super.key, required this.activeTab, required this.durationLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Graph content
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 40, 12, 16),
              child: _buildGraph(context),
            ),
          ),

          // Maximize FAB
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.white.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: () => _openFullScreen(context),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(
                    Icons.fullscreen,
                    size: 22,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraph(BuildContext context) {
    final controller = context.watch<ProgressController>();

    if (activeTab == 'bp') {
      if (controller.bpTrendState.isLoading) return _buildGraphLoader();
      if (controller.bpTrendState.error != null) {
        return Center(child: Text(controller.bpTrendState.error!));
      }
      if (controller.bpTrendState.data == null) {
        return const Center(child: Text('No data available'));
      }
      return BPGraph(data: controller.bpTrendState.data!);
    } else {
      if (controller.glucoseTrendState.isLoading) return _buildGraphLoader();
      if (controller.glucoseTrendState.error != null) {
        return Center(child: Text(controller.glucoseTrendState.error!));
      }
      if (controller.glucoseTrendState.data == null) {
        return const Center(child: Text('No data available'));
      }
      return GlucoseGraph(data: controller.glucoseTrendState.data!);
    }
  }

  Widget _buildGraphLoader() {
    return Center(
      child: AppShimmer.box(
        width: double.infinity,
        height: 200,
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenGraphView(
          activeTab: activeTab,
          durationLabel: durationLabel,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
