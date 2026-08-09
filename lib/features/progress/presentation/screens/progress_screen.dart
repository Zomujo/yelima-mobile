import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../controllers/progress_controller.dart';
import '../widgets/duration_selector.dart';
import '../widgets/blood_glucose_section.dart';
import '../widgets/blood_pressure_section.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/utils/app_tutorial_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String duration = '1w';
  late final ProgressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl<ProgressController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      if (mounted) {
        _showTutorial();
      }
    });
  }

  void _showTutorial() {
    AppTutorialService.showTutorial(
      context: context,
      tutorialId: 'progress_screen_intro',
      targets: [
        AppTutorialService.createTarget(
          identify: 'progress_graph',
          key: AppTutorialService.progressGraphKey,
          title: context.l10n.tutorialProgressGraphTitle,
          description: context.l10n.tutorialProgressGraphDesc,
        ),
      ],
    );
  }

  void _fetchData() {
    final dateRange = _getDateRange();
    _controller.fetchBPTrend(dateRange: dateRange);
    _controller.fetchGlucoseTrend(dateRange: dateRange);
  }

  String _getDateRange() {
    switch (duration) {
      case '1w':
        return 'thisWeek';
      case '1m':
        return 'thisMonth';
      default:
        return 'today';
    }
  }

  String getDurationLabel(BuildContext context) {
    if (duration == '24h') return context.l10n.last24Hours;
    if (duration == '1w') return context.l10n.last7Days;
    return context.l10n.last30Days;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppHeader(
          title: context.l10n.yourProgress,
          onBackPressed: () => Navigator.of(context).pop(),
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            AppText.labelMedium(
              '${getDurationLabel(context)} • ${context.l10n.updatedToday}',
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),

            // Time Tabs (Duration Selector)
            DurationSelector(
              duration: duration,
              onDurationChanged: (newDuration) {
                setState(() {
                  duration = newDuration;
                });
                _fetchData();
              },
            ),
            const SizedBox(height: 24),

            // Blood Pressure Card
            BloodPressureSection(
              key: AppTutorialService.progressGraphKey,
              durationLabel: getDurationLabel(context),
            ),
            const SizedBox(height: 24),

            // Blood Glucose Card
            BloodGlucoseSection(durationLabel: getDurationLabel(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
