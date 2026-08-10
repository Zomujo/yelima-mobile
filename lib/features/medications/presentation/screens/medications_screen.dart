import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../controllers/medication_controller.dart';
import '../widgets/medications_dashboard/adherence_card.dart';
import '../widgets/medications_dashboard/time_of_day_tabs.dart';
import '../widgets/medications_dashboard/todays_medications_list.dart';
import 'all_medicines_screen.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/core/utils/app_tutorial_service.dart';
import 'package:yelima/core/utils/app_tutorial_keys.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationController>().init();
      if (mounted) {
        AppTutorialService.showMedicationsTutorial(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: AppHeader(title: context.l10n.myMedications),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AllMedicinesScreen(),
                            ),
                          );
                          if (context.mounted) {
                            final medController =
                                context.read<MedicationController>();
                            medController.init();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 2),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.primary,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: AppText.labelMedium(
                            context.l10n.allMedicines,
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer<MedicationController>(
                      builder: (context, controller, child) {
                    return ShimmerLoading(
                      isLoading: controller.state.isAdherenceLoading,
                      shimmer:
                          AppShimmer.box(width: double.infinity, height: 150),
                      child: AdherenceCard(
                        key: AppTutorialKeys.medicationsAdherenceKey,
                        adherence: controller.state.adherence,
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  AppText.titleLarge(
                    context.l10n.todaysMedications,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  const SizedBox(height: 16),
                  Consumer<MedicationController>(
                      builder: (context, controller, child) {
                    return TimeOfDayTabs(
                      selectedIndex: controller.state.selectedTabIndex,
                      onTabSelected: controller.setTabIndex,
                      counts: {
                        'MORNING': controller.state.counts?.morning ?? 0,
                        'AFTERNOON': controller.state.counts?.afternoon ?? 0,
                        'EVENING': controller.state.counts?.evening ?? 0,
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: Consumer<MedicationController>(
                builder: (context, controller, child) {
              return TodaysMedicationsList(
                key: AppTutorialKeys.medicationsListKey,
                controller: controller,
              );
            }),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 60),
          ),
        ],
      ),
    );
  }
}
