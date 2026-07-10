import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../controllers/progress_controller.dart';
import '../widgets/graphs/bp_graph.dart';
import '../widgets/graphs/glucose_graph.dart';
import '../widgets/full_screen_close_button.dart';

class FullScreenGraphView extends StatefulWidget {
  final String activeTab;
  final String durationLabel;

  const FullScreenGraphView({
    super.key,
    required this.activeTab,
    required this.durationLabel,
  });

  @override
  State<FullScreenGraphView> createState() => _FullScreenGraphViewState();
}

class _FullScreenGraphViewState extends State<FullScreenGraphView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String get _title {
    if (widget.activeTab == 'bp') return 'Blood Pressure';
    return 'Blood Glucose';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen graph
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 8,
                  right: 8,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.titleMedium(
                            _title,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                          const SizedBox(height: 2),
                          AppText.labelSmall(
                            widget.durationLabel,
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildGraph(context),
                    ),
                  ],
                ),
              ),
            ),

            // Minimize FAB
            FullScreenCloseButton(
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph(BuildContext context) {
    final controller = context.watch<ProgressController>();

    if (widget.activeTab == 'bp') {
      if (controller.bpTrendState.isLoading) return _loader();
      if (controller.bpTrendState.error != null) {
        return Center(
            child: AppText.bodyMedium(controller.bpTrendState.error!));
      }
      if (controller.bpTrendState.data == null) {
        return const Center(child: AppText.bodyMedium('No data available'));
      }
      return BPGraph(data: controller.bpTrendState.data!);
    } else {
      if (controller.glucoseTrendState.isLoading) return _loader();
      if (controller.glucoseTrendState.error != null) {
        return Center(
            child: AppText.bodyMedium(controller.glucoseTrendState.error!));
      }
      if (controller.glucoseTrendState.data == null) {
        return const Center(child: AppText.bodyMedium('No data available'));
      }
      return GlucoseGraph(data: controller.glucoseTrendState.data!);
    }
  }

  Widget _loader() => Center(
        child: AppShimmer.box(
          width: double.infinity,
          height: double.infinity,
        ),
      );
}
