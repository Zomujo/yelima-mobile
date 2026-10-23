import 'package:flutter/material.dart';
import '../widgets/trend_view.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../controllers/progress_controller.dart';
import '../widgets/graphs/bp_graph.dart';
import '../widgets/graphs/glucose_graph.dart';
import '../widgets/full_screen_close_button.dart';

/// One chart in landscape, filling the screen.
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
    if (widget.activeTab == 'bp') return context.l10n.bloodPressureTitle;
    return context.l10n.bloodGlucoseTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
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
    return widget.activeTab == 'bp'
        ? TrendView(
            state: controller.bpTrendState,
            chart: (d) => BPGraph(data: d),
            height: null)
        : TrendView(
            state: controller.glucoseTrendState,
            chart: (d) => GlucoseGraph(data: d),
            height: null);
  }
}
