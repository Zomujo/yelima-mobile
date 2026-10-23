import '../../../../core/failures/app_failure.dart';
import '../entities/symptom_entity.dart';

/// Reported symptoms, saved on the phone first.
abstract class SymptomsRepository {
  /// Live symptoms on the phone.
  Stream<List<SymptomEntity>> watchSymptoms();

  /// Replaces the phone's symptoms with the server's, keeping unsent ones.
  /// Skipped if the last refresh in this session was under 5 minutes ago, unless [force].
  AsyncResult<void> refresh({bool force = false});

  /// Reports a symptom and returns its id (a temporary one until it syncs).
  AsyncResult<String> createSymptom(String description);
}
