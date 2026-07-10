import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';

class AppPopupDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final Function(T?) onChanged;
  final String Function(T)? displayText;
  final Widget? child;
  final String? buttonText;
  final bool matchParentWidth;
  final double? customWidth;
  final double? maxHeight;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsets itemPadding;
  final TextStyle? itemTextStyle;
  final TextStyle? buttonTextStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showSelectedInButton;

  const AppPopupDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = 'Select an option',
    this.displayText,
    this.child,
    this.buttonText,
    this.matchParentWidth = true,
    this.customWidth,
    this.maxHeight = 300,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.itemTextStyle,
    this.buttonTextStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.showSelectedInButton = true,
  });

  @override
  State<AppPopupDropdown<T>> createState() => _AppPopupDropdownState<T>();
}

class _AppPopupDropdownState<T> extends State<AppPopupDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _DropdownOverlay<T>(
        items: widget.items,
        onChanged: (value) {
          widget.onChanged(value);
          _removeOverlay();
        },
        displayText: widget.displayText,
        layerLink: _layerLink,
        position: position,
        buttonSize: size,
        matchParentWidth: widget.matchParentWidth,
        customWidth: widget.customWidth,
        maxHeight: widget.maxHeight ?? 300,
        backgroundColor: widget.backgroundColor ?? Theme.of(context).cardColor,
        borderColor: widget.borderColor ?? Theme.of(context).dividerColor,
        borderRadius: widget.borderRadius,
        itemPadding: widget.itemPadding,
        itemTextStyle: widget.itemTextStyle,
        onTapOutside: _removeOverlay,
        selectedValue: widget.value,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      try {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            try {
              setState(() {
                _isOpen = false;
              });
            } catch (e) {
              AppLogger.e(e.toString());
            }
          }
        });
      } catch (e) {
        AppLogger.e(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: widget.child ??
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        widget.borderColor ?? Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.prefixIcon != null) ...[
                    widget.prefixIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.showSelectedInButton && widget.value != null
                        ? (widget.displayText?.call(widget.value as T) ??
                            widget.value.toString())
                        : (widget.buttonText ?? widget.hint),
                    style: widget.buttonTextStyle ??
                        Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    widget.suffixIcon!,
                  ] else ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ],
              ),
            ),
      ),
    );
  }
}

class _DropdownOverlay<T> extends StatelessWidget {
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T)? displayText;
  final LayerLink layerLink;
  final Offset position;
  final Size buttonSize;
  final bool matchParentWidth;
  final double? customWidth;
  final double maxHeight;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets itemPadding;
  final TextStyle? itemTextStyle;
  final VoidCallback onTapOutside;
  final T? selectedValue;

  const _DropdownOverlay({
    required this.items,
    required this.onChanged,
    required this.layerLink,
    required this.position,
    required this.buttonSize,
    required this.onTapOutside,
    this.displayText,
    this.matchParentWidth = true,
    this.customWidth,
    this.maxHeight = 300,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.borderRadius = 8.0,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.itemTextStyle,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final spaceBelow = screenSize.height - (position.dy + buttonSize.height);
    final spaceAbove = position.dy;
    final bool opensUp = (spaceBelow < maxHeight && spaceAbove >= maxHeight);

    double dropdownWidth;
    if (customWidth != null) {
      dropdownWidth = customWidth!;
    } else if (matchParentWidth) {
      dropdownWidth = buttonSize.width;
    } else {
      dropdownWidth = 200;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onTapOutside,
            child: Container(color: Colors.transparent),
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: opensUp ? const Offset(0, -4) : const Offset(0, 4),
          followerAnchor: opensUp ? Alignment.bottomLeft : Alignment.topLeft,
          targetAnchor: opensUp ? Alignment.topLeft : Alignment.bottomLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.transparent,
            child: Container(
              width: dropdownWidth,
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: borderColor),
              ),
              child: items.isEmpty
                  ? Padding(
                      padding: itemPadding,
                      child: Text(
                        'No items available',
                        style: itemTextStyle ??
                            TextStyle(color: Theme.of(context).disabledColor),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = item == selectedValue;

                        return InkWell(
                          onTap: () => onChanged(item),
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: Container(
                            width: double.infinity,
                            padding: itemPadding,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withValues(alpha: 0.1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayText?.call(item) ?? item.toString(),
                                    style: itemTextStyle?.copyWith(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : null,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : null,
                                        ) ??
                                        TextStyle(
                                          fontSize: 16,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
