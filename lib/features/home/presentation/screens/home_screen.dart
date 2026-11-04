import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import 'package:yelima/features/appointment/presentation/controllers/appointment_controller.dart';
import 'package:yelima/features/home/presentation/controllers/home_metrics_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/sections/home_metrics_section.dart';
import '../widgets/sections/home_next_step_section.dart';
import '../widgets/sections/home_upcoming_visits_section.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../user/user_providers.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';
import 'package:clock/clock.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/core_providers.dart';
import '../../../../shared/widgets/layout/pending_changes_badge.dart';

/// The home tab: greeting, metrics, next step and upcoming visits.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Created once so the badge doesn't resubscribe on every rebuild.
  late final _sync = ref.read(mutationSyncManagerProvider);
  late final _waiting = _sync.watchWaitingCount();
  late final _failed = _sync.watchFailedCount();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(appointmentControllerProvider.notifier)
            .fetchNearestAppointment();
        ref.read(homeMetricsControllerProvider.notifier).fetchMetrics();
        AppTutorialService.showHomeTutorial(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider).userEntity;
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
