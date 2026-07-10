import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:yelima/shared/widgets/layout/app_shimmer.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/features/appointment/presentation/controllers/appointment_controller.dart';
import '../next_clinic_visit_card.dart';

class HomeUpcomingVisitsSection extends StatelessWidget {
  const HomeUpcomingVisitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Consumer<AppointmentController>(
        builder: (context, controller, child) {
          if (controller.state.isNearestLoading) {
            return AppShimmer.box(
              height: 120,
              width: double.infinity,
              borderRadius: 16,
            );
          }

          if (controller.state.nearestError != null) {
            return Center(
              child:
                  AppText.bodyMedium('Error: ${controller.state.nearestError}'),
            );
          }

          final nearest = controller.state.nearestAppointment;
          if (nearest == null) {
            return const SizedBox.shrink(); // Or some empty state
          }

          final formattedDate =
              DateFormat('MMMM d').format(nearest.appointmentDate);
          final formattedTime =
              DateFormat('h:mm a').format(nearest.appointmentDate);

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
