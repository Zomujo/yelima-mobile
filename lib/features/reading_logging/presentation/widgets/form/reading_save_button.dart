import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../home/presentation/controllers/home_metrics_controller.dart';
import '../../controllers/reading_logging_controller.dart';

class ReadingSaveButton extends StatelessWidget {
  const ReadingSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingLoggingController>(
      builder: (context, controller, child) {
        return AppButton(
          text: controller.state.isSaving ? 'Saving...' : 'Save',
          onPressed: () async {
            final result = await controller.saveReading();
            if (context.mounted) {
              result.fold(
                (error) => AppSnackBar.showError(context, message: error),
                (_) {
                  AppSnackBar.showSuccess(context, message: 'Reading saved successfully');
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
}
