import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../controllers/progress_controller.dart';
import '../widgets/duration_selector.dart';
import '../widgets/blood_glucose_section.dart';
import '../widgets/blood_pressure_section.dart';
import '../widgets/progress_note_banner.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';
import '../../domain/entities/vital_trends.dart';

/// Blood pressure and sugar charts over 24 hours, a week or a month.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ChartDateRange _range = ChartDateRange.thisWeek;
  late final _controller = context.read<ProgressController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load(_range);
      if (mounted) AppTutorialService.showProgressTutorial(context);
    });
  }

  String _rangeLabel(BuildContext context) => switch (_range) {
        ChartDateRange.today => context.l10n.last24Hours,
        ChartDateRange.thisWeek => context.l10n.last7Days,
        ChartDateRange.thisMonth => context.l10n.last30Days,
      };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppHeader(
          title: context.l10n.yourProgress,
          onBackPressed: () => Navigator.of(context).pop(),
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            AppText.labelMedium(
              '${_rangeLabel(context)} • ${context.l10n.updatedToday}',
              color: AppColors.textGrey,
            ),
            const SizedBox(height: 16),
            DurationSelector(
              range: _range,
              onChanged: (range) {
                setState(() => _range = range);
                _controller.load(range);
              },
            ),
            const SizedBox(height: 24),
            Consumer<ProgressController>(
              builder: (context, controller, child) {
                final note = controller.bpTrendState.data?.note ??
                    controller.glucoseTrendState.data?.note;
                if (note != null && note.trim().isNotEmpty) {
                  return ProgressNoteBanner(note: note);
                }
                return const SizedBox.shrink();
              },
            ),
            BloodPressureSection(
              key: AppTutorialKeys.progressGraphKey,
              durationLabel: _rangeLabel(context),
            ),
            const SizedBox(height: 24),
            BloodGlucoseSection(durationLabel: _rangeLabel(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
