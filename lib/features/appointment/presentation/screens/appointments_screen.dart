import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/motion/entrance.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/appointment_entity.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/appointment_controller.dart';
import '../widgets/paginated_appointment_list.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';

/// Upcoming and past appointments.
class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(appointmentControllerProvider.notifier).initialize();
      }
    });
    // Once the lists have risen into place, so the spotlight lands on them.
    Future.delayed(AppMotion.slow + AppMotion.stagger * 2, () {
      if (mounted) AppTutorialService.showAppointmentsTutorial(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: AppBar(
        backgroundColor: AppColors.globalBackground,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppText.headlineSmall(
            context.l10n.yourAppointments,
            fontWeight: FontWeight.bold,
            color: AppColors.slate800,
          ),
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(appointmentControllerProvider);
          final upcomingState = state.upcomingState;
          final pastState = state.pastState;

          return ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            children: [
              ...Entrance.staggered(playOnce: 'appointments', [
                AppText.labelLarge(
                  context.l10n.appointmentsDescription,
                  color: const Color(0xFF6F7683),
                  fontWeight: FontWeight.w200,
                ),
                _Section(
                  title: context.l10n.comingUp,
                  list: PaginatedAppointmentList(
                    key: AppTutorialKeys.appointmentListKey,
                    state: upcomingState,
                    isPast: false,
                    emptyMessage: context.l10n.noUpcomingAppointments,
                    filter: AppointmentFilter.upcoming,
                  ),
                ),
                _Section(
                  title: context.l10n.pastVisits,
                  list: PaginatedAppointmentList(
                    key: AppTutorialKeys.appointmentPastListKey,
                    state: pastState,
                    isPast: true,
                    emptyMessage: context.l10n.noPastAppointments,
                    filter: AppointmentFilter.past,
                  ),
                ),
              ]),
              SizedBox(height: AppSizes.bottomNavClearance(context)),
            ],
          );
        },
      ),
    );
  }
}

/// A list's heading over the list, with room above.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.list});

  final String title;
  final Widget list;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText.labelMedium(
              title,
              color: AppColors.textGrey,
              letterSpacing: 1.5,
            ),
            const SizedBox(height: 16),
            list,
          ],
        ),
      );
}
