import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medication_form_controller.dart';

/// A full-width dropdown of dose units.
class UnitPicker extends StatelessWidget {
  const UnitPicker({super.key, required this.value, required this.onSelected});

  final String value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 48;
    const units = MedicationFormController.units;
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.slate200),
      ),
      color: Colors.white,
      elevation: 4,
      constraints: BoxConstraints(minWidth: width, maxWidth: width),
      itemBuilder: (_) => [
        for (final unit in units) ...[
          PopupMenuItem(
            value: unit,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppText.bodyMedium(unit, color: AppColors.slate800),
          ),
          if (unit != units.last)
            const PopupMenuItem<String>(
              enabled: false,
              height: 1,
              padding: EdgeInsets.zero,
              child: Divider(height: 1, color: AppColors.slate200),
            ),
        ],
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.bodyMedium(value, color: AppColors.slate800),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}
