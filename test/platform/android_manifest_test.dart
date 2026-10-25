import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('local reminders have the receiver that shows them', () {
    expect(
        manifest,
        contains(
            'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver'));
  });

  test('reminders are scheduled again after a reboot or an app update', () {
    expect(
        manifest,
        contains(
            'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver'));
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
  });

  test(
      'asks for "Alarms & reminders" instead of the alarm-clock-only permission',
      () {
    expect(manifest, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(manifest, isNot(contains('android.permission.USE_EXACT_ALARM')));
  });
}
