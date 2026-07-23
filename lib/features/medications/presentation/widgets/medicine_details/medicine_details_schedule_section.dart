import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/medicine_details_form_controller.dart';
import '../../../data/models/medication_detail_model.dart';
import '../../../data/models/dosing_schedule_model.dart';
import 'package:provider/provider.dart';

class MedicineDetailsScheduleSection extends StatelessWidget {
  final MedicationDetailModel data;

  const MedicineDetailsScheduleSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineDetailsFormController>(
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText.titleMedium('Dosing Schedule',
                fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            const SizedBox(height: 24),
            if (controller.state.isEditing) ...[
              _EditableDosageToggle(
                label: 'Morning',
                isEnabled: controller.state.hasMorning,
                time: controller.state.morningTime,
                quantity: controller.state.morningQuantity,
                onToggle: (v) => controller.updateMorning(v),
                onTimeSelect: () => _selectTime(
                    context,
                    controller.state.morningTime,
                    (t) => controller.updateMorning(
                        controller.state.hasMorning, t)),
                onQuantityChange: (q) => controller.updateMorning(
                    controller.state.hasMorning, null, q),
              ),
              const SizedBox(height: 16),
              _EditableDosageToggle(
                label: 'Afternoon',
                isEnabled: controller.state.hasAfternoon,
                time: controller.state.afternoonTime,
                quantity: controller.state.afternoonQuantity,
                onToggle: (v) => controller.updateAfternoon(v),
                onTimeSelect: () => _selectTime(
                    context,
                    controller.state.afternoonTime,
                    (t) => controller.updateAfternoon(
                        controller.state.hasAfternoon, t)),
                onQuantityChange: (q) => controller.updateAfternoon(
                    controller.state.hasAfternoon, null, q),
              ),
              const SizedBox(height: 16),
              _EditableDosageToggle(
                label: 'Evening',
                isEnabled: controller.state.hasEvening,
                time: controller.state.eveningTime,
                quantity: controller.state.eveningQuantity,
                onToggle: (v) => controller.updateEvening(v),
                onTimeSelect: () => _selectTime(
                    context,
                    controller.state.eveningTime,
                    (t) => controller.updateEvening(
                        controller.state.hasEvening, t)),
                onQuantityChange: (q) => controller.updateEvening(
                    controller.state.hasEvening, null, q),
              ),
            ] else ...[
              if (data.morning != null)
                _ReadOnlyDosageTime(
                    timeOfDay: 'Morning', schedule: data.morning!),
              if (data.afternoon != null) ...[
                const SizedBox(height: 24),
                _ReadOnlyDosageTime(
                    timeOfDay: 'Afternoon', schedule: data.afternoon!),
              ],
              if (data.evening != null) ...[
                const SizedBox(height: 24),
                _ReadOnlyDosageTime(
                    timeOfDay: 'Evening', schedule: data.evening!),
              ],
              if (data.morning == null &&
                  data.afternoon == null &&
                  data.evening == null)
                const AppText.bodyMedium('No schedule configured.',
                    color: Color(0xFF94A3B8)),
            ],
          ],
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFDBA74),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onSelected(picked);
  }
}

class _ReadOnlyDosageTime extends StatelessWidget {
  final String timeOfDay;
  final DosingScheduleModel schedule;

  const _ReadOnlyDosageTime({
    required this.timeOfDay,
    required this.schedule,
  });

  String _formatScheduleTime(ScheduleTimeModel time) {
    final hour = time.hour.toString();
    final minute = time.minutes.toString().padLeft(2, '0');
    final period = time.timeDesignators.toUpperCase();
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodyLarge(timeOfDay,
                fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            const SizedBox(height: 8),
            AppText.bodyMedium(
                '${_formatScheduleTime(schedule.time)} | ${schedule.quantity.value} ${schedule.quantity.unit}(s)',
                color: const Color(0xFF475569)),
          ],
        ),
      ],
    );
  }
}

class _EditableDosageToggle extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final TimeOfDay time;
  final int quantity;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeSelect;
  final ValueChanged<int> onQuantityChange;

  const _EditableDosageToggle({
    required this.label,
    required this.isEnabled,
    required this.time,
    required this.quantity,
    required this.onToggle,
    required this.onTimeSelect,
    required this.onQuantityChange,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                isEnabled ? const Color(0xFFFDBA74) : const Color(0xFFE2E8F0),
            width: isEnabled ? 2 : 1),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: AppText.titleMedium(label,
                fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            value: isEnabled,
            onChanged: onToggle,
            activeColor: const Color(0xFFFDBA74),
            inactiveThumbColor: const Color(0xFFFDBA74),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          if (isEnabled) ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Color(0xFF94A3B8), size: 18),
                            const SizedBox(width: 8),
                            AppText.bodyMedium(_formatTime(time),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove,
                              size: 18, color: Color(0xFF64748B)),
                          onPressed: quantity > 1
                              ? () => onQuantityChange(quantity - 1)
                              : null,
                        ),
                        AppText.bodyLarge(quantity.toString(),
                            fontWeight: FontWeight.bold),
                        IconButton(
                          icon: const Icon(Icons.add,
                              size: 18, color: Color(0xFF64748B)),
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
}
