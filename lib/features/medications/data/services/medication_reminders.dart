import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/medication_section.dart';
import '../../utils/medication_reminder_id.dart';

/// The daily local reminders for medication rows, one per section.
class MedicationReminders {
  MedicationReminders(this._notifications, this._l10n);

  final NotificationService _notifications;

  /// The app's current translations, read each time reminders are scheduled.
  final AppLocalizations Function() _l10n;

  /// Schedules a reminder for every row that has a dose time.
  Future<void> schedule(List<Medication> rows) async {
    final text = _l10n();
    for (final m in rows.where((m) => m.toBeTakenAt != null)) {
      await _notifications.scheduleDailyReminder(
        id: medicationReminderId(m.id, m.section),
        title: text.medicationReminderTitle,
        // Generic on purpose: no drug name on the lock screen.
        body: text.medicationReminderBody,
        time: TimeOfDay.fromDateTime(m.toBeTakenAt!),
      );
    }
  }

  /// Cancels one section's reminder.
  Future<void> cancelSection(String id, String section) =>
      _notifications.cancelReminder(medicationReminderId(id, section));

  /// Cancels every section's reminder; UNKNOWN rows came from an older list sync.
  Future<void> cancel(String id) async {
    for (final section in [
      ...MedicationSection.values.map((s) => s.key),
      'UNKNOWN'
    ]) {
      await cancelSection(id, section);
    }
  }

  /// Replaces every scheduled reminder with ones for [rows].
  Future<void> replaceAll(List<Medication> rows) async {
    await _notifications.cancelAllReminders();
    await schedule(rows);
  }
}
