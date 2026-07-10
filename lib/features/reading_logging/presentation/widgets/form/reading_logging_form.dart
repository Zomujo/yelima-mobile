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
    return Consumer<ReadingLoggingController>(
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReadingTypeSelector(
              selectedIndex: controller.state.selectedTypeIndex,
              onTypeSelected: controller.setTypeIndex,
            ),
            const SizedBox(height: 24),
            const InteractiveReadingCard(),
            const SizedBox(height: 24),
            ReadingDaySelector(
              selectedDate: controller.state.selectedDate,
              onTap: () async {
                final DateTime? picked = await CustomCalendarModal.show(
                    context, controller.state.selectedDate);
                if (picked != null) {
                  controller.setSelectedDate(picked);
                }
              },
            ),
            const SizedBox(height: 32),
            const ReadingSaveButton(),
          ],
        );
      },
    );
  }
}
