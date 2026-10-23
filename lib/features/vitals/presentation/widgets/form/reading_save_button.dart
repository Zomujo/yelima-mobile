import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/utils/app_snackbar.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../controllers/reading_logging_controller.dart';
import '../../vital_failure_message.dart';

/// Saves the reading and says whether it worked.
class ReadingSaveButton extends StatelessWidget {
  const ReadingSaveButton({super.key});

  Future<void> _save(
      BuildContext context, ReadingLoggingController controller) async {
    final l10n = context.l10n;
    final result = await controller.saveReading();
    if (!context.mounted) return;
    result.fold(
      (f) =>
          AppSnackBar.showError(context, message: f.vitalMessage(l10n) ?? ''),
      (_) => AppSnackBar.showSuccess(context, message: l10n.readingSaved),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReadingLoggingController>();
    final state = controller.state;
    return AppButton(
      text: state.isSaving ? '${context.l10n.save}...' : context.l10n.save,
      onPressed: () => _save(context, controller),
      isDisabled: !state.hasChanged || state.isSaving,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      borderRadius: 12,
      height: 50,
    );
  }
}
