/// The backend's severity labels (`determineSeverity` in dnh-server).
abstract final class VitalSeverityThresholds {
  static const normal = 'normal';
  static const elevated = 'elevated';
  static const hypertensive = 'hypertensive';
  static const hypertensiveCrisis = 'hypertensive_crisis';
  static const hypotensive = 'hypotensive';
  static const severeHypotension = 'severe_hypotension';
  static const low = 'low';
  static const criticallyLow = 'critically_low';
  static const high = 'high';
  static const criticallyHigh = 'critically_high';

  /// Labels the backend treats as an emergency (`CRITICAL_VITAL_SEVERITIES`).
  static const critical = {
    'critical',
    hypertensiveCrisis,
    severeHypotension,
    criticallyLow,
    criticallyHigh,
  };
}

/// One cutoff: the reading's [field] is at least [gte], or below [lt].
class SeverityCondition {
  const SeverityCondition(this.field, {this.gte, this.lt});

  final String field;
  final num? gte;
  final num? lt;

  /// Whether the cutoff holds for [values] (`systolic`, `diastolic` or `value`).
  bool holds(Map<String, num> values) {
    final x = values[field];
    if (x == null) return false;
    return (gte != null && x >= gte!) || (lt != null && x < lt!);
  }

  factory SeverityCondition.fromJson(Map<String, dynamic> json) =>
      SeverityCondition(json['field'] as String,
          gte: json['gte'] as num?, lt: json['lt'] as num?);
}

/// A label that applies when any of its conditions holds; with none, it always applies.
class SeverityRule {
  const SeverityRule(this.label, [this.any = const []]);

  final String label;
  final List<SeverityCondition> any;

  bool matches(Map<String, num> values) =>
      any.isEmpty || any.any((c) => c.holds(values));

  factory SeverityRule.fromJson(Map<String, dynamic> json) => SeverityRule(
        json['label'] as String,
        [
          for (final c in json['any'] as List? ?? const [])
            SeverityCondition.fromJson(c as Map<String, dynamic>)
        ],
      );
}

/// The server's grading table (`GET /client/severity-thresholds`); the first matching rule wins.
class SeverityRules {
  const SeverityRules({
    required this.version,
    required this.bloodPressureRules,
    required this.bloodSugarRules,
    this.defaultLabel = VitalSeverityThresholds.normal,
  });

  /// A hash of the rules: compare for equality only.
  final String version;
  final List<SeverityRule> bloodPressureRules;
  final List<SeverityRule> bloodSugarRules;
  final String defaultLabel;

  /// Grades a blood pressure reading in mmHg.
  String bloodPressure(num systolic, num diastolic) => _grade(
      bloodPressureRules, {'systolic': systolic, 'diastolic': diastolic});

  /// Grades a blood sugar reading in mmol/L. The server ignores the subtype.
  String bloodSugar(double mmolPerLitre) =>
      _grade(bloodSugarRules, {'value': mmolPerLitre});

  String _grade(List<SeverityRule> rules, Map<String, num> values) {
    for (final rule in rules) {
      if (rule.matches(values)) return rule.label;
    }
    return defaultLabel;
  }

  /// Reads the endpoint's `data`; throws [FormatException] if either table is missing.
  factory SeverityRules.fromJson(Map<String, dynamic> json) {
    List<SeverityRule> rules(String vital) {
      final list = (json[vital] as Map<String, dynamic>?)?['rules'] as List?;
      if (list == null || list.isEmpty) {
        throw FormatException('No $vital rules');
      }
      return [
        for (final r in list) SeverityRule.fromJson(r as Map<String, dynamic>)
      ];
    }

    return SeverityRules(
      version: json['version'] as String? ?? '',
      bloodPressureRules: rules('bloodPressure'),
      bloodSugarRules: rules('bloodSugar'),
      defaultLabel:
          json['default'] as String? ?? VitalSeverityThresholds.normal,
    );
  }

  /// The table built into the app, from dnh-server@d0cb0d034d `determineSeverity`.
  /// Used offline until the server's copy has been fetched; the tests pin every boundary.
  static const bundled = SeverityRules(
    version: 'bundled-d0cb0d0',
    bloodPressureRules: [
      SeverityRule(VitalSeverityThresholds.hypertensiveCrisis, [
        SeverityCondition('systolic', gte: 180),
        SeverityCondition('diastolic', gte: 120),
      ]),
      SeverityRule(VitalSeverityThresholds.severeHypotension, [
        SeverityCondition('systolic', lt: 80),
        SeverityCondition('diastolic', lt: 50),
      ]),
      SeverityRule(VitalSeverityThresholds.hypertensive, [
        SeverityCondition('systolic', gte: 130),
        SeverityCondition('diastolic', gte: 80),
      ]),
      SeverityRule(VitalSeverityThresholds.hypotensive, [
        SeverityCondition('systolic', lt: 90),
        SeverityCondition('diastolic', lt: 60),
      ]),
      SeverityRule(VitalSeverityThresholds.elevated,
          [SeverityCondition('systolic', gte: 120)]),
      SeverityRule(VitalSeverityThresholds.normal),
    ],
    bloodSugarRules: [
      SeverityRule(VitalSeverityThresholds.criticallyLow,
          [SeverityCondition('value', lt: 3.0)]),
      SeverityRule(
          VitalSeverityThresholds.low, [SeverityCondition('value', lt: 3.9)]),
      SeverityRule(VitalSeverityThresholds.normal,
          [SeverityCondition('value', lt: 7.3)]),
      SeverityRule(VitalSeverityThresholds.elevated,
          [SeverityCondition('value', lt: 11.1)]),
      SeverityRule(
          VitalSeverityThresholds.high, [SeverityCondition('value', lt: 13.9)]),
      SeverityRule(VitalSeverityThresholds.criticallyHigh),
    ],
  );
}
