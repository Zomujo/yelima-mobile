import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../widgets/request_appointment_modal.dart';
import '../../../../core/constants/app_sizes.dart';

import 'package:provider/provider.dart';
import '../controllers/appointment_controller.dart';
import '../widgets/paginated_appointment_list.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/utils/app_tutorial_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showTutorial();
      }
    });
  }

  void _showTutorial() {
    AppTutorialService.showTutorial(
      context: context,
      tutorialId: 'appointments_screen_intro',
      targets: [
        AppTutorialService.createTarget(
          identify: 'appointments_list',
          key: AppTutorialService.appointmentListKey,
          title: context.l10n.tutorialAppointmentListTitle,
          description: context.l10n.tutorialAppointmentListDesc,
        ),
      ],
    );
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
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: Consumer<AppointmentController>(
        builder: (context, controller, child) {
          final upcomingState = controller.state.upcomingState;
          final pastState = controller.state.pastState;

          return ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            children: [
              AppText.labelLarge(
                context.l10n.appointmentsDescription,
                color: const Color(0xFF6F7683),
                fontWeight: FontWeight.w200,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: context.l10n.askForAppointment,
                prefixIcon:
                    const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: () => RequestAppointmentModal.show(context),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                borderRadius: 24,
              ),
              const SizedBox(height: 32),
              AppText.labelMedium(
                context.l10n.comingUp,
                color: AppColors.textGrey,
                letterSpacing: 1.5,
              ),
              const SizedBox(height: 16),
              PaginatedAppointmentList(
                key: AppTutorialService.appointmentListKey,
                state: upcomingState,
                isPast: false,
                emptyMessage: context.l10n.noUpcomingAppointments,
                filter: 'upcoming',
                controller: controller,
              ),
              const SizedBox(height: 32),
              AppText.labelMedium(
                context.l10n.pastVisits,
                color: AppColors.textGrey,
                letterSpacing: 1.5,
              ),
              const SizedBox(height: 16),
              PaginatedAppointmentList(
                state: pastState,
                isPast: true,
                emptyMessage: context.l10n.noPastAppointments,
                filter: 'past',
                controller: controller,
              ),
              SizedBox(height: AppSizes.bottomNavClearance(context)),
            ],
          );
        },
      ),
    );
  }
}
