import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../controllers/add_medication_form_controller.dart';

class MedicationDosingSchedule extends StatelessWidget {
  const MedicationDosingSchedule({super.key});

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onSelected) async {
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
          color: isEnabled ? const Color(0xFFFDBA74) : const Color(0xFFE2E8F0),
          width: isEnabled ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: AppText.titleMedium(label, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            value: isEnabled,
            onChanged: onToggle,
            activeColor: const Color(0xFFFDBA74),
            inactiveThumbColor: const Color(0xFFFDBA74),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF94A3B8), size: 18),
                            const SizedBox(width: 8),
                            AppText.bodyMedium(_formatTime(time), fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
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
                          icon: const Icon(Icons.remove, size: 18, color: Color(0xFF64748B)),
                          onPressed: quantity > 1 ? () => onQuantityChange(quantity - 1) : null,
                        ),
                        AppText.bodyLarge(quantity.toString(), fontWeight: FontWeight.bold),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18, color: Color(0xFF64748B)),
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
            const AppText.titleLarge('Dosing Schedule', fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            const SizedBox(height: 8),
            const AppText.bodyMedium('Select when and how much to take.', color: Color(0xFF64748B)),
            const SizedBox(height: 24),
            _buildDosageToggle(
              context,
              label: 'Morning',
              isEnabled: controller.state.hasMorning,
              time: controller.state.morningTime,
              quantity: controller.state.morningQuantity,
              onToggle: (v) => controller.updateMorning(v),
              onTimeSelect: () => _selectTime(context, controller.state.morningTime, (t) => controller.updateMorning(controller.state.hasMorning, t)),
              onQuantityChange: (v) => controller.updateMorning(controller.state.hasMorning, controller.state.morningTime, v),
            ),
            const SizedBox(height: 16),
            _buildDosageToggle(
              context,
              label: 'Afternoon',
              isEnabled: controller.state.hasAfternoon,
              time: controller.state.afternoonTime,
              quantity: controller.state.afternoonQuantity,
              onToggle: (v) => controller.updateAfternoon(v),
              onTimeSelect: () => _selectTime(context, controller.state.afternoonTime, (t) => controller.updateAfternoon(controller.state.hasAfternoon, t)),
              onQuantityChange: (v) => controller.updateAfternoon(controller.state.hasAfternoon, controller.state.afternoonTime, v),
            ),
            const SizedBox(height: 16),
            _buildDosageToggle(
              context,
              label: 'Evening',
              isEnabled: controller.state.hasEvening,
              time: controller.state.eveningTime,
              quantity: controller.state.eveningQuantity,
              onToggle: (v) => controller.updateEvening(v),
              onTimeSelect: () => _selectTime(context, controller.state.eveningTime, (t) => controller.updateEvening(controller.state.hasEvening, t)),
              onQuantityChange: (v) => controller.updateEvening(controller.state.hasEvening, controller.state.eveningTime, v),
            ),
          ],
        );
      },
    );
  }
}
