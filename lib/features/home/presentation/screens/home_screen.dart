import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import 'package:yelima/features/appointment/presentation/controllers/appointment_controller.dart';
import 'package:yelima/features/home/presentation/controllers/home_metrics_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/sections/home_metrics_section.dart';
import '../widgets/sections/home_next_step_section.dart';
import '../widgets/sections/home_upcoming_visits_section.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/utils/app_tutorial_service.dart';
import 'package:clock/clock.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/layout/pending_changes_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Created once so the badge doesn't resubscribe on every rebuild.
  final _sync = sl<MutationSyncManager>();
  late final _waiting = _sync.watchWaitingCount();
  late final _failed = _sync.watchFailedCount();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppointmentController>().fetchNearestAppointment();
        context.read<HomeMetricsController>().fetchMetrics();
        AppTutorialService.showHomeTutorial(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>().userEntity;
    final String greetingName = user?.firstName ?? '';
    final String formattedDate =
        AppDateFormats.dayDateMonth.format(clock.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding:
                EdgeInsets.only(bottom: AppSizes.bottomNavClearance(context)),
            children: [
              HomeHeader(
                date: formattedDate,
                greeting: greetingName.isNotEmpty
                    ? context.l10n.welcomeName(greetingName)
                    : context.l10n.welcome,
                status: PendingChangesBadge(
                  waiting: _waiting,
                  failed: _failed,
                  onTap: () => context.push(RoutePaths.unsyncedChanges),
                ),
              ),
              const HomeMetricsSection(),
              const SizedBox(height: 16),
              const HomeNextStepSection(
                topSlotWidget: HomeUpcomingVisitsSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
