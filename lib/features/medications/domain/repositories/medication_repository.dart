import '../../../../core/failures/app_failure.dart';
import '../entities/medication_adherence.dart';
import '../entities/medication_count.dart';
import '../entities/medication_entity.dart';
import '../entities/medication_form.dart';
import '../entities/medication_history_entity.dart';
import '../entities/medication_section.dart';
import '../models/medication_detail_model.dart';
import '../models/seeded_medication_model.dart';

/// Medications, doses and adherence: saved on the phone first, synced when online.
abstract class MedicationRepository {
  /// This week's adherence as last saved on the phone.
  Future<MedicationAdherence> getCachedAdherence();

  /// Live weekly adherence rate (0–100) as saved on the phone.
  Stream<double?> watchAdherenceRate();

  /// This week's adherence from the server, or the phone's copy.
  AsyncResult<MedicationAdherence> getAdherence();

  /// Live number of medications per section.
  Stream<MedicationCount> watchCounts();

  /// Live list of today's doses in [section].
  Stream<List<MedicationEntity>> watchSection(MedicationSection section);

  /// Refreshes every section and the medication list from the server.
  Future<void> refreshAll();

  /// Marks today's [section] dose of [medicationId] as taken.
  AsyncResult<void> confirmDose(String medicationId, MedicationSection section);

  /// Live list of every medication once, whatever its sections.
  Stream<List<MedicationEntity>> watchAll();

  /// Full details, including the schedule.
  AsyncResult<MedicationDetailModel> getMedicationById(String id);

  /// Taken and missed doses of [medicationId] in [month].
  AsyncResult<MedicationHistoryEntity> getMedicationHistory(
      String medicationId, DateTime month);

  /// Adds a medication and returns its (local) id.
  AsyncResult<String> createMedication(MedicationForm form);

  /// Changes a medication's dosage, notes and schedule.
  AsyncResult<void> updateMedication(String id, MedicationForm form);

  /// Deletes a medication and its reminders.
  AsyncResult<void> deleteMedication(String id);

  /// Known medications whose name matches [search], for the add form.
  Future<List<SeededMedicationModel>> searchPreloaded(String search);

  /// Emits after a medication change reached the server.
  Stream<void> get onSynced;

  /// Emits (local id, server id) once a new medication gets its server id.
  Stream<(String, String)> get onIdChanged;

  /// Reschedules every reminder from the phone's medications.
  Future<void> syncLocalAlarms();

  /// Whether reminders fire at the exact minute; newer Android asks the user first.
  Future<bool> remindersAreExact();

  /// Asks the user to allow exact reminders, then reschedules every reminder.
  Future<void> allowExactReminders();

  /// Moves a medication's reminders from its local id to its server id after sync.
  Future<void> moveReminders(String oldId, String newId);
}
