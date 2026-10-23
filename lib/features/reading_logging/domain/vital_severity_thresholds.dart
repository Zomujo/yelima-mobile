/// Grades readings with the backend's exact labels and cutoffs, so offline
/// readings match what the server will store.
///
/// Copied from dnh-server@d0cb0d034d
/// `src/features/vital-histories/vital-histories.service.ts` `determineSeverity`.
/// Change it only together with the backend; the tests pin every boundary.
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

  /// Grades a blood pressure reading in mmHg. Check order matches the server.
  static String bloodPressure(num systolic, num diastolic) {
    if (systolic >= 180 || diastolic >= 120) return hypertensiveCrisis;
    if (systolic < 80 || diastolic < 50) return severeHypotension;
    if (systolic >= 130 || diastolic >= 80) return hypertensive;
    if (systolic < 90 || diastolic < 60) return hypotensive;
    if (systolic >= 120) return elevated;
    return normal;
  }

  /// Grades a blood sugar reading in mmol/L. The server ignores the subtype.
  static String bloodSugar(double mmolPerLitre) {
    if (mmolPerLitre < 3.0) return criticallyLow;
    if (mmolPerLitre < 3.9) return low;
    if (mmolPerLitre < 7.3) return normal;
    if (mmolPerLitre < 11.1) return elevated;
    if (mmolPerLitre < 13.9) return high;
    return criticallyHigh;
  }
}
