import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../widgets/request_appointment_modal.dart';
import '../../../../core/constants/app_sizes.dart';

import 'package:provider/provider.dart';
import '../controllers/appointment_controller.dart';
import '../widgets/paginated_appointment_list.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: AppBar(
        backgroundColor: AppColors.globalBackground,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: AppText.headlineSmall(
            'Your appointments',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
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
              const AppText.labelLarge(
                'The clinic books these for you. You can ask for a new one.',
                color: Color(0xFF6F7683),
                fontWeight: FontWeight.w200,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Ask for an appointment',
                prefixIcon:
                    const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: () => RequestAppointmentModal.show(context),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                borderRadius: 24,
              ),
              const SizedBox(height: 32),
              const AppText.labelMedium(
                'COMING UP',
                color: AppColors.textGrey,
                letterSpacing: 1.5,
              ),
              const SizedBox(height: 16),
              PaginatedAppointmentList(
                state: upcomingState,
                isPast: false,
                emptyMessage: 'No upcoming appointments.',
                filter: 'upcoming',
                controller: controller,
              ),
              const SizedBox(height: 32),
              const AppText.labelMedium(
                'PAST VISITS',
                color: AppColors.textGrey,
                letterSpacing: 1.5,
              ),
              const SizedBox(height: 16),
              PaginatedAppointmentList(
                state: pastState,
                isPast: true,
                emptyMessage: 'No past appointments.',
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
