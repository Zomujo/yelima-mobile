import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/home/data/models/home_metrics_model.dart';
import 'package:yelima/features/home/domain/entities/vital_history_entity.dart';

void main() {
  VitalHistoryEntity bp(String value,
          {DateTime? at, String severity = 'normal'}) =>
      VitalHistoryEntity(
        id: value,
        vitalType: 'bloodPressure',
        value: value,
        unit: 'mmHg',
        severity: severity,
        vitalName: 'Blood Pressure',
        recordedAt: at,
      );

  VitalHistoryEntity sugar(String value, {DateTime? at}) => VitalHistoryEntity(
        id: value,
        vitalType: 'bloodSugar',
        value: value,
        unit: 'mmol/L',
        severity: 'normal',
        vitalName: 'Blood Sugar',
        recordedAt: at,
      );

  test('VIT-EC-08: shows the newest reading, whatever the row order', () {
    final metrics = HomeMetricsModel.fromVitals([
      bp('120/80', at: DateTime(2026, 10, 20)),
      bp('185/125',
          at: DateTime(2026, 10, 23), severity: 'hypertensive_crisis'),
      sugar('5.1', at: DateTime(2026, 10, 1)),
      sugar('9.0', at: DateTime(2026, 10, 22)),
    ], null);

    expect(metrics.bloodPressure, '185/125');
    expect(metrics.bpSeverity, 'hypertensive_crisis');
    expect(metrics.bloodGlucose, '9.0');
  });

  test('server rows without a time keep the server\'s newest-first order', () {
    final metrics = HomeMetricsModel.fromVitals(
        [bp('130/85'), bp('120/80'), bp('110/70')], null);

    expect(metrics.bloodPressure, '130/85');
  });

  test('a dated local reading beats undated server rows', () {
    final metrics = HomeMetricsModel.fromVitals(
        [bp('120/80'), bp('150/95', at: DateTime(2026, 10, 23))], null);

    expect(metrics.bloodPressure, '150/95');
  });

  test('no readings gives empty metrics and keeps the adherence', () {
    final metrics = HomeMetricsModel.fromVitals(const [], 0.75);

    expect(metrics.bloodPressure, isNull);
    expect(metrics.bloodGlucose, isNull);
    expect(metrics.adherenceRate, 0.75);
  });
}
