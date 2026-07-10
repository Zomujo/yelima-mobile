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
    });
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

  String getDurationLabel() {
    if (duration == '24h') return 'Last 24 hours';
    if (duration == '1w') return 'Last 7 days';
    return 'Last 30 days';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppHeader(
          title: 'Your Progress',
          onBackPressed: () => Navigator.of(context).pop(),
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            AppText.labelMedium(
              '${getDurationLabel()} • updated today',
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
            BloodPressureSection(durationLabel: getDurationLabel()),
            const SizedBox(height: 24),

            // Blood Glucose Card
            BloodGlucoseSection(durationLabel: getDurationLabel()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
