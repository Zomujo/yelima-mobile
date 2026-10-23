import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/add_medication_form_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class MedicationDosingSchedule extends StatelessWidget {
  const MedicationDosingSchedule({super.key});

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onSelected,
      {bool? isAM}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.orange300,
              onPrimary: Colors.white,
              onSurface: AppColors.slate800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      TimeOfDay finalTime = picked;
      if (isAM == true && picked.period == DayPeriod.pm) {
        finalTime = TimeOfDay(hour: picked.hour - 12, minute: picked.minute);
      } else if (isAM == false && picked.period == DayPeriod.am) {
        finalTime = TimeOfDay(hour: picked.hour + 12, minute: picked.minute);
      }
      onSelected(finalTime);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildDosageToggle(
    BuildContext context, {
    required String label,
    required bool isEnabled,
    required TimeOfDay time,
    required int quantity,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeSelect,
    required ValueChanged<int> onQuantityChange,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? AppColors.orange300 : AppColors.slate200,
          width: isEnabled ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: AppText.titleMedium(label,
                fontWeight: FontWeight.bold, color: AppColors.slate800),
            value: isEnabled,
            onChanged: onToggle,
            activeColor: AppColors.orange300,
            inactiveThumbColor: AppColors.orange300,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          if (isEnabled) ...[
            const Divider(height: 1, color: AppColors.slate200),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onTimeSelect,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: AppColors.slate400, size: 18),
                            const SizedBox(width: 8),
                            AppText.bodyMedium(_formatTime(time),
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate800),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove,
                              size: 18, color: AppColors.slate500),
                          onPressed: quantity > 1
                              ? () => onQuantityChange(quantity - 1)
                              : null,
                        ),
                        AppText.bodyLarge(quantity.toString(),
                            fontWeight: FontWeight.bold),
                        IconButton(
                          icon: const Icon(Icons.add,
                              size: 18, color: AppColors.slate500),
                          onPressed: () => onQuantityChange(quantity + 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddMedicationFormController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.titleLarge(context.l10n.dosingSchedule,
                fontWeight: FontWeight.bold, color: AppColors.slate800),
            const SizedBox(height: 8),
            AppText.bodyMedium(context.l10n.selectWhenAndHowMuch,
                color: AppColors.slate500),
            const SizedBox(height: 24),
            _buildDosageToggle(
              context,
              label: context.l10n.morningLabel,
              isEnabled: controller.state.hasMorning,
              time: controller.state.morningTime,
              quantity: controller.state.morningQuantity,
              onToggle: (v) => controller.updateMorning(v),
              onTimeSelect: () => _selectTime(
                  context,
                  controller.state.morningTime,
                  (t) =>
                      controller.updateMorning(controller.state.hasMorning, t),
                  isAM: true),
              onQuantityChange: (v) => controller.updateMorning(
                  controller.state.hasMorning, controller.state.morningTime, v),
            ),
            const SizedBox(height: 16),
            _buildDosageToggle(
              context,
              label: context.l10n.afternoonLabel,
              isEnabled: controller.state.hasAfternoon,
              time: controller.state.afternoonTime,
              quantity: controller.state.afternoonQuantity,
              onToggle: (v) => controller.updateAfternoon(v),
              onTimeSelect: () => _selectTime(
                  context,
                  controller.state.afternoonTime,
                  (t) => controller.updateAfternoon(
                      controller.state.hasAfternoon, t),
                  isAM: false),
              onQuantityChange: (v) => controller.updateAfternoon(
                  controller.state.hasAfternoon,
                  controller.state.afternoonTime,
                  v),
            ),
            const SizedBox(height: 16),
            _buildDosageToggle(
              context,
              label: context.l10n.eveningLabel,
              isEnabled: controller.state.hasEvening,
              time: controller.state.eveningTime,
              quantity: controller.state.eveningQuantity,
              onToggle: (v) => controller.updateEvening(v),
              onTimeSelect: () => _selectTime(
                  context,
                  controller.state.eveningTime,
                  (t) =>
                      controller.updateEvening(controller.state.hasEvening, t),
                  isAM: false),
              onQuantityChange: (v) => controller.updateEvening(
                  controller.state.hasEvening, controller.state.eveningTime, v),
            ),
          ],
        );
      },
    );
  }
}
