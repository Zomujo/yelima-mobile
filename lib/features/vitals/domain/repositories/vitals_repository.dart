import '../../../../core/failures/app_failure.dart';
import '../entities/reading_form.dart';
import '../entities/vital_history_entity.dart';

/// Blood pressure and sugar readings, saved on the phone first.
abstract class VitalsRepository {
  /// Live readings on the phone.
  Stream<List<VitalHistoryEntity>> watchReadings();

  /// Live newest reading of each kind.
  Stream<LatestVitals> watchLatest();

  /// Replaces the phone's readings with the server's, keeping unsent ones.
  AsyncResult<void> refresh();

  /// Checks and saves a reading, sending it now or queueing it while offline; gives its grade.
  AsyncResult<VitalSeverity> saveReading(ReadingForm form);
}
