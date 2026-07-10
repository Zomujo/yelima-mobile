import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/vitals_dao.dart';
import '../controllers/reading_logging_controller.dart';
import '../../../../injection_container.dart';
import '../widgets/form/reading_logging_form.dart';
import '../widgets/history/reading_history_section.dart';

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

class _ReadingLoggingView extends StatelessWidget {
  const _ReadingLoggingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Log a reading'),
            Expanded(
              child: Consumer<ReadingLoggingController>(
                builder: (context, controller, child) {
                  return StreamBuilder<List<VitalHistory>>(
                    stream: context.read<VitalsDao>().watchAllVitals(),
                    builder: (context, snapshot) {
                      final allVitals =
                          List<VitalHistory>.from(snapshot.data ?? []);
                      final hasHistory = allVitals.any((v) {
                        final type = v.vitalType.toUpperCase();
                        return !type.contains('CACHE') &&
                            !type.contains('TREND');
                      });

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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
