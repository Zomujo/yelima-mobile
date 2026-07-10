import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/appointments.dart';

part 'appointments_dao.g.dart';

@DriftAccessor(tables: [Appointments])
class AppointmentsDao extends DatabaseAccessor<AppDatabase> with _$AppointmentsDaoMixin {
  AppointmentsDao(super.db);

  Stream<List<Appointment>> watchAllAppointments() {
    return select(appointments).watch();
  }

  Future<List<Appointment>> getAllAppointments() {
    return select(appointments).get();
  }

  Future<void> insertOrUpdateAppointment(AppointmentsCompanion appointment) {
    return into(appointments).insertOnConflictUpdate(appointment);
  }

  Future<void> deleteAppointment(String id) {
    return (delete(appointments)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAppointments() {
    return delete(appointments).go();
  }
}
