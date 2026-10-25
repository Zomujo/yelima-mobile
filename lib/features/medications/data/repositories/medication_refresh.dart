part of 'medication_repository_impl.dart';

/// Replaces the cached medications with the server's, keeping rows with unsent changes.
mixin _MedicationRefresh {
  MedicationRemoteDataSource get remoteDataSource;
  ConnectivityService get connectivityService;
  AppDatabase get db;
  SessionEpoch get session;
  MedicationReminders get _reminders;
  RecentFetches get recent;

  MedicationsDao get _meds => db.medicationsDao;

  /// Pulls every section and the list from the server, when online.
  Future<void> refreshAll() => recent.share('medications', () async {
        if (recent.isFresh('medications') ||
            !await connectivityService.isConnected) {
          return;
        }
        await Future.wait([
          for (final s in MedicationSection.values) _refreshSection(s),
          _refreshList(),
        ]);
        recent.markFetched('medications');
      });

  /// Replaces [section]'s rows with the server's, except rows with unsent changes.
  Future<void> _refreshSection(MedicationSection section) async {
    try {
      final epoch = session.current;
      final remote =
          await remoteDataSource.getMedicationsBySection(section.key);
      session.ensure(epoch);

      final local = (await _meds.getAllMedications())
          .where((m) => m.section == section.key);
      final byId = {for (final m in local) m.id: m};
      final waiting = await db.pendingMutationsDao
          .getEntityIdsOfType(MedicationRepositoryImpl._type);
      final remoteIds = remote.map((m) => m.id).toSet();

      // Gone from this section only: the medication's other sections stay.
      for (final m in local) {
        if (remoteIds.contains(m.id) || waiting.contains(m.id)) continue;
        await _reminders.cancelSection(m.id, section.key);
        await _meds.deleteMedicationSection(m.id, section.key);
      }

      final rows = [
        for (final m in remote)
          if (!waiting.contains(m.id))
            MedicationMapper.mergeRemoteWithLocal(m, byId[m.id], section),
      ];
      await _meds.insertMedications(rows);
      await _reminders.schedule(rows);
    } catch (e) {
      AppLogger.w('Refreshing ${section.key} failed: $e');
    }
  }

  /// Refreshes name, dosage and purpose from the list (it has no schedules);
  /// a medication not seen before gets its sections fetched.
  Future<void> _refreshList() async {
    try {
      final epoch = session.current;
      final remote = await remoteDataSource.getAllMedications(pageSize: 100);
      session.ensure(epoch);
      final waiting = await db.pendingMutationsDao
          .getEntityIdsOfType(MedicationRepositoryImpl._type);

      for (final id in await _meds.deleteUnknownSectionRows()) {
        await _reminders.cancelSection(id, 'UNKNOWN');
      }

      final updated = <Medication>[];
      var hasNew = false;
      for (final m in remote.rows.where((m) => !waiting.contains(m.id))) {
        final rows = await _meds.getMedicationById(m.id);
        hasNew |= rows.isEmpty;
        updated.addAll(rows.map((row) => row.copyWith(
            name: m.name, dosage: m.dosage, purpose: Value(m.purpose))));
      }
      await _meds.insertMedications(updated);
      if (hasNew) {
        await Future.wait(MedicationSection.values.map(_refreshSection));
      }
    } catch (e) {
      AppLogger.w('Refreshing the medication list failed: $e');
    }
  }
}
