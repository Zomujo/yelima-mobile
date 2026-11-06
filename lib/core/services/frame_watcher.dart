import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Logs how long frames take to draw, every couple of seconds while the screen
/// is changing, so janky animations show up in the device log.
///
/// Off unless built with `--dart-define=PERF_WATCH=true`; use a profile build
/// for real numbers (debug builds are much slower).
class FrameWatcher {
  FrameWatcher._();

  static const enabled = bool.fromEnvironment('PERF_WATCH');

  /// One frame's budget on a 60 Hz screen.
  static const budget = Duration(microseconds: 16667);

  static final _frames = <FrameTiming>[];

  /// Starts collecting frame timings, when enabled.
  static void start() {
    if (!enabled) return;
    SchedulerBinding.instance.addTimingsCallback(_frames.addAll);
    Timer.periodic(const Duration(seconds: 2), (_) => _report());
  }

  static void _report() {
    if (_frames.isEmpty) return;
    final summary = summarise(_frames);
    _frames.clear();
    debugPrint('PERF $summary');
  }

  /// One line with frame count, build and raster times (p90 and worst, in ms)
  /// and how many frames went over [budget].
  @visibleForTesting
  static String summarise(List<FrameTiming> frames) {
    String ms(Duration d) => (d.inMicroseconds / 1000).toStringAsFixed(1);
    Duration p90(List<Duration> all) =>
        (all..sort())[(all.length * 0.9).floor().clamp(0, all.length - 1)];
    Duration worst(List<Duration> all) => all.reduce((a, b) => a > b ? a : b);
    final build = [for (final f in frames) f.buildDuration];
    final raster = [for (final f in frames) f.rasterDuration];
    final janky = frames
        .where((f) => f.buildDuration > budget || f.rasterDuration > budget)
        .length;
    return 'frames=${frames.length} '
        'build p90=${ms(p90(build))} max=${ms(worst(build))} '
        'raster p90=${ms(p90(raster))} max=${ms(worst(raster))} '
        'janky=$janky';
  }
}
