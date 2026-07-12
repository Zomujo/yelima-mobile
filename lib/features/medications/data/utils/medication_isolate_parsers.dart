import 'dart:convert';
import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';


MedicationHistoryEntity parseHistoryJson(String jsonStr) {
  final decoded = jsonDecode(jsonStr);
  final logsList = (decoded['logs'] as List)
      .map((l) => MedicationLogEntity(
            id: l['id'],
            taken: l['taken'] == true,
            takenAt: DateTime.parse(l['takenAt']),
          ))
      .toList();

  return MedicationHistoryEntity(
    medicationName: decoded['medicationName'],
    adherenceRate: decoded['adherenceRate'] as num,
    logs: logsList,
  );
}

MedicationAdherence parseAdherenceJson(String jsonStr) {
  final Map<String, dynamic> decoded = jsonDecode(jsonStr);
  final rate = (decoded['rate'] as num).toDouble();
  final daysList = (decoded['days'] as List)
      .map((d) => AdherenceDay(
            id: d['id'],
            taken: d['taken'] == true,
            takenAt: DateTime.parse(d['takenAt']),
          ))
      .toList();
  return MedicationAdherence(rate: rate, days: daysList);
}

MedicationCount parseCountsJson(String jsonStr) {
  final decoded = jsonDecode(jsonStr);
  return MedicationCount(
    morning: decoded['morning'] ?? 0,
    afternoon: decoded['afternoon'] ?? 0,
    evening: decoded['evening'] ?? 0,
  );
}

List<MedicationEntity> parseSectionMedicationsJson(String jsonStr) {
  final decoded = jsonDecode(jsonStr) as List;
  return decoded
      .map((m) => MedicationEntity(
            id: m['id'],
            name: m['name'],
            dosage: m['dosage'],
            purpose: m['purpose'],
            toBeTakenAt: DateTime.parse(m['toBeTakenAt']).toLocal(),
            taken: m['taken'] == true,
          ))
      .toList();
}
