import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/vitals/domain/entities/vital_history_entity.dart';
import 'package:yelima/features/vitals/domain/vital_severity_thresholds.dart';

void main() {
  test(
      'every grade the server can send has a display level (none show as unknown)',
      () {
    const serverLabels = [
      VitalSeverityThresholds.normal,
      VitalSeverityThresholds.elevated,
      VitalSeverityThresholds.hypertensive,
      VitalSeverityThresholds.hypertensiveCrisis,
      VitalSeverityThresholds.hypotensive,
      VitalSeverityThresholds.severeHypotension,
      VitalSeverityThresholds.low,
      VitalSeverityThresholds.criticallyLow,
      VitalSeverityThresholds.high,
      VitalSeverityThresholds.criticallyHigh,
      'critical',
    ];
    for (final label in serverLabels) {
      expect(VitalSeverityExt.fromString(label), isNot(VitalSeverity.unknown),
          reason: label);
    }
  });

  test('server emergencies show as the critical levels', () {
    expect(VitalSeverityExt.fromString('hypertensive_crisis'),
        VitalSeverity.critical);
    expect(
        VitalSeverityExt.fromString('critically_high'), VitalSeverity.critical);
    expect(VitalSeverityExt.fromString('severe_hypotension'),
        VitalSeverity.criticallyLow);
  });

  test('older local labels still map', () {
    expect(VitalSeverityExt.fromString('good'), VitalSeverity.normal);
    expect(VitalSeverityExt.fromString('very_high'), VitalSeverity.veryHigh);
    expect(VitalSeverityExt.fromString(null), VitalSeverity.unknown);
  });
}
