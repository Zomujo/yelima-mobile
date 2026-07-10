import '../../domain/entities/vital_history_entity.dart';

class HomeMetricsModel extends HomeMetricsEntity {
  const HomeMetricsModel({
    super.bloodPressure,
    super.bloodGlucose,
    super.adherenceRate,
  });

  factory HomeMetricsModel.fromVitals(
      List<VitalHistoryEntity> vitals, double? adherence) {
    String? bp;
    String? bg;

    for (var vital in vitals) {
      final type = vital.vitalType.toLowerCase();
      final name = vital.vitalName.toLowerCase();

      if (bp == null && (type == 'bloodpressure' || name == 'blood pressure')) {
        bp = vital.value;
      } else if (bg == null &&
          (type == 'bloodglucose' ||
              name == 'blood glucose' ||
              type == 'bloodsugar' ||
              name == 'blood sugar')) {
        bg = vital.value;
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
    );
  }
}
