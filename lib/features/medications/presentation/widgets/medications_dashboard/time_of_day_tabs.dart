import 'package:flutter/material.dart';

import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_motion.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../domain/entities/medication_count.dart';
import '../../../domain/entities/medication_section.dart';

/// Morning / Afternoon / Evening tabs with a dose count on each; the
/// underline slides to the selected tab.
class TimeOfDayTabs extends StatefulWidget {
  const TimeOfDayTabs({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.counts,
  });

  final MedicationSection selected;
  final ValueChanged<MedicationSection> onSelected;
  final MedicationCount? counts;

  @override
  State<TimeOfDayTabs> createState() => _TimeOfDayTabsState();
}

class _TimeOfDayTabsState extends State<TimeOfDayTabs> {
  final _stackKey = GlobalKey();
  final _tabKeys = {for (final s in MedicationSection.values) s: GlobalKey()};

  /// Where the selected tab sits; known after the first layout.
  Rect? _selectedRect;

  @override
  void initState() {
    super.initState();
    _measureAfterLayout();
  }

  @override
  void didUpdateWidget(TimeOfDayTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    _measureAfterLayout();
  }

  void _measureAfterLayout() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final stack = _stackKey.currentContext?.findRenderObject();
        final tab =
            _tabKeys[widget.selected]!.currentContext?.findRenderObject();
        if (!mounted || stack is! RenderBox || tab is! RenderBox) return;
        final rect = tab.localToGlobal(Offset.zero, ancestor: stack) & tab.size;
        if (rect != _selectedRect) setState(() => _selectedRect = rect);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = widget.counts;
    final line = _selectedRect;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Stack(
        key: _stackKey,
        children: [
          // Tabs change width with text size and counts; re-measure then.
          NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (_) {
              _measureAfterLayout();
              return true;
            },
            child: SizeChangedLayoutNotifier(
              child: Row(
                children: [
                  for (final (section, title, count) in [
                    (MedicationSection.morning, l10n.morning, counts?.morning),
                    (
                      MedicationSection.afternoon,
                      l10n.afternoon,
                      counts?.afternoon
                    ),
                    (MedicationSection.evening, l10n.evening, counts?.evening),
                  ]) ...[
                    if (section != MedicationSection.morning)
                      const SizedBox(width: 24),
                    _Tab(
                      key: _tabKeys[section],
                      title: title,
                      count: count ?? 0,
                      isSelected: section == widget.selected,
                      onTap: () => widget.onSelected(section),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (line != null)
            AnimatedPositioned(
              left: line.left,
              top: line.bottom - _Tab.lineHeight,
              width: line.width,
              height: _Tab.lineHeight,
              duration:
                  AppMotion.duration(context, AppMotion.medium),
              curve: AppMotion.move,
              child: const ColoredBox(color: AppColors.slate500),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab(
      {super.key,
      required this.title,
      required this.count,
      required this.isSelected,
      required this.onTap});

  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  /// Room left at the bottom for the shared sliding underline.
  static const lineHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8 + lineHeight),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText.labelMedium(title,
                color: isSelected ? AppColors.slate500 : AppColors.slate400,
                fontWeight: FontWeight.w600),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: AppText.labelSmall('$count',
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
