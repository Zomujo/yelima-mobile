import 'dart:ui' show FrameTiming;

import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/core/services/frame_watcher.dart';

/// A frame that took [buildMs] to build and [rasterMs] to draw.
FrameTiming _frame(int buildMs, int rasterMs) {
  const start = 1000000;
  final built = start + buildMs * 1000, drawn = built + rasterMs * 1000;
  return FrameTiming(
    vsyncStart: start,
    buildStart: start,
    buildFinish: built,
    rasterStart: built,
    rasterFinish: drawn,
    rasterFinishWallTime: drawn,
  );
}

void main() {
  test('sums up frame times and counts frames over budget', () {
    final frames = [for (var i = 0; i < 9; i++) _frame(4, 6), _frame(20, 30)];
    expect(
      FrameWatcher.summarise(frames),
      'frames=10 build p90=20.0 max=20.0 raster p90=30.0 max=30.0 janky=1',
    );
  });

  test('is off in normal builds', () {
    expect(FrameWatcher.enabled, isFalse);
  });
}
