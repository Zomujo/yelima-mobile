import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/shared/widgets/layout/app_shimmer.dart';
import 'package:yelima/features/vitals/presentation/widgets/displays/reading_display_card.dart';
import 'package:yelima/features/vitals/presentation/widgets/displays/blood_pressure_display.dart';
import 'package:yelima/features/vitals/presentation/widgets/displays/sugar_display.dart';
import 'package:yelima/features/vitals/presentation/widgets/pickers/value_wheel_picker_bottom_sheet.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/features/vitals/domain/reading_limits.dart';
import 'package:yelima/features/vitals/domain/entities/reading_form.dart';

/// The current value; tap to change it with a wheel picker.
class InteractiveReadingCard extends ConsumerWidget {
  const InteractiveReadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingLoggingControllerProvider);
    if (state.isInitializing) {
      return ReadingDisplayCard(
        child: AppShimmer.box(
          width: double.infinity,
          height: 100,
          borderRadius: 12,
        ),
      );
    }

    return ReadingDisplayCard(
      child: InkWell(
        onTap: () {
          final controller =
              ref.read(readingLoggingControllerProvider.notifier);
          if (state.kind == VitalKind.bloodPressure) {
            ValueWheelPickerBottomSheet.showDual(
              context,
              title: context.l10n.bpPickerTitle,
              initialValue1: state.systolic,
              initialValue2: state.diastolic,
              minValue1: ReadingLimits.systolicMin,
              maxValue1: ReadingLimits.systolicMax,
              minValue2: ReadingLimits.diastolicMin,
              maxValue2: ReadingLimits.diastolicMax,
              onChanged: controller.setBloodPressure,
            );
          } else {
            ValueWheelPickerBottomSheet.showSingle(
              context,
              title: context.l10n.sugarPickerTitle,
              initialValue: state.sugarLevel,
              minValue: ReadingLimits.sugarMin,
              maxValue: ReadingLimits.sugarMax,
              step: 0.1,
              onChanged: controller.setSugarLevel,
            );
          }
        },
        child: state.kind == VitalKind.bloodPressure
            ? BloodPressureDisplay(
                systolic: state.systolic.toString(),
                diastolic: state.diastolic.toString(),
              )
            : SugarDisplay(
                sugarLevel: state.sugarLevel.toStringAsFixed(1),
              ),
      ),
    );
  }
}
