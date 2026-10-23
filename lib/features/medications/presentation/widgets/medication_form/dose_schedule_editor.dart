import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_section.dart';
import '../../controllers/medication_form_controller.dart';
import '../../medication_section_label.dart';

/// On/off, time and quantity for each dose section of a medication form.
class DoseScheduleEditor extends StatelessWidget {
  const DoseScheduleEditor({super.key, required this.controller});

  final MedicationFormController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        children: [
          for (final section in MedicationSection.values) ...[
            _DoseToggle(
              section: section,
              slot: controller.slots[section]!,
              onChanged: ({enabled, time, quantity}) => controller.setSlot(
                  section,
                  enabled: enabled,
                  time: time,
                  quantity: quantity),
            ),
            if (section != MedicationSection.evening)
              const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

typedef _SlotChange = void Function(
    {bool? enabled, TimeOfDay? time, int? quantity});

class _DoseToggle extends StatelessWidget {
  const _DoseToggle(
      {required this.section, required this.slot, required this.onChanged});

  final MedicationSection section;
  final DoseSlot slot;
  final _SlotChange onChanged;

  /// Keeps morning times in the AM and the other sections in the PM.
  TimeOfDay _inSection(TimeOfDay t) {
    final wantsAm = section == MedicationSection.morning;
    if (wantsAm && t.period == DayPeriod.pm) {
      return t.replacing(hour: t.hour - 12);
    }
    if (!wantsAm && t.period == DayPeriod.am) {
      return t.replacing(hour: t.hour + 12);
    }
    return t;
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: slot.time,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.orange300,
            onPrimary: Colors.white,
            onSurface: AppColors.slate800,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(time: _inSection(picked));
  }

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: AppColors.slate50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.slate200),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: slot.enabled ? AppColors.orange300 : AppColors.slate200,
          width: slot.enabled ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: AppText.titleMedium(section.label(context.l10n),
                fontWeight: FontWeight.bold, color: AppColors.slate800),
            value: slot.enabled,
            onChanged: (v) => onChanged(enabled: v),
            activeColor: AppColors.orange300,
            inactiveThumbColor: AppColors.orange300,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          if (slot.enabled) ...[
            const Divider(height: 1, color: AppColors.slate200),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: boxDecoration,
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: AppColors.slate400, size: 18),
                            const SizedBox(width: 8),
                            AppText.bodyMedium(slot.time.format(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: boxDecoration,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove,
                              size: 18, color: AppColors.slate500),
                          onPressed: slot.quantity > 1
                              ? () => onChanged(quantity: slot.quantity - 1)
                              : null,
                        ),
                        AppText.bodyLarge('${slot.quantity}',
                            fontWeight: FontWeight.bold),
                        IconButton(
                          icon: const Icon(Icons.add,
                              size: 18, color: AppColors.slate500),
                          onPressed: () =>
                              onChanged(quantity: slot.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
