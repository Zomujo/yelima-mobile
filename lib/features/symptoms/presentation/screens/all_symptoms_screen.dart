import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../home/presentation/widgets/report_symptom_modal.dart';
import '../controllers/symptoms_controller.dart';
import '../widgets/symptom_card.dart';

class AllSymptomsScreen extends StatefulWidget {
  const AllSymptomsScreen({super.key});

  @override
  State<AllSymptomsScreen> createState() => _AllSymptomsScreenState();
}

class _AllSymptomsScreenState extends State<AllSymptomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SymptomsController>().fetchSymptoms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SymptomsController>();
    final state = controller.state;
    final groupedSymptoms = controller.groupedSymptoms;

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AppText.headlineSmall(
                      'All Symptoms',
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
                      child: const AppText.bodyMedium(
                        'Add',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: state.isLoading && !state.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : state.symptoms.isEmpty
                      ? const Center(
                          child: AppText.bodyMedium(
                            'No symptoms reported yet.',
                            color: AppColors.textGrey,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: groupedSymptoms.keys.length,
                          itemBuilder: (context, index) {
                            final dateKey =
                                groupedSymptoms.keys.elementAt(index);
                            final symptomsList = groupedSymptoms[dateKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 8, top: 16),
                                  child: AppText.bodyMedium(
                                    dateKey,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                ...symptomsList.map((symptom) {
                                  return SymptomCard(
                                      content: symptom.description);
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
