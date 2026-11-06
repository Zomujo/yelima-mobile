import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

/// A grey placeholder box with a light sweeping across it while content loads.
///
/// The sweep is the box's own gradient, not a mask over a child: a mask needs
/// an off-screen pass per box on every frame, which stalls older phones when a
/// list of placeholders is showing.
class AppShimmer extends StatefulWidget {
  const AppShimmer.box({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, highlight, base],
              stops: const [0.1, 0.3, 0.4],
              transform: _SlidingGradientTransform(_controller.value),
            ),
          ),
        ),
      ),
    );
  }
}

/// Moves the gradient across the box as [offset] goes from 0 to 1.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.offset);

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
      duration: AppMotion.duration(context, AppMotion.medium),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      // Keyed on the flag so it cross-fades even when both are the same type.
      child: KeyedSubtree(
          key: ValueKey(isLoading), child: isLoading ? shimmer : child),
    );
  }
}
