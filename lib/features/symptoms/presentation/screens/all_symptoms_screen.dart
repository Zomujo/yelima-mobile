import 'package:flutter/material.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../core/extensions/l10n_extension.dart';
import 'package:yelima/features/symptoms/presentation/widgets/report_symptom_modal.dart';
import '../controllers/symptoms_controller.dart';
import '../widgets/symptom_card.dart';

/// Every reported symptom, grouped by day, with Add.
class AllSymptomsScreen extends ConsumerStatefulWidget {
  const AllSymptomsScreen({super.key});

  @override
  ConsumerState<AllSymptomsScreen> createState() => _AllSymptomsScreenState();
}

class _AllSymptomsScreenState extends ConsumerState<AllSymptomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(symptomsControllerProvider.notifier).fetchSymptoms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(symptomsControllerProvider);
    final symptoms = state.symptoms;
    final byDay = state.byDay;

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppText.headlineSmall(
                      context.l10n.allSymptoms,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ReportSymptomModal.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: AppText.bodyMedium(
                        context.l10n.add,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const _SymptomsShimmer()
                  : symptoms!.isEmpty
                      ? Center(
                          child: AppText.bodyMedium(
                            context.l10n.noSymptomsReported,
                            color: AppColors.textGrey,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: byDay.length,
                          itemBuilder: (context, index) {
                            final (day, symptomsList) = byDay[index];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8, top: 16),
                                  child: AppText.bodyMedium(
                                    context.l10n.dayLabel(day),
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                ...symptomsList.map((symptom) {
                                  return SymptomCard(
                                      content: symptom.description,
                                      time: AppDateFormats.timeShort
                                          .format(symptom.onsetDate.toLocal()));
                                }),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    ));
  }
}

/// Placeholder day groups while the symptoms load.
class _SymptomsShimmer extends StatelessWidget {
  const _SymptomsShimmer();

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.box(width: 100, height: 16),
              const SizedBox(height: 16),
              AppShimmer.box(height: 64, borderRadius: 16),
              const SizedBox(height: 16),
              AppShimmer.box(height: 64, borderRadius: 16),
            ],
          ),
        ),
      );
}
