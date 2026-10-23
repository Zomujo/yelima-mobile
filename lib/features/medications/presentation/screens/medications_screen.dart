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
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_keys.dart';

/// The medications tab: adherence, section tabs and today's doses.
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
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AllMedicinesScreen()),
                        ),
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
                            context.l10n.addMedication,
                            color: AppColors.slate800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer<MedicationController>(
                      builder: (context, controller, child) {
                    return SizedBox(
                      key: AppTutorialKeys.medicationsAdherenceKey,
                      width: double.infinity,
                      child: ShimmerLoading(
                        isLoading: controller.state.adherence == null,
                        shimmer:
                            AppShimmer.box(width: double.infinity, height: 150),
                        child: AdherenceCard(
                          adherence: controller.state.adherence,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  AppText.titleLarge(
                    context.l10n.todaysMedications,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                  const SizedBox(height: 16),
                  Consumer<MedicationController>(
                      builder: (context, controller, child) {
                    return TimeOfDayTabs(
                      selected: controller.state.section,
                      onSelected: controller.selectSection,
                      counts: controller.state.counts,
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
