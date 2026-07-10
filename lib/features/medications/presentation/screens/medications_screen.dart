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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: const AppHeader(title: 'My Medications'),
      body: Consumer<MedicationController>(
        builder: (context, controller, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                      child: const AppText.labelMedium(
                        'All Medicines',
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ShimmerLoading(
                isLoading: controller.state.isAdherenceLoading,
                shimmer: AppShimmer.box(width: double.infinity, height: 150),
                child: AdherenceCard(adherence: controller.state.adherence),
              ),
              const SizedBox(height: 32),
              const AppText.titleLarge(
                "Today's medications",
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(height: 16),
              TimeOfDayTabs(
                selectedIndex: controller.state.selectedTabIndex,
                onTabSelected: controller.setTabIndex,
                counts: {
                  'MORNING': controller.state.counts?.morning ?? 0,
                  'AFTERNOON': controller.state.counts?.afternoon ?? 0,
                  'EVENING': controller.state.counts?.evening ?? 0,
                },
              ),
              const SizedBox(height: 24),
              TodaysMedicationsList(controller: controller),
              const SizedBox(height: 60),
            ],
          );
        },
      ),
    );
  }
}
