import 'package:flutter/material.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import 'reading_history_item.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/reading_logging/presentation/controllers/reading_logging_controller.dart';
import 'package:yelima/core/utils/app_date_formats.dart';
import 'package:yelima/features/home/domain/entities/vital_history_entity.dart';

class ReadingHistorySection extends StatefulWidget {
  const ReadingHistorySection({super.key});

  @override
  State<ReadingHistorySection> createState() => _ReadingHistorySectionState();
}

class _ReadingHistorySectionState extends State<ReadingHistorySection> {
  int _currentPage = 1;
  final int _pageSize = 5;
  late Stream<List<VitalHistoryEntity>> _vitalsStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vitalsStream = context.read<ReadingLoggingController>().vitalHistoriesStream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VitalHistoryEntity>>(
      stream: _vitalsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final vitals = List<VitalHistoryEntity>.from(snapshot.data ?? []);

        if (vitals.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort newest first
        vitals.sort((a, b) {
          final dateA = a.recordedAt ?? DateTime(2000);
          final dateB = b.recordedAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });

        final totalItems = vitals.length;
        final totalPages = (totalItems / _pageSize).ceil();

        if (_currentPage > totalPages && totalPages > 0) {
          _currentPage = 1;
        }

        final startIndex = (_currentPage - 1) * _pageSize;
        final displayVitals = vitals.skip(startIndex).take(_pageSize).toList();

        return CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.titleMedium(
                        'Reading History',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
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
                totalPages: totalPages > 0
                    ? totalPages
                    : 1, // Fallback to 1 if no items, though handled by empty state
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
                    final date = vital.recordedAt ?? DateTime.now();
                    final dateStr = AppDateFormats.dayDateMonth.format(date);
                    final typeLower = vital.vitalType.toLowerCase();
                    final isBP = typeLower == 'bloodpressure';
                    final vitalName = isBP ? 'BP' : 'Sugar';

                    return ReadingHistoryItem(
                      date: dateStr,
                      vitalName: vitalName,
                      vitalValue: "${vital.value} ${vital.unit}",
                      severity: VitalSeverityExt.fromString(vital.severity),
                    );
                  },
                  childCount: displayVitals.length,
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 120), // Bottom nav clearance
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        );
      },
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
      color: const Color(
          0xFFFFF7ED), // Match globalBackground so it looks sticky over the list
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.bodyMedium(
            'Page $currentPage of $totalPages',
            color: const Color(0xFF575F69),
            fontWeight: FontWeight.w600,
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFDBA74)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.chevron_left, color: Color(0xFFFDBA74)),
                  onPressed: currentPage > 1 ? onPrev : null,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFDBA74)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon:
                      const Icon(Icons.chevron_right, color: Color(0xFFFDBA74)),
                  onPressed: currentPage < totalPages ? onNext : null,
                ),
              ),
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
