import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:yelima/core/utils/time_zone.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);
  tearDown(() => tz.setLocalLocation(tz.UTC));

  test('CORE-EC-14: uses the device time zone for reminders', () async {
    await configureLocalTimeZone(deviceZone: () async => 'Africa/Lagos');

    expect(tz.local.name, 'Africa/Lagos');
  });

  test('an unknown or failing zone keeps UTC instead of crashing', () async {
    await configureLocalTimeZone(deviceZone: () async => 'Mars/Olympus');
    expect(tz.local.name, 'UTC');

    await configureLocalTimeZone(
        deviceZone: () => throw Exception('no plugin'));
    expect(tz.local.name, 'UTC');
  });

  group('nextDailyTime', () {
    test('MED-EC-01: an 08:00 reminder in Lagos fires at 08:00 Lagos time',
        () async {
      await configureLocalTimeZone(deviceZone: () async => 'Africa/Lagos');
      final now = tz.TZDateTime(tz.local, 2026, 10, 23, 7, 0);

      final next = nextDailyTime(const TimeOfDay(hour: 8, minute: 0), now: now);

      expect((next.hour, next.minute, next.day), (8, 0, 23));
      expect(next.toUtc(), DateTime.utc(2026, 10, 23, 7, 0));
    });

    test('a time already passed today moves to tomorrow', () {
      final now = tz.TZDateTime(tz.local, 2026, 10, 23, 9, 0);

      final next = nextDailyTime(const TimeOfDay(hour: 8, minute: 0), now: now);

      expect((next.day, next.hour), (24, 8));
    });

    test('keeps the wall-clock time across a DST change', () async {
      await configureLocalTimeZone(deviceZone: () async => 'Europe/London');
      // Clocks go back at 02:00 on 25 Oct 2026.
      final now = tz.TZDateTime(tz.local, 2026, 10, 24, 20, 0);

      final next = nextDailyTime(const TimeOfDay(hour: 8, minute: 0), now: now);

      expect((next.day, next.hour), (25, 8));
      expect(next.toUtc().hour, 8, reason: 'GMT after the change');
    });
  });
}
