import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

/// Points `tz.local` at the device's time zone so reminders fire at local time; keeps UTC if that fails.
Future<void> configureLocalTimeZone(
    {Future<String> Function()? deviceZone}) async {
  try {
    final name = await (deviceZone ?? FlutterTimezone.getLocalTimezone)();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (_) {
    // Unknown zone or no plugin: stay on the current location (UTC by default).
  }
}

/// Next local occurrence of [time], today if it hasn't passed yet, otherwise tomorrow.
tz.TZDateTime nextDailyTime(TimeOfDay time, {tz.TZDateTime? now}) {
  final current = now ?? tz.TZDateTime.now(tz.local);
  tz.TZDateTime on(int dayOffset) => tz.TZDateTime(tz.local, current.year,
      current.month, current.day + dayOffset, time.hour, time.minute);
  final today = on(0);
  // Build tomorrow by calendar day, not +24h, so DST changes keep the wall-clock time.
  return today.isBefore(current) ? on(1) : today;
}
