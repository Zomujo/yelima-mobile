part of 'medication_repository_impl.dart';

/// Adherence and history: the server's numbers when online and nothing is unsent,
/// otherwise what the phone has.
mixin _MedicationAdherence {
  MedicationRemoteDataSource get remoteDataSource;
  ConnectivityService get connectivityService;
  AppDatabase get db;
  SessionEpoch get session;
  RecentFetches get recent;

  static const _weekly = 'global_weekly';

  AdherenceDao get _adherence => db.adherenceDao;

  Future<MedicationAdherence> getCachedAdherence() async {
    final rate = await _adherence.getGlobalAdherenceRate(_weekly);
    if (rate == null) return const MedicationAdherence(rate: 0, days: []);
    final days = await _adherence.getGlobalAdherenceDays();
    return MedicationAdherence(rate: rate.rate, days: [
      for (final d in days.where((d) => d.type == _weekly))
        AdherenceDay(
            id: d.label,
            taken: d.taken,
            takenAt: DateTime.parse(d.dateTakenStr).toLocal(),
            takenDoses: d.takenDoses,
            scheduledDoses: d.scheduledDoses),
    ]);
  }

  Stream<double?> watchAdherenceRate() =>
      _adherence.watchGlobalAdherenceRate(_weekly).map((a) => a?.rate);

  AsyncResult<MedicationAdherence> getAdherence() =>
      guard(() => recent.share(_weekly, () async {
            // Unsent doses would be missing from the server's numbers.
            if (recent.isFresh(_weekly) ||
                !await connectivityService.isConnected ||
                await db.pendingMutationsDao
                    .hasWaiting(entityType: MedicationRepositoryImpl._type)) {
              return getCachedAdherence();
            }
            try {
              final epoch = session.current;
              final result =
                  await remoteDataSource.getAdherence(showWeekdays: true);
              session.ensure(epoch);
              await _adherence.saveGlobalAdherence(_weekly, result.rate, [
                for (final d in result.days)
                  AdherenceGlobalDay(
                      dateTakenStr: d.takenAt.toIso8601String(),
                      taken: d.taken,
                      label: d.id ?? '',
                      type: _weekly,
                      takenDoses: d.takenDoses,
                      scheduledDoses: d.scheduledDoses),
              ]);
              recent.markFetched(_weekly);
              return result;
            } catch (e) {
              AppLogger.w('Adherence from cache: $e');
              return getCachedAdherence();
            }
          }));

  AsyncResult<MedicationHistoryEntity> getMedicationHistory(
          String medicationId, DateTime month) =>
      guard(() async {
        final key = 'history:$medicationId:${month.year}-${month.month}';
        if (recent.valueOf<MedicationHistoryEntity>(key) case final fresh?) {
          return fresh;
        }
        if (!MedicationRepositoryImpl._isLocalId(medicationId) &&
            await connectivityService.isConnected &&
            !await db.pendingMutationsDao.hasWaiting(entityId: medicationId)) {
          try {
            final epoch = session.current;
            final result = await remoteDataSource.getMedicationHistory(
                medicationId,
                date: AppDateFormats.yyyyMM15.format(month));
            session.ensure(epoch);
            // Only settled days: a pending one shows as no data offline.
            await _adherence.saveMedicationLogs([
              for (final l in result.logs)
                if (l.taken case final taken?)
                  MedicationLog(
                      id: l.id,
                      medicationId: medicationId,
                      takenAt: l.takenAt,
                      taken: taken),
            ]);
            recent.markFetched(key, result);
            return result;
          } catch (e) {
            AppLogger.w('History from the phone: $e');
          }
        }
        // Offline: only the requested month, like the server returns.
        final logs = (await _adherence.getLogsForMedication(medicationId))
            .where((l) =>
                l.takenAt.year == month.year && l.takenAt.month == month.month)
            .toList();
        final taken = logs.where((l) => l.taken).length;
        return MedicationHistoryEntity(
          medicationName:
              (await db.medicationsDao.getMedicationById(medicationId))
                      .firstOrNull
                      ?.name ??
                  '',
          adherenceRate: logs.isEmpty ? 0 : (taken / logs.length * 100).round(),
          logs: [
            for (final l in logs)
              MedicationLogEntity(id: l.id, taken: l.taken, takenAt: l.takenAt),
          ],
        );
      });
}
