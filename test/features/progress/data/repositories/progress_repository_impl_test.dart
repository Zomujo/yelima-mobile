import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/core/failures/app_failure.dart';
import 'package:yelima/core/services/session_epoch.dart';
import 'package:yelima/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:yelima/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';

import '../../../../helpers/fakes.dart';

class MockRemote extends Mock implements ProgressRemoteDataSource {}

void main() {
  const week = ChartDateRange.thisWeek;
  const bp = BPTrend(
      labels: ['Mon', 'Tue'], systolic: [120, 122], diastolic: [80, 82]);
  const sugar = VitalTrend(labels: ['Mon'], values: [5.5], latestValue: 5.5);
  late MockRemote remote;
  late AppDatabase db;

  ProgressRepositoryImpl repo({bool online = true}) => ProgressRepositoryImpl(
        remoteDataSource: remote,
        connectivityService: FakeConnectivity(online: online),
        db: db,
        session: SessionEpoch(),
      );

  setUp(() {
    remote = MockRemote();
    db = testDb();
    when(() => remote.getBPTrend(dateRange: 'thisWeek'))
        .thenAnswer((_) async => bp);
    when(() => remote.getVitalTrend(
        vitalType: 'bloodSugar',
        dateRange: 'thisWeek')).thenAnswer((_) async => sugar);
  });

  tearDown(() => db.close());

  test('an online trend is returned and cached under its old key', () async {
    expect((await repo().getBPTrend(week)).toNullable(), bp);

    final row = (await db.vitalsDao.getAllVitals()).single;
    expect(row.id, 'bp_trend_cache_thisWeek');
    expect(jsonDecode(row.value)['labels'], ['Mon', 'Tue']);
  });

  test('offline, the cached trend comes back as it was saved', () async {
    await repo().getBPTrend(week);
    await repo().getSugarTrend(week);

    expect((await repo(online: false).getBPTrend(week)).toNullable(), bp);
    expect((await repo(online: false).getSugarTrend(week)).toNullable(), sugar);
    verify(() => remote.getBPTrend(dateRange: 'thisWeek')).called(1);
  });

  test('offline with nothing cached says offline, not "not found"', () async {
    expect((await repo(online: false).getBPTrend(week)).getLeft().toNullable(),
        const NetworkFailure());
  });

  test('a server error falls back to the cached trend', () async {
    await repo().getBPTrend(week);
    when(() => remote.getBPTrend(dateRange: 'thisWeek'))
        .thenThrow(Exception('500'));

    expect((await repo().getBPTrend(week)).toNullable(), bp);
  });

  test('a vitals refresh leaves cached trends alone', () async {
    await repo().getBPTrend(week);

    await db.vitalsDao.clearVitals();

    expect((await repo().getCachedBPTrend(week)).toNullable(), bp);
  });

  group('readings saved on the phone', () {
    final now = DateTime(2026, 11, 2, 15, 30);
    Future<void> saveOnPhone(String type, String value, DateTime at) =>
        db.vitalsDao.insertVitals([
          VitalHistoriesCompanion(
            id: Value('local-$value'),
            vitalType: Value(type),
            vitalName: Value(type),
            value: Value(value),
            unit: const Value(''),
            severity: const Value('normal'),
            recordedAt: Value(at),
          )
        ]);
    const oldBP = BPTrend(
        labels: ['2026-10-26T12:57:18.542Z'],
        systolic: [211],
        diastolic: [131]);

    test('offline, a reading logged after the download is in the chart',
        () async {
      when(() => remote.getBPTrend(dateRange: 'thisWeek'))
          .thenAnswer((_) async => oldBP);
      await withClock(Clock.fixed(now), () => repo().getBPTrend(week));
      await saveOnPhone(
          'bloodPressure', '122/76', DateTime(2026, 11, 2, 15, 2));

      final trend = (await withClock(
              Clock.fixed(now), () => repo(online: false).getBPTrend(week)))
          .toNullable();

      expect((trend?.systolic.last, trend?.diastolic.last), (122, 76));
    });

    test('offline with nothing downloaded, the phone\'s readings still show',
        () async {
      await saveOnPhone('bloodSugar', '5.9', DateTime(2026, 11, 2, 15, 6));

      final trend = (await withClock(
              Clock.fixed(now), () => repo(online: false).getSugarTrend(week)))
          .toNullable();

      expect(trend?.latestValue, 5.9);
    });
  });
}
