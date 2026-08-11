import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../home/presentation/widgets/report_symptom_modal.dart';
import '../widgets/symptom_card.dart';

class AllSymptomsScreen extends StatefulWidget {
  const AllSymptomsScreen({super.key});

  @override
  State<AllSymptomsScreen> createState() => _AllSymptomsScreenState();
}

class _AllSymptomsScreenState extends State<AllSymptomsScreen> {
  // Mock data for UI presentation
  final Map<String, List<String>> _mockSymptoms = {
    'Yesterday': [
      'I feel a slight headache after taking my medication today.',
      'I feel a slight headache after taking my BP medication today.',
    ],
    '10th July 2026': [
      'I feel a slight headache after taking my medication today. I had not taken any food yet. I took just the BP medication. I have taken a pain killer, yet I can still feel it.',
    ],
  };

  @override
  Widget build(BuildContext context) {
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _mockSymptoms.keys.length,
                itemBuilder: (context, index) {
                  final dateKey = _mockSymptoms.keys.elementAt(index);
                  final symptomsList = _mockSymptoms[dateKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 16),
                        child: AppText.bodyMedium(
                          dateKey,
                          color: AppColors.textGrey,
                        ),
                      ),
                      ...symptomsList.map((symptom) {
                        return SymptomCard(content: symptom);
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
