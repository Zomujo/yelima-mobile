import 'package:flutter_test/flutter_test.dart';
import 'package:yelima/features/vitals/domain/vital_severity_thresholds.dart';

typedef T = VitalSeverityThresholds;

const rules = SeverityRules.bundled;

void main() {
  group('bloodPressure matches backend determineSeverity', () {
    const cases = <(int, int, String)>[
      (180, 70, T.hypertensiveCrisis),
      (110, 120, T.hypertensiveCrisis),
      (179, 119, T.hypertensive),
      (79, 70, T.severeHypotension),
      (110, 49, T.severeHypotension),
      (80, 50, T.hypotensive),
      (130, 70, T.hypertensive),
      (110, 80, T.hypertensive),
      // Hypertensive is checked before hypotensive, as on the server.
      (135, 55, T.hypertensive),
      (89, 70, T.hypotensive),
      (110, 59, T.hypotensive),
      (90, 60, T.normal),
      (120, 79, T.elevated),
      (129, 79, T.elevated),
      (119, 79, T.normal),
    ];
    for (final (sys, dia, expected) in cases) {
      test('$sys/$dia -> $expected', () {
        expect(rules.bloodPressure(sys, dia), expected);
      });
    }
  });

  group('bloodSugar matches backend determineSeverity', () {
    const cases = <(double, String)>[
      (2.9, T.criticallyLow),
      (3.0, T.low),
      (3.8, T.low),
      (3.9, T.normal),
      (7.2, T.normal),
      (7.3, T.elevated),
      (11.0, T.elevated),
      (11.1, T.high),
      (13.8, T.high),
      (13.9, T.criticallyHigh),
      (25.0, T.criticallyHigh),
    ];
    for (final (value, expected) in cases) {
      test('$value -> $expected', () {
        expect(rules.bloodSugar(value), expected);
      });
    }
  });

  test('critical set matches backend CRITICAL_VITAL_SEVERITIES', () {
    expect(T.critical, {
      'critical',
      'hypertensive_crisis',
      'severe_hypotension',
      'critically_low',
      'critically_high',
    });
  });
}
