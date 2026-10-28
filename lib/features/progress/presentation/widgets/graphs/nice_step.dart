import 'dart:math';

/// A round grid step (1, 2 or 5 times a power of ten) close to [rough].
double niceStep(double rough) {
  if (rough <= 0) return 1;
  final magnitude = pow(10, (log(rough) / ln10).floor()).toDouble();
  final fraction = rough / magnitude;
  final nice = fraction <= 1
      ? 1
      : fraction <= 2
          ? 2
          : fraction <= 5
              ? 5
              : 10;
  return nice * magnitude;
}
