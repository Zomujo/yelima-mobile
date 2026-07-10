import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:yelima/features/progress/domain/entities/vital_trends.dart';
import 'package:yelima/features/progress/domain/repositories/progress_repository.dart';
import 'package:yelima/features/progress/presentation/controllers/progress_controller.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late ProgressController controller;
  late MockProgressRepository mockRepository;

  setUp(() {
    mockRepository = MockProgressRepository();
    controller = ProgressController(mockRepository);
  });

  group('ProgressController', () {
    const tDateRange = 'today';
    final tBPTrend = const BPTrend(
      labels: ['10:00 AM'],
      systolic: [120],
      diastolic: [80],
    );

    test('fetchBPTrend successfully updates state with data', () async {
      // Arrange
      // First it tries to get cached data, let's say cache is empty
      when(() => mockRepository.getCachedBPTrend(dateRange: tDateRange))
          .thenAnswer((_) async => const Left('No cache'));

      // Then it fetches from network
      when(() => mockRepository.getBPTrend(dateRange: tDateRange))
          .thenAnswer((_) async => Right(tBPTrend));

      // We can also verify that listeners are notified, but testing the state is sufficient
      int listenerCallCount = 0;
      controller.addListener(() {
        listenerCallCount++;
      });

      // Act
      await controller.fetchBPTrend(dateRange: tDateRange);

      // Assert
      expect(controller.bpTrendState.data, tBPTrend);
      expect(controller.bpTrendState.isLoading, false);
      expect(controller.bpTrendState.error, null);

      // It should notify listeners when loading starts, (maybe cache fails), loading continues, and success
      expect(listenerCallCount, greaterThan(0));

      verify(() => mockRepository.getCachedBPTrend(dateRange: tDateRange))
          .called(1);
      verify(() => mockRepository.getBPTrend(dateRange: tDateRange)).called(1);
    });

    test('fetchBPTrend sets error state on failure', () async {
      // Arrange
      const errorMessage = 'Network error';
      when(() => mockRepository.getCachedBPTrend(dateRange: tDateRange))
          .thenAnswer((_) async => const Left('No cache'));

      when(() => mockRepository.getBPTrend(dateRange: tDateRange))
          .thenAnswer((_) async => const Left(errorMessage));

      // Act
      await controller.fetchBPTrend(dateRange: tDateRange);

      // Assert
      expect(controller.bpTrendState.data, null);
      expect(controller.bpTrendState.isLoading, false);
      expect(controller.bpTrendState.error, errorMessage);

      verify(() => mockRepository.getCachedBPTrend(dateRange: tDateRange))
          .called(1);
      verify(() => mockRepository.getBPTrend(dateRange: tDateRange)).called(1);
    });

    test('fetchBPTrend uses cached data first if available', () async {
      // Arrange
      when(() => mockRepository.getCachedBPTrend(dateRange: tDateRange))
          .thenAnswer((_) async => Right(tBPTrend));

      // The network call might still happen in the background or fail
      when(() => mockRepository.getBPTrend(dateRange: tDateRange))
          .thenAnswer((_) async => const Left('Network offline'));

      // Act
      await controller.fetchBPTrend(dateRange: tDateRange);

      // Assert
      // Because cache was successful, data should be tBPTrend,
      // but since the network call failed afterwards, it might set error.
      // Let's check how the controller handles it.
      // Actually, looking at ProgressController:
      // result.fold((err) => bpTrendState.copyWith(error: err.message), ...)
      // So it will overwrite the error state, but the data will remain since copyWith doesn't clear data unless specified!

      expect(controller.bpTrendState.data, tBPTrend);
      expect(controller.bpTrendState.error, 'Network offline');
      expect(controller.bpTrendState.isLoading, false);
    });
  });
}
