import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:provider/provider.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/features/appointment/presentation/controllers/appointment_controller.dart';
import '../next_clinic_visit_card.dart';
import 'package:yelima/shared/utils/failure_message.dart';

/// Upcoming appointments on home.
class HomeUpcomingVisitsSection extends StatelessWidget {
  const HomeUpcomingVisitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Consumer<AppointmentController>(
        builder: (context, controller, child) {
          if (controller.state.nearestError != null) {
            return Center(
              child: AppText.bodyMedium(
                  controller.state.nearestError!.message(context.l10n) ?? ''),
            );
          }

          final nearest = controller.state.nearestAppointment;
          if (nearest == null) {
            return const SizedBox.shrink();
          }

          final formattedDate =
              AppDateFormats.monthDay.format(nearest.appointmentDate);
          final formattedTime =
              AppDateFormats.timeShort.format(nearest.appointmentDate);

          return NextClinicVisitCard(
            date: formattedDate,
            time: formattedTime,
            location: nearest.hostPersonnel.facility.name,
          );
        },
      ),
    );
  }
}
