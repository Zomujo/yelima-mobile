import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_header.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/features/vitals/presentation/widgets/form/reading_logging_form.dart';
import 'package:yelima/features/vitals/presentation/widgets/history/reading_history_section.dart';
import 'package:yelima/shared/widgets/forms/unsaved_changes_guard.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/features/onboarding/presentation/tutorials/app_tutorial_service.dart';

/// Logs a blood pressure or blood sugar reading and lists earlier ones.
class ReadingLoggingScreen extends ConsumerStatefulWidget {
  const ReadingLoggingScreen({super.key});

  @override
  ConsumerState<ReadingLoggingScreen> createState() =>
      _ReadingLoggingScreenState();
}

class _ReadingLoggingScreenState extends ConsumerState<ReadingLoggingScreen> {
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
                    ref.read(readingLoggingControllerProvider).hasChanged,
                child: Consumer(
                  builder: (context, ref, _) {
                    final hasHistory = ref.watch(
                        readingLoggingControllerProvider
                            .select((s) => s.history?.isNotEmpty ?? false));
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
