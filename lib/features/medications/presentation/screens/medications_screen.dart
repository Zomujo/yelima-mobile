import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/widgets/layout/back_to_home.dart';
import '../controllers/medication_controller.dart';
import '../widgets/medications_dashboard/adherence_card.dart';
import '../widgets/medications_dashboard/time_of_day_tabs.dart';
import '../widgets/medications_dashboard/todays_medications_list.dart';
import 'all_medicines_screen.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';

/// The medications tab: adherence, section tabs and today's doses.
class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  final _adherenceKey = GlobalKey();
  final _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(medicationControllerProvider.notifier).init();
      if (mounted) {
        AppTutorialService.showMedicationsTutorial(context,
            adherenceKey: _adherenceKey, listKey: _listKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackToHome(
      child: Scaffold(
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
                    Consumer(builder: (context, ref, child) {
                      final adherence = ref.watch(medicationControllerProvider
                          .select((s) => s.adherence));
                      return SizedBox(
                        key: _adherenceKey,
                        width: double.infinity,
                        child: ShimmerLoading(
                          isLoading: adherence == null,
                          shimmer: const AppShimmer.box(
                              width: double.infinity, height: 150),
                          child: AdherenceCard(adherence: adherence),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    // The tutorial needs a box to point at; the list below is a sliver.
                    Column(
                      key: _listKey,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.titleLarge(
                          context.l10n.todaysMedications,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate800,
                        ),
                        const SizedBox(height: 16),
                        Consumer(builder: (context, ref, child) {
                          final state = ref.watch(medicationControllerProvider);
                          return TimeOfDayTabs(
                            selected: state.section,
                            onSelected: ref
                                .read(medicationControllerProvider.notifier)
                                .selectSection,
                            counts: state.counts,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              sliver: TodaysMedicationsList(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 60),
            ),
          ],
        ),
      ),
    );
  }
}
