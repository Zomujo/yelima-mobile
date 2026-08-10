import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reading_type_selector.dart';
import 'interactive_reading_card.dart';
import 'reading_day_selector.dart';
import 'reading_save_button.dart';
import '../../../../../shared/widgets/modals/custom_calendar_modal.dart';
import '../../../../../shared/widgets/forms/app_dropdown.dart';
import '../../controllers/reading_logging_controller.dart';
import '../../../../../core/utils/app_tutorial_keys.dart';

class ReadingLoggingForm extends StatelessWidget {
  const ReadingLoggingForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Selector<ReadingLoggingController, int>(
          selector: (context, controller) => controller.state.selectedTypeIndex,
          builder: (context, selectedTypeIndex, child) {
            return Column(
              children: [
                ReadingTypeSelector(
                  key: AppTutorialKeys.logReadingTypeKey,
                  selectedIndex: selectedTypeIndex,
                  onTypeSelected:
                      context.read<ReadingLoggingController>().setTypeIndex,
                ),
                if (selectedTypeIndex == 1) ...[
                  const SizedBox(height: 16),
                  Selector<ReadingLoggingController, String>(
                    selector: (context, controller) =>
                        controller.state.vitalSubType,
                    builder: (context, vitalSubType, child) {
                      return AppDropdown<String>(
                        value: vitalSubType,
                        hintText: 'Measurement Context',
                        items: const ['fasting', 'postprandial', 'random'],
                        itemLabelBuilder: (val) {
                          if (val == 'fasting') return 'Fasting';
                          if (val == 'postprandial') return 'Post-Meal';
                          if (val == 'random') return 'Random';
                          return val;
                        },
                        onChanged: (value) {
                          context
                              .read<ReadingLoggingController>()
                              .setVitalSubType(value);
                        },
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        InteractiveReadingCard(
          key: AppTutorialKeys.logReadingInputKey,
        ),
        const SizedBox(height: 24),
        Selector<ReadingLoggingController, DateTime>(
          selector: (context, controller) => controller.state.selectedDate,
          builder: (context, selectedDate, child) {
            return ReadingDaySelector(
              key: AppTutorialKeys.logReadingDateKey,
              selectedDate: selectedDate,
              onTap: () async {
                final controller = context.read<ReadingLoggingController>();
                final DateTime? picked =
                    await CustomCalendarModal.show(context, selectedDate);
                if (picked != null) {
                  controller.setSelectedDate(picked);
                }
              },
            );
          },
        ),
        const SizedBox(height: 32),
        ReadingSaveButton(
          key: AppTutorialKeys.logReadingSaveKey,
        ),
      ],
    );
  }
}
