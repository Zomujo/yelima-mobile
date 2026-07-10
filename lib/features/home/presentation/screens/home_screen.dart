import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/sections/home_metrics_section.dart';
import '../widgets/sections/home_next_step_section.dart';
import '../widgets/sections/home_upcoming_visits_section.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../user/presentation/controllers/user_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>().userEntity;
    final String greetingName = user?.firstName ?? '';
    final String formattedDate = DateFormat('EEEE d MMMM').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.only(bottom: AppSizes.bottomNavClearance(context)),
            children: [
              HomeHeader(
                date: formattedDate,
                greeting: greetingName.isNotEmpty ? 'Akwaaba, $greetingName' : 'Akwaaba',
              ),
              const HomeMetricsSection(),
              const SizedBox(height: 32),
              const HomeNextStepSection(),
              const SizedBox(height: 24),
              const HomeUpcomingVisitsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
