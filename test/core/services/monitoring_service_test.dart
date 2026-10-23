import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/services/monitoring_service.dart';

class MockAnalytics extends Mock implements FirebaseAnalytics {}

class MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late MockAnalytics analytics;
  late MockCrashlytics crashlytics;
  late MonitoringService monitoring;

  setUp(() {
    analytics = MockAnalytics();
    crashlytics = MockCrashlytics();
    when(() => analytics.setUserId(id: any(named: 'id')))
        .thenAnswer((_) async {});
    when(() => analytics.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    when(() => crashlytics.setUserIdentifier(any())).thenAnswer((_) async {});
    when(() => crashlytics.setCustomKey(any(), any())).thenAnswer((_) async {});
    when(() => crashlytics.log(any())).thenAnswer((_) async {});
    monitoring = MonitoringService.withServices(analytics, crashlytics);
  });

  test('CORE-EC-13: a session start identifies the user by uid only', () async {
    await monitoring.onSessionStarted('uid-123');

    verify(() => analytics.setUserId(id: 'uid-123')).called(1);
    verify(() => crashlytics.setUserIdentifier('uid-123')).called(1);
    verifyNever(() => analytics.setUserProperty(
        name: 'email', value: any(named: 'value', that: isNotNull)));
    final keys =
        verify(() => crashlytics.setCustomKey(captureAny(), captureAny()))
            .captured;
    expect(keys.whereType<String>().any((v) => v.contains('@')), isFalse,
        reason: 'no email in any Crashlytics key');
  });

  test('CORE-EC-13: a session end clears the identity, including old emails',
      () async {
    await monitoring.onSessionEnded();

    verify(() => analytics.setUserId(id: null)).called(1);
    verify(() => analytics.setUserProperty(name: 'email', value: null))
        .called(1);
    verify(() => crashlytics.setUserIdentifier('')).called(1);
    verify(() => crashlytics.setCustomKey('user_email', '')).called(1);
  });
}
