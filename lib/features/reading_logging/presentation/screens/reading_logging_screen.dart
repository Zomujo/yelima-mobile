import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../controllers/reading_logging_controller.dart';
import 'package:yelima/features/home/domain/entities/vital_history_entity.dart';
import '../../../../injection_container.dart';
import '../widgets/form/reading_logging_form.dart';
import '../widgets/history/reading_history_section.dart';
import '../../../../shared/widgets/forms/unsaved_changes_guard.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../core/utils/app_tutorial_service.dart';

class ReadingLoggingScreen extends StatelessWidget {
  const ReadingLoggingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReadingLoggingController>(
      create: _initializeController,
      child: const _ReadingLoggingView(),
    );
  }

  ReadingLoggingController _initializeController(BuildContext context) {
    return sl<ReadingLoggingController>()..init();
  }
}

class _ReadingLoggingView extends StatefulWidget {
  const _ReadingLoggingView();

  @override
  State<_ReadingLoggingView> createState() => _ReadingLoggingViewState();
}

class _ReadingLoggingViewState extends State<_ReadingLoggingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppTutorialService.showLogReadingTutorial(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: context.l10n.logReading,
              automaticallyImplyLeading: false,
            ),
            Expanded(
              child: UnsavedChangesGuard(
                hasUnsavedChanges: () =>
                    context.read<ReadingLoggingController>().state.hasChanged,
                child: StreamBuilder<List<VitalHistoryEntity>>(
                  stream: context.read<ReadingLoggingController>().vitalHistoriesStream,
                  builder: (context, snapshot) {
                    final allVitals =
                        List<VitalHistoryEntity>.from(snapshot.data ?? []);
                    final hasHistory = allVitals.isNotEmpty;

                    // No history: simple non-scrollable column
                    if (!hasHistory) {
                      return const Padding(
                        padding: EdgeInsets.only(
                            left: 24, right: 24, top: 16, bottom: 40),
                        child: SingleChildScrollView(
                          child: ReadingLoggingForm(),
                        ),
                      );
                    }

                    // Has history: scrollable layout with history section below
                    return NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          const SliverPadding(
                            padding: EdgeInsets.only(
                                left: 24, right: 24, top: 16, bottom: 40),
                            sliver: SliverToBoxAdapter(
                              child: ReadingLoggingForm(),
                            ),
                          ),
                        ];
                      },
                      body: const ReadingHistorySection(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
