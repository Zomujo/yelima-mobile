part of 'medication_repository_impl.dart';

/// Told how far the server's week differs from the phone's: decided days that
/// disagree, and server rate minus phone rate.
typedef AdherenceDriftReporter = void Function(
    {required int days, required int rateDiff});

/// Adherence and history: the server's numbers when online and nothing is unsent,
/// otherwise the phone works them out the same way.
mixin _MedicationAdherence {
  MedicationRemoteDataSource get remoteDataSource;
  ConnectivityService get connectivityService;
  AppDatabase get db;
  SessionEpoch get session;
  RecentFetches get recent;

  AdherenceDriftReporter? get onAdherenceDrift;

  static const _weekly = 'global_weekly';

  /// The week the phone last worked out, until the server's answer replaces it.
  MedicationAdherence? _phoneWeek;

  AdherenceDao get _adherence => db.adherenceDao;

  /// This week's days and the last saved rate.
  Future<MedicationAdherence> getCachedAdherence() async {
    final rate = await _adherence.getGlobalAdherenceRate(_weekly);
    if (rate == null) return const MedicationAdherence(rate: 0, days: []);
    final monday = WeekAdherence.mondayOf(clock.now());
    final sunday = DateTime(monday.year, monday.month, monday.day + 7);
    return MedicationAdherence(rate: rate.rate, savedAt: rate.updatedAt, days: [
      for (final d in await _savedDays())
        if (!d.takenAt.isBefore(monday) && d.takenAt.isBefore(sunday)) d,
    ]);
  }

  Future<List<AdherenceDay>> _savedDays() async => [
        for (final d in await _adherence.getGlobalAdherenceDays())
          if (d.type == _weekly)
            AdherenceDay(
                id: d.label,
                taken: d.taken,
                takenAt: DateTime.parse(d.dateTakenStr).toLocal(),
                takenDoses: d.takenDoses,
                scheduledDoses: d.scheduledDoses),
      ];

  Stream<MedicationAdherence?> watchAdherence() => _adherence
      .watchGlobalAdherenceRate(_weekly)
      .asyncMap((a) => a == null ? null : getCachedAdherence());

  AsyncResult<MedicationAdherence> getAdherence() =>
      guard(() => recent.share(_weekly, () async {
            if (recent.isFresh(_weekly)) return getCachedAdherence();
            // Unsent doses would be missing from the server's numbers.
            if (!await connectivityService.isConnected ||
                await db.pendingMutationsDao
                    .hasWaiting(entityType: MedicationRepositoryImpl._type)) {
              return _workOutHere();
            }
            try {
              final epoch = session.current;
              final result =
                  await remoteDataSource.getAdherence(showWeekdays: true);
              session.ensure(epoch);
              await _saveWeek(result);
              _reportDrift(result);
              recent.markFetched(_weekly);
              return result;
            } catch (e) {
              AppLogger.w('Adherence worked out on the phone: $e');
              return _workOutHere();
            }
          }));

  /// The week by the server's rule, from its saved days and today's doses here.
  Future<MedicationAdherence> _workOutHere() async {
    final now = clock.now();
    final rows = await db.medicationsDao.getAllMedications();
    final today = rows.where((r) => MedicationMapper.isDueToday(r, now));
    await _saveWeek(_phoneWeek = WeekAdherence.compute(
      saved: await _savedDays(),
      scheduledToday: today.length,
      takenToday: today.where((r) => MedicationMapper.toEntity(r).taken).length,
      perDay: rows.length,
      now: now,
      lastRate: (await _adherence.getGlobalAdherenceRate(_weekly))?.rate ?? 0,
    ));
    return getCachedAdherence();
  }

  /// Reports when the server's week differs from the phone's, so a rule that
  /// drifted between the two shows up in analytics.
  void _reportDrift(MedicationAdherence server) {
    final phone = _phoneWeek;
    _phoneWeek = null;
    if (phone == null) return;
    String day(DateTime t) => AppDateFormats.yyyyMMdd.format(t);
    final mine = {for (final d in phone.days) day(d.takenAt): d.taken};
    final days = server.days.where((d) {
      final own = mine[day(d.takenAt)];
      return d.taken != null && own != null && own != d.taken;
    }).length;
    final rateDiff = (server.rate - phone.rate).round();
    if (days > 0 || rateDiff != 0) {
      onAdherenceDrift?.call(days: days, rateDiff: rateDiff);
    }
  }

  Future<void> _saveWeek(MedicationAdherence week) =>
      _adherence.saveGlobalAdherence(_weekly, week.rate, [
        for (final d in week.days)
          AdherenceGlobalDay(
              dateTakenStr: d.takenAt.toIso8601String(),
              taken: d.taken,
              label: d.id ?? '',
              type: _weekly,
              takenDoses: d.takenDoses,
              scheduledDoses: d.scheduledDoses),
      ]);

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
            await _adherence.replaceMonthLogs(
                medicationId,
                month,
                [
                  for (final l in result.logs)
                    if (l.taken case final taken?)
                      MedicationLog(
                          id: l.id,
                          medicationId: medicationId,
                          takenAt: l.takenAt,
                          taken: taken),
                ],
                rate: result.adherenceRate.round());
            recent.markFetched(key, result);
            return result;
          } catch (e) {
            AppLogger.w('History from the phone: $e');
          }
        }
        return getCachedHistory(medicationId, month);
      });

  /// Only the requested month, like the server returns.
  Future<MedicationHistoryEntity> getCachedHistory(
      String medicationId, DateTime month) async {
    final logs = (await _adherence.getLogsForMedication(medicationId))
        .where((l) =>
            l.takenAt.year == month.year && l.takenAt.month == month.month)
        .toList();
    final taken = logs.where((l) => l.taken).length;
    // The server counts doses, which the phone can't, so its last rate wins.
    final saved = await _adherence.getMonthRate(medicationId, month);
    return MedicationHistoryEntity(
      medicationName: (await db.medicationsDao.getMedicationById(medicationId))
              .firstOrNull
              ?.name ??
          '',
      adherenceRate:
          saved ?? (logs.isEmpty ? 0 : (taken / logs.length * 100).round()),
      logs: [
        for (final l in logs)
          MedicationLogEntity(id: l.id, taken: l.taken, takenAt: l.takenAt),
      ],
    );
  }
}
