import '../../domain/entities/vital_history_entity.dart';

class HomeMetricsModel extends HomeMetricsEntity {
  const HomeMetricsModel({
    super.bloodPressure,
    super.bloodGlucose,
    super.adherenceRate,
    super.bpSeverity,
    super.bgSeverity,
  });

  factory HomeMetricsModel.fromVitals(
      List<VitalHistoryEntity> vitals, double? adherence) {
    String? bp;
    String? bg;
    String? bpSev;
    String? bgSev;

    for (var vital in _newestFirst(vitals)) {
      final type = vital.vitalType.toLowerCase();
      final name = vital.vitalName.toLowerCase();

      if (bp == null && (type == 'bloodpressure' || name == 'blood pressure')) {
        bp = vital.value;
        bpSev = vital.severity;
      } else if (bg == null &&
          (type == 'bloodglucose' ||
              name == 'blood glucose' ||
              type == 'bloodsugar' ||
              name == 'blood sugar')) {
        bg = vital.value;
        bgSev = vital.severity;
      } else if (adherence == null &&
          (type.contains('adherence') || name.contains('adherence'))) {
        final cleanedStr = vital.value.replaceAll('%', '').trim();
        final parsed = double.tryParse(cleanedStr);
        if (parsed != null) {
          adherence = parsed > 1 ? parsed / 100 : parsed;
        }
      }
    }

    return HomeMetricsModel(
      bloodPressure: bp,
      bloodGlucose: bg,
      adherenceRate: adherence,
      bpSeverity: bpSev,
      bgSeverity: bgSev,
    );
  }

  /// Sorts readings newest first. Undated rows (server rows, already newest first) keep their order, after dated ones.
  static List<VitalHistoryEntity> _newestFirst(
      List<VitalHistoryEntity> vitals) {
    final indexed = vitals.indexed.toList()
      ..sort((a, b) {
        final (ta, tb) = (a.$2.recordedAt, b.$2.recordedAt);
        if (ta != null && tb != null && ta != tb) return tb.compareTo(ta);
        if ((ta == null) != (tb == null)) return ta == null ? 1 : -1;
        return a.$1.compareTo(b.$1);
      });
    return [for (final (_, v) in indexed) v];
  }
}
