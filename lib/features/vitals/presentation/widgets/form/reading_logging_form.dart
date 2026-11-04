import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/reading_type_selector.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/interactive_reading_card.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/reading_day_selector.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/reading_save_button.dart';
import 'package:yelima/shared/widgets/modals/custom_calendar_modal.dart';
import 'package:yelima/shared/widgets/forms/app_dropdown.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form.dart';

/// Type, value, day and Save for a new reading.
class ReadingLoggingForm extends ConsumerWidget {
  const ReadingLoggingForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (kind, vitalSubType, selectedDate) = ref.watch(
        readingLoggingControllerProvider
            .select((s) => (s.kind, s.vitalSubType, s.selectedDate)));
    ReadingLoggingController controller() =>
        ref.read(readingLoggingControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReadingTypeSelector(
          key: AppTutorialKeys.logReadingTypeKey,
          selectedIndex: kind.index,
          onTypeSelected: (i) => controller().setKind(VitalKind.values[i]),
        ),
        if (kind == VitalKind.bloodSugar) ...[
          const SizedBox(height: 16),
          AppDropdown<String>(
            value: vitalSubType,
            hintText: context.l10n.measurementContext,
            items: const ['fasting', 'postprandial', 'random'],
            itemLabelBuilder: (val) => switch (val) {
              'fasting' => context.l10n.fasting,
              'postprandial' => context.l10n.postMeal,
              'random' => context.l10n.randomReading,
              _ => val,
            },
            onChanged: (value) => controller().setVitalSubType(value),
          ),
        ],
        const SizedBox(height: 24),
        InteractiveReadingCard(
          key: AppTutorialKeys.logReadingInputKey,
        ),
        const SizedBox(height: 24),
        ReadingDaySelector(
          key: AppTutorialKeys.logReadingDateKey,
          selectedDate: selectedDate,
          onTap: () async {
            final notifier = controller();
            final picked =
                await CustomCalendarModal.show(context, selectedDate);
            if (picked != null) notifier.setSelectedDate(picked);
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
