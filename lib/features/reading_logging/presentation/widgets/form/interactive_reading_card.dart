import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../displays/reading_display_card.dart';
import '../displays/blood_pressure_display.dart';
import '../displays/sugar_display.dart';
import '../pickers/value_wheel_picker_bottom_sheet.dart';
import '../../controllers/reading_logging_controller.dart';

class InteractiveReadingCard extends StatelessWidget {
  const InteractiveReadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingLoggingController>(
      builder: (context, controller, child) {
        return ReadingDisplayCard(
          child: InkWell(
            onTap: () {
              if (controller.state.selectedTypeIndex == 0) {
                ValueWheelPickerBottomSheet.showDual(
                  context,
                  title: 'Blood Pressure (mmHg)',
                  initialValue1: controller.state.systolic,
                  initialValue2: controller.state.diastolic,
                  minValue1: 60,
                  maxValue1: 250,
                  minValue2: 40,
                  maxValue2: 150,
                  onChanged: (sys, dia) {
                    controller.setBloodPressure(sys, dia);
                  },
                );
              } else {
                ValueWheelPickerBottomSheet.showSingle(
                  context,
                  title: 'Blood Glucose (mmol/L)',
                  initialValue: controller.state.sugarLevel,
                  minValue: 1.0,
                  maxValue: 33.3,
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
