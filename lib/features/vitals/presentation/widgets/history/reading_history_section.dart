import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/features/vitals/presentation/widgets/history/reading_history_item.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/vitals/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import 'package:clock/clock.dart';

/// The saved readings, five per page.
class ReadingHistorySection extends StatefulWidget {
  const ReadingHistorySection({super.key});

  @override
  State<ReadingHistorySection> createState() => _ReadingHistorySectionState();
}

class _ReadingHistorySectionState extends State<ReadingHistorySection> {
  int _currentPage = 1;
  final int _pageSize = 5;

  @override
  Widget build(BuildContext context) {
    final vitals =
        context.select((ReadingLoggingController c) => c.history) ?? const [];
    if (vitals.isEmpty) return const SizedBox.shrink();

    final totalItems = vitals.length;
    final totalPages = (totalItems / _pageSize).ceil();

    if (_currentPage > totalPages && totalPages > 0) {
      _currentPage = 1;
    }

    final startIndex = (_currentPage - 1) * _pageSize;
    final displayVitals = vitals.skip(startIndex).take(_pageSize).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.titleMedium(
                    context.l10n.readingHistory,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PaginationHeaderDelegate(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPrev: () => setState(() => _currentPage--),
            onNext: () => setState(() => _currentPage++),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final vital = displayVitals[index];
                final date = vital.recordedAt ?? clock.now();
                final dateStr = AppDateFormats.dayDateMonth.format(date);
                final vitalName = vital.isBloodPressure
                    ? context.l10n.bpShort
                    : context.l10n.sugar;

                return ReadingHistoryItem(
                  date: dateStr,
                  vitalName: vitalName,
                  vitalValue: "${vital.value} ${vital.unit}",
                  severity: vital.grade,
                );
              },
              childCount: displayVitals.length,
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 120),
          sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
      ],
    );
  }
}

class _PaginationHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  _PaginationHeaderDelegate({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFFF7ED),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.bodyMedium(
            context.l10n.pageOfTotal(currentPage, totalPages),
            color: const Color(0xFF575F69),
            fontWeight: FontWeight.w600,
          ),
          Row(
            children: [
              _PageButton(
                  icon: Icons.chevron_left,
                  onPressed: currentPage > 1 ? onPrev : null),
              const SizedBox(width: 8),
              _PageButton(
                  icon: Icons.chevron_right,
                  onPressed: currentPage < totalPages ? onNext : null),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant _PaginationHeaderDelegate oldDelegate) {
    return oldDelegate.currentPage != currentPage ||
        oldDelegate.totalPages != totalPages;
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.orange300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
            icon: Icon(icon, color: AppColors.orange300), onPressed: onPressed),
      );
}
