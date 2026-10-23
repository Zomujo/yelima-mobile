import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:provider/provider.dart';
import 'package:yelima/shared/widgets/layout/app_shimmer.dart';
import '../displays/reading_display_card.dart';
import '../displays/blood_pressure_display.dart';
import '../displays/sugar_display.dart';
import '../pickers/value_wheel_picker_bottom_sheet.dart';
import '../../controllers/reading_logging_controller.dart';
import '../../../domain/reading_limits.dart';

class InteractiveReadingCard extends StatelessWidget {
  const InteractiveReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingLoggingController>(
      builder: (context, controller, child) {
        if (controller.state.isInitializing) {
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
              if (controller.state.selectedTypeIndex == 0) {
                ValueWheelPickerBottomSheet.showDual(
                  context,
                  title: context.l10n.bpPickerTitle,
                  initialValue1: controller.state.systolic,
                  initialValue2: controller.state.diastolic,
                  minValue1: ReadingLimits.systolicMin,
                  maxValue1: ReadingLimits.systolicMax,
                  minValue2: ReadingLimits.diastolicMin,
                  maxValue2: ReadingLimits.diastolicMax,
                  onChanged: (sys, dia) {
                    controller.setBloodPressure(sys, dia);
                  },
                );
              } else {
                ValueWheelPickerBottomSheet.showSingle(
                  context,
                  title: context.l10n.sugarPickerTitle,
                  initialValue: controller.state.sugarLevel,
                  minValue: ReadingLimits.sugarMin,
                  maxValue: ReadingLimits.sugarMax,
                  step: 0.1,
                  onChanged: (val) {
                    controller.setSugarLevel(val);
                  },
                );
              }
            },
            child: controller.state.selectedTypeIndex == 0
                ? BloodPressureDisplay(
                    systolic: controller.state.systolic.toString(),
                    diastolic: controller.state.diastolic.toString(),
                  )
                : SugarDisplay(
                    sugarLevel: controller.state.sugarLevel.toStringAsFixed(1),
                  ),
          ),
        );
      },
    );
  }
}
