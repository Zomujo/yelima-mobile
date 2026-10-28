import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/modals/app_modal.dart';
import '../../health_warning.dart';

/// Tells the patient what to do right after they save a dangerous reading.
class HealthWarningModal extends StatelessWidget {
  const HealthWarningModal({super.key, required this.warning});

  final HealthWarning warning;

  static const _red = Color(0xFFDC2626);
  static const _orange = Color(0xFFEA580C);

  /// Shows [warning] until the patient confirms they read it.
  static Future<void> show(BuildContext context, HealthWarning warning) =>
      showAppDialog(context, HealthWarningModal(warning: warning),
          barrierColor: Colors.black54);

  @override
  Widget build(BuildContext context) {
    final color = warning.isCritical ? _red : _orange;
    return ModalContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Iconsax.warning_2, color: color, size: 48),
          const SizedBox(height: 16),
          AppText.titleLarge(warning.title,
              color: color,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          AppText.bodyLarge(warning.message, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          AppButton(
            text: context.l10n.gotIt,
            backgroundColor: color,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
