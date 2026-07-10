import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// Factory for a rectangular shimmer box.
  factory AppShimmer.box({
    double? width,
    double? height,
    double borderRadius = 8,
    bool enabled = true,
  }) =>
      AppShimmer(
        enabled: enabled,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      );

  /// Factory for a circular shimmer.
  factory AppShimmer.circle({
    double size = 40,
    bool enabled = true,
  }) =>
      AppShimmer(
        enabled: enabled,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = widget.baseColor ?? 
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ?? 
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: const [
                  0.1,
                  0.3,
                  0.4,
                ],
                transform: _SlidingGradientTransform(offset: _controller.value),
              ).createShader(bounds);
            },
            child: RepaintBoundary(child: widget.child),
          );
        },
      );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.offset,
  });

  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double dist = bounds.width * 2;
    return Matrix4.translationValues(-dist + (dist * offset * 2), 0, 0);
  }
}

/// A convenient wrapper to switch between a shimmer placeholder and real content.
class ShimmerLoading extends StatelessWidget {
  final bool isLoading;
  final Widget shimmer;
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.shimmer,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isLoading ? shimmer : child,
    );
  }
}
