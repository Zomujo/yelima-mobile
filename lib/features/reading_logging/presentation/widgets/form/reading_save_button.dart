import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../home/presentation/controllers/home_metrics_controller.dart';
import '../../controllers/reading_logging_controller.dart';
import '../../states/reading_logging_state.dart';
import '../../../domain/reading_limits.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class ReadingSaveButton extends StatelessWidget {
  const ReadingSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingLoggingController>(
      builder: (context, controller, child) {
        return AppButton(
          text: controller.state.isSaving
              ? '${context.l10n.save}...'
              : context.l10n.save,
          onPressed: () async {
            final invalid = _invalidReading(controller.state);
            if (invalid != null) {
              AppSnackBar.showError(context,
                  message: _errorText(context, invalid));
              return;
            }
            final result = await controller.saveReading();
            if (context.mounted) {
              result.fold(
                (error) => AppSnackBar.showError(context, message: error),
                (_) {
                  AppSnackBar.showSuccess(context,
                      message: context.l10n.readingSaved);
                  try {
                    context.read<HomeMetricsController>().fetchMetrics();
                  } catch (_) {}
                },
              );
            }
          },
          isDisabled: !controller.state.hasChanged || controller.state.isSaving,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          borderRadius: 12,
          height: 50,
        );
      },
    );
  }

  ReadingError? _invalidReading(ReadingLoggingState s) =>
      s.selectedTypeIndex == 0
          ? ReadingLimits.bloodPressureError(s.systolic, s.diastolic)
          : ReadingLimits.bloodSugarError(s.sugarLevel);

  String _errorText(BuildContext context, ReadingError error) =>
      switch (error) {
        ReadingError.bpOutOfRange => context.l10n.readingErrorBpRange(
            ReadingLimits.systolicMin,
            ReadingLimits.diastolicMin,
            ReadingLimits.systolicMax,
            ReadingLimits.diastolicMax),
        ReadingError.systolicNotAboveDiastolic =>
          context.l10n.readingErrorSystolicNotAbove,
        ReadingError.sugarOutOfRange => context.l10n.readingErrorSugarRange(
            '${ReadingLimits.sugarMin}', '${ReadingLimits.sugarMax}'),
      };
}
