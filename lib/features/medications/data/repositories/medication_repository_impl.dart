import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/custom_types.dart';
import '../../../../core/services/mutation_sync_manager.dart';
import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../datasources/medication_local_datasource.dart';
import '../models/create_medication_model.dart';
import '../models/update_medication_model.dart';
import '../models/medication_detail_model.dart';
import '../models/seeded_medication_list_response_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final MedicationLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  AsyncResponse<MedicationAdherence> getCachedAdherence(
          {required bool showWeekdays}) =>
      localDataSource.getCachedAdherence();

  @override
  Stream<MedicationCount> watchMedicationCounts() =>
      localDataSource.watchMedicationCounts();

  @override
  Stream<List<MedicationEntity>> watchMedicationsBySection(String section) =>
      localDataSource.watchMedicationsBySection(section);

  @override
  Stream<List<MedicationEntity>> watchAllMedications() =>
      localDataSource.watchAllMedications();

  @override
  AsyncResponse<MedicationCount> getCachedMedicationCounts() =>
      localDataSource.getCachedMedicationCounts();

  @override
  AsyncResponse<List<MedicationEntity>> getCachedMedicationsBySection(
          String section) =>
      localDataSource.getCachedMedicationsBySection(section);

  @override
  AsyncResponse<MedicationListResponse> getCachedAllMedications() =>
      localDataSource.getCachedAllMedications(1, 50);

  @override
  AsyncResponse<MedicationAdherence> getAdherence(
      {required bool showWeekdays}) async {
    if (await connectivityService.isConnected) {
      try {
        MedicationAdherence result =
            await remoteDataSource.getAdherence(showWeekdays: showWeekdays);
        result = await localDataSource
            .applyPendingMutationsToAdherenceResult(result);
        await localDataSource.cacheAdherence(result);
        return right(result);
      } on ApiException catch (e) {
        return (await localDataSource.getCachedAdherence())
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return localDataSource.getCachedAdherence();
      }
    } else {
      return localDataSource.getCachedAdherence();
    }
  }

  @override
  Stream<MedicationAdherence> watchAdherence() =>
      localDataSource.watchAdherence();

  @override
  AsyncResponse<MedicationCount> getMedicationCounts() async {
    return localDataSource.getCachedMedicationCounts();
  }

  @override
  AsyncResponse<List<MedicationEntity>> getMedicationsBySection(
      String section) async {
    if (await connectivityService.isConnected) {
      try {
        List<MedicationEntity> result =
            await remoteDataSource.getMedicationsBySection(section);
        result = await localDataSource.applyPendingMutationsToRemoteResult(
            result,
            sectionFilter: section);
        await localDataSource.cacheMedicationsBySection(section, result);
        return right(result);
      } on ApiException catch (e) {
        return (await localDataSource.getCachedMedicationsBySection(section))
            .fold(
                (_) => left(e.message ?? 'Server error'),
                (r) async => right(
                    await localDataSource.applyPendingMutationsToRemoteResult(r,
                        sectionFilter: section)));
      } catch (e) {
        return localDataSource.getCachedMedicationsBySection(section).then(
            (res) => res.fold(
                (l) => left(l),
                (r) async => right(
                    await localDataSource.applyPendingMutationsToRemoteResult(r,
                        sectionFilter: section))));
      }
    } else {
      return localDataSource.getCachedMedicationsBySection(section).then(
          (res) => res.fold(
              (l) => left(l),
              (r) async => right(
                  await localDataSource.applyPendingMutationsToRemoteResult(r,
                      sectionFilter: section))));
    }
  }

  @override
  AsyncResponse<void> confirmMedication(String medicationId, String section,
      {String? date}) async {
    bool forceOffline = false;
    final effectiveDate =
        date ?? DateTime.now().toIso8601String().split('T')[0];

    if (await connectivityService.isConnected) {
      try {
        await remoteDataSource.confirmMedication(medicationId, section,
            date: effectiveDate);

        await localDataSource.markMedicationTaken(
            medicationId, section, effectiveDate);
        await localDataSource.optimisticallyUpdateAdherence(effectiveDate);
        await localDataSource.updateMedicationHistoryLog(
            medicationId, effectiveDate, DateTime.now());

        return right(null);
      } on NetworkException {
        forceOffline = true;
      } on ApiException catch (e) {
        return left(e.message ?? 'Failed to confirm dose. Please try again.');
      } catch (e) {
        return left(
            'Something went wrong confirming this dose. Please try again.');
      }
    } else {
      forceOffline = true;
    }

    if (forceOffline) {
      try {
        await localDataSource.queueOptimisticConfirm(
            medicationId, section, effectiveDate);
        await localDataSource.markMedicationTaken(
            medicationId, section, effectiveDate);
        await localDataSource.optimisticallyUpdateAdherence(effectiveDate);
        await localDataSource.updateMedicationHistoryLog(
            medicationId, effectiveDate, DateTime.now());

        try {
          if (GetIt.instance.isRegistered<MutationSyncManager>()) {
            GetIt.instance<MutationSyncManager>().triggerSync();
          }
        } catch (_) {}

        return right(null);
      } catch (e) {
        return left('Cache failure');
      }
    }
    return left('Unexpected state');
  }

  final Map<String, DateTime> _lastFetchTimeByPage = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  AsyncResponse<MedicationListResponse> getAllMedications(
      {int page = 1, int pageSize = 10, bool forceRefresh = false}) async {
    if (await connectivityService.isConnected) {
      final pageCacheKey = '$page-$pageSize';

      if (!forceRefresh && _lastFetchTimeByPage[pageCacheKey] != null) {
        final now = DateTime.now();
        if (now.difference(_lastFetchTimeByPage[pageCacheKey]!) <
            _cacheDuration) {
          return localDataSource.getCachedAllMedications(page, pageSize);
        }
      }

      try {
        MedicationListResponse result = await remoteDataSource
            .getAllMedications(page: page, pageSize: pageSize);

        final patchedRows = await localDataSource
            .applyPendingMutationsToRemoteResult(result.rows);
        result = MedicationListResponse(
          rows: patchedRows,
          total: result.total + (patchedRows.length - result.rows.length),
          pageSize: result.pageSize,
          page: result.page,
          totalPages: result.totalPages,
        );

        await localDataSource.cacheAllMedications(result.rows);

        _lastFetchTimeByPage[pageCacheKey] = DateTime.now();
        return right(result);
      } on ApiException catch (e) {
        return (await localDataSource.getCachedAllMedications(page, pageSize))
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return localDataSource.getCachedAllMedications(page, pageSize);
      }
    } else {
      return localDataSource.getCachedAllMedications(page, pageSize);
    }
  }

  @override
  AsyncResponse<MedicationHistoryEntity> getMedicationHistory(
      String medicationId,
      {required String date}) async {
    if (await connectivityService.isConnected) {
      try {
        final result = await remoteDataSource.getMedicationHistory(medicationId,
            date: date);
        await localDataSource.cacheMedicationHistory(
            medicationId, date, result);
        return right(result);
      } on ApiException catch (e) {
        return (await localDataSource.getCachedMedicationHistory(
                medicationId, date))
            .fold((_) => left(e.message ?? 'Server error'), right);
      } catch (e) {
        return localDataSource.getCachedMedicationHistory(medicationId, date);
      }
    } else {
      return localDataSource.getCachedMedicationHistory(medicationId, date);
    }
  }

  @override
  void invalidateCache() {
    _lastFetchTimeByPage.clear();
  }

  @override
  AsyncResponse<String> createMedication(CreateMedicationModel data) async {
    try {
      final localId = await localDataSource.createMedicationOffline(data);

      try {
        if (GetIt.instance.isRegistered<MutationSyncManager>()) {
          GetIt.instance<MutationSyncManager>().triggerSync();
        }
      } catch (_) {}

      return right(localId);
    } catch (e) {
      return left('Failed to create medication locally');
    }
  }

  @override
  AsyncResponse<MedicationDetailModel> getMedicationById(String id) async {
    return localDataSource.getMedicationById(id);
  }

  @override
  AsyncResponse<String> updateMedication(
      String id, UpdateMedicationModel data) async {
    try {
      final updatedId = await localDataSource.updateMedicationOffline(id, data);

      try {
        if (GetIt.instance.isRegistered<MutationSyncManager>()) {
          GetIt.instance<MutationSyncManager>().triggerSync();
        }
      } catch (_) {}

      return right(updatedId);
    } catch (e) {
      return left('Failed to update medication locally');
    }
  }

  @override
  AsyncResponse<SeededMedicationListResponseModel> getPreloadedMedications(
      {int page = 1, int limit = 10, String? search}) async {
    if (await connectivityService.isConnected) {
      try {
        final res = await remoteDataSource.getPreloadedMedications(
            page: page, limit: limit, search: search);
        return right(res);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left(e.toString());
      }
    } else {
      return left('No internet connection');
    }
  }
}
