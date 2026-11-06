import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/motion/entrance.dart';
import 'package:yelima/features/appointment/presentation/controllers/appointment_controller.dart';
import '../next_clinic_visit_card.dart';
import 'package:yelima/shared/utils/failure_message.dart';

/// Upcoming appointments on home.
class HomeUpcomingVisitsSection extends ConsumerWidget {
  const HomeUpcomingVisitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Builder(
        builder: (context) {
          if (state.nearestError != null) {
            return Center(
              child: AppText.bodyMedium(
                  state.nearestError!.message(context.l10n) ?? ''),
            );
          }

          final nearest = state.nearestAppointment;
          if (nearest == null) {
            return const SizedBox.shrink();
          }

          final formattedDate =
              AppDateFormats.monthDay.format(nearest.appointmentDate);
          final formattedTime =
              AppDateFormats.timeShort.format(nearest.appointmentDate);

          // Mounts when the visit loads, so it eases in then, once per run.
          return Entrance(
            index: 3,
            playOnce: 'home/visit',
            child: NextClinicVisitCard(
              date: formattedDate,
              time: formattedTime,
              location: nearest.hostPersonnel.facility.name,
            ),
          );
        },
      ),
    );
  }
}
