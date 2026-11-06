import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/motion/entrance.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_shimmer.dart';
import '../../../../core/extensions/l10n_extension.dart';
import 'package:yelima/features/symptoms/presentation/widgets/report_symptom_modal.dart';
import '../controllers/symptoms_controller.dart';
import '../../domain/entities/symptom_entity.dart';
import '../widgets/symptom_day_group.dart';

/// Every reported symptom, grouped by day, with Add.
class AllSymptomsScreen extends ConsumerStatefulWidget {
  const AllSymptomsScreen({super.key});

  @override
  ConsumerState<AllSymptomsScreen> createState() => _AllSymptomsScreenState();
}

class _AllSymptomsScreenState extends ConsumerState<AllSymptomsScreen> {
  /// Set after the list's first frame; rows built later (by scrolling) skip the stagger.
  bool _listShown = false;

  /// The symptom just reported, which slides in at the top once.
  String? _arrivedId;

  /// Marks a new, newer symptom (a fresh report), not the server's copy of one.
  void _onSymptoms(List<SymptomEntity>? old, List<SymptomEntity>? now) {
    final (was, top) = (_newest(old), _newest(now));
    if (was != null && top != null && top.onsetDate.isAfter(was.onsetDate)) {
      _arrivedId = top.id;
    }
  }

  static SymptomEntity? _newest(List<SymptomEntity>? list) =>
      (list == null || list.isEmpty)
          ? null
          : list.reduce((a, b) => b.onsetDate.isAfter(a.onsetDate) ? b : a);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(symptomsControllerProvider.notifier).fetchSymptoms();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<SymptomEntity>?>(
        symptomsControllerProvider.select((s) => s.symptoms), _onSymptoms);
    final state = ref.watch(symptomsControllerProvider);
    final symptoms = state.symptoms;
    final byDay = state.byDay;
    if (!_listShown && byDay.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _listShown = true);
    }

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
                            final (day, list) = byDay[index];
                            return Entrance(
                              index: index,
                              enabled: !_listShown,
                              child: SymptomDayGroup(
                                  day: day,
                                  symptoms: list,
                                  arrivedId: _arrivedId),
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
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.box(width: 100, height: 16),
              SizedBox(height: 16),
              AppShimmer.box(height: 64, borderRadius: 16),
              SizedBox(height: 16),
              AppShimmer.box(height: 64, borderRadius: 16),
            ],
          ),
        ),
      );
}
