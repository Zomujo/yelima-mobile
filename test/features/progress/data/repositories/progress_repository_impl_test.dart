import 'dart:convert';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yelima/core/services/connectivity_service.dart';
import 'package:yelima/core/db/app_database.dart';
import 'package:yelima/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:yelima/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:yelima/features/progress/domain/entities/vital_trends.dart';

class MockProgressRemoteDataSource extends Mock
    implements ProgressRemoteDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late ProgressRepositoryImpl repository;
  late MockProgressRemoteDataSource mockRemoteDataSource;
  late MockConnectivityService mockConnectivityService;
  late AppDatabase testDb;

  setUp(() {
    mockRemoteDataSource = MockProgressRemoteDataSource();
    mockConnectivityService = MockConnectivityService();
    // Use an in-memory database for testing
    testDb = AppDatabase(executor: NativeDatabase.memory());

    repository = ProgressRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      connectivityService: mockConnectivityService,
      db: testDb,
    );
  });

  tearDown(() async {
    await testDb.close();
  });

  group('getBPTrend', () {
    const tDateRange = 'week';
    final tBPTrend = const BPTrend(
      labels: ['Mon', 'Tue'],
      systolic: [120, 122],
      diastolic: [80, 82],
    );

    test(
        'should return remote data and cache it when online and request is successful',
        () async {
      // Arrange
      when(() => mockConnectivityService.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getBPTrend(dateRange: tDateRange))
          .thenAnswer((_) async => tBPTrend);

      // Act
      final result = await repository.getBPTrend(dateRange: tDateRange);

      // Assert
      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), tBPTrend);

      verify(() => mockRemoteDataSource.getBPTrend(dateRange: tDateRange))
          .called(1);

      // Verify it was cached in the local database
      final cachedVitals = await testDb.vitalsDao.getAllVitals();
      expect(cachedVitals.length, 1);
      expect(cachedVitals.first.id, 'bp_trend_cache_$tDateRange');

      final cachedJson = jsonDecode(cachedVitals.first.value);
      expect(cachedJson['labels'], ['Mon', 'Tue']);
    });

    test('should return cached data when offline', () async {
      // Arrange
      when(() => mockConnectivityService.isConnected).thenAnswer((_) async => false);

      // Pre-populate the database with cached data
      final trendJson = jsonEncode({
        'labels': ['Wed'],
        'systolic': [118],
        'diastolic': [78],
      });
      await testDb.vitalsDao.insertVitals([
        VitalHistoriesCompanion(
          id: const drift.Value('bp_trend_cache_week'),
          vitalType: const drift.Value('PROGRESS_BP_TREND'),
          vitalName: const drift.Value('BP Trend week'),
          value: drift.Value(trendJson),
          unit: const drift.Value('json'),
          severity: const drift.Value('normal'),
          recordedAt: drift.Value(DateTime.now()),
        )
      ]);

      // Act
      final result = await repository.getBPTrend(dateRange: tDateRange);

      // Assert
      expect(result.isRight(), true);
      final returnedTrend = result.getRight().toNullable();
      expect(returnedTrend?.labels, ['Wed']);
      expect(returnedTrend?.systolic, [118]);

      verifyNever(() =>
          mockRemoteDataSource.getBPTrend(dateRange: any(named: 'dateRange')));
    });

    test('should return Failure when offline and no cached data exists',
        () async {
      // Arrange
      when(() => mockConnectivityService.isConnected).thenAnswer((_) async => false);
      // Database is empty

      // Act
      final result = await repository.getBPTrend(dateRange: tDateRange);

      // Assert
      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable(),
          'No offline data available for BP trend. Please connect to the internet to fetch it.');
    });
  });
}
