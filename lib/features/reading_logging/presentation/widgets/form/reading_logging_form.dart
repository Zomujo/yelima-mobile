import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reading_type_selector.dart';
import 'interactive_reading_card.dart';
import 'reading_day_selector.dart';
import 'reading_save_button.dart';
import '../../../../../shared/widgets/modals/custom_calendar_modal.dart';
import '../../controllers/reading_logging_controller.dart';

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
            return ReadingTypeSelector(
              selectedIndex: selectedTypeIndex,
              onTypeSelected:
                  context.read<ReadingLoggingController>().setTypeIndex,
            );
          },
        ),
        const SizedBox(height: 24),
        const InteractiveReadingCard(),
        const SizedBox(height: 24),
        Selector<ReadingLoggingController, DateTime>(
          selector: (context, controller) => controller.state.selectedDate,
          builder: (context, selectedDate, child) {
            return ReadingDaySelector(
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
        const ReadingSaveButton(),
      ],
    );
  }
}
