import 'package:flutter/widgets.dart';

/// The app's animation timings and curves: quick and calm, never bouncy.
abstract final class AppMotion {
  /// Presses, toggles, tab switches.
  static const quick = Duration(milliseconds: 150);

  /// Most state changes: colours, sizes, cross-fades.
  static const medium = Duration(milliseconds: 250);

  /// Page transitions and entrances.
  static const slow = Duration(milliseconds: 400);

  /// Gap between items of a staggered entrance.
  static const stagger = Duration(milliseconds: 60);

  /// Things arriving on screen.
  static const enter = Curves.easeOutCubic;

  /// Things leaving the screen.
  static const exit = Curves.easeInCubic;

  /// Things moving from one place to another.
  static const move = Curves.easeInOutCubic;

  /// Whether the user turned animations off in the phone's settings.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when animations are turned off.
  static Duration duration(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;

  static final _played = <String>{};

  /// True the first time [key] is asked about while the app runs, so an
  /// entrance on a tab plays once rather than on every tab switch.
  static bool firstTime(String key) => _played.add(key);
}
