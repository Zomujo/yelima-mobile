import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_header.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/features/vitals/domain/repositories/vitals_repository.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/reading_logging_form.dart';
import 'package:yelima/features/vitals/presentation/widgets/history/reading_history_section.dart';
import 'package:yelima/shared/widgets/forms/unsaved_changes_guard.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';

/// Logs a blood pressure or blood sugar reading and lists earlier ones.
class ReadingLoggingScreen extends StatelessWidget {
  const ReadingLoggingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReadingLoggingController>(
      create: (context) =>
          ReadingLoggingController(repository: context.read<VitalsRepository>())
            ..init(),
      child: const _ReadingLoggingView(),
    );
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
                child: Builder(
                  builder: (context) {
                    final hasHistory = context.select(
                        (ReadingLoggingController c) =>
                            c.history?.isNotEmpty ?? false);
                    if (!hasHistory) {
                      return const Padding(
                        padding: EdgeInsets.only(
                            left: 24, right: 24, top: 16, bottom: 40),
                        child: SingleChildScrollView(
                          child: ReadingLoggingForm(),
                        ),
                      );
                    }

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
