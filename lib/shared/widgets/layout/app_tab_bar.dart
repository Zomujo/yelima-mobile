import 'package:flutter/material.dart';
import 'app_text.dart';

class AppTabBar extends StatefulWidget {
  final TabController tabController;
  final List<String> tabs;
  final Function(int)? onTabChange;
  final Color? selectedBackgroundColor;
  final Color? unselectedTextColor;
  final Color? selectedTextColor;
  final bool hasBackgroundColor;

  const AppTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    this.onTabChange,
    this.selectedBackgroundColor,
    this.unselectedTextColor,
    this.selectedTextColor,
    this.hasBackgroundColor = false,
  });

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {});
    if (widget.onTabChange != null) {
      widget.onTabChange!(widget.tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double padding = 2;

    return Container(
      padding: const EdgeInsets.all(padding),
      decoration: widget.hasBackgroundColor
          ? BoxDecoration(
              color: theme.disabledColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: TabBar(
        controller: widget.tabController,
        indicator: BoxDecoration(
          color: widget.selectedBackgroundColor ??
              theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding:
            const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: List.generate(
          widget.tabs.length,
          (index) => Tab(
            child: AppText.bodyLarge(
              widget.tabs[index],
              color: widget.tabController.index == index
                  ? (widget.selectedTextColor ?? theme.primaryColor)
                  : (widget.unselectedTextColor ??
                      theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.5)),
              textAlign: TextAlign.center,
              fontWeight: widget.tabController.index == index
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class AppUnderlineTabBar extends StatefulWidget {
  final TabController tabController;
  final List<String> tabs;
  final Function(int)? onTabChange;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final Color? indicatorColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry? labelPadding;
  final bool isScrollable;
  final double? insetPadding;
  final TabAlignment? tabAlignment;
  final Map<int, bool>? badges;

  const AppUnderlineTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    this.onTabChange,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.labelPadding,
    this.isScrollable = false,
    this.insetPadding,
    this.tabAlignment,
    this.badges,
  });

  @override
  State<AppUnderlineTabBar> createState() => _AppUnderlineTabBarState();
}

class _AppUnderlineTabBarState extends State<AppUnderlineTabBar> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {});
    if (widget.onTabChange != null) {
      widget.onTabChange!(widget.tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      controller: widget.tabController,
      isScrollable: widget.isScrollable,
      tabAlignment: widget.tabAlignment,
      indicatorWeight: widget.indicatorWeight,
      indicatorColor: widget.indicatorColor ?? theme.primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: widget.labelPadding ?? const EdgeInsets.only(right: 16),
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      dividerColor: widget.unselectedTextColor?.withValues(alpha: 0.2) ??
          theme.dividerColor,
      dividerHeight: 1,
      tabs: List.generate(
        widget.tabs.length,
        (index) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.bodyLarge(
                widget.tabs[index],
                color: widget.tabController.index == index
                    ? (widget.selectedTextColor ??
                        theme.textTheme.bodyLarge?.color)
                    : (widget.unselectedTextColor ??
                        theme.textTheme.bodyLarge?.color
                            ?.withValues(alpha: 0.5)),
                textAlign: TextAlign.center,
                fontWeight: widget.tabController.index == index
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
              if (widget.badges?[index] ?? false) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
