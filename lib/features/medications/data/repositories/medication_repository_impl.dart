import 'package:fpdart/fpdart.dart';

import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/custom_types.dart';

import '../../domain/entities/medication_adherence.dart';
import '../../domain/entities/medication_count.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/entities/medication_history_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_datasource.dart';
import '../models/create_medication_model.dart';
import '../models/update_medication_model.dart';
import '../models/medication_detail_model.dart';
import '../models/seeded_medication_list_response_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  AsyncResponse<MedicationAdherence> getCachedAdherence(
          {required bool showWeekdays}) async =>
      left('No cache');

  @override
  Stream<MedicationCount> watchMedicationCounts() => const Stream.empty();

  @override
  Stream<List<MedicationEntity>> watchMedicationsBySection(String section) =>
      const Stream.empty();

  @override
  Stream<List<MedicationEntity>> watchAllMedications() => const Stream.empty();

  @override
  AsyncResponse<MedicationAdherence> getAdherence(
      {required bool showWeekdays}) async {
    if (await connectivityService.isConnected) {
      try {
        MedicationAdherence result =
            await remoteDataSource.getAdherence(showWeekdays: showWeekdays);
        return right(result);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left('Unexpected error');
      }
    } else {
      return left('No internet');
    }
  }

  @override
  Stream<MedicationAdherence> watchAdherence() => const Stream.empty();

  @override
  AsyncResponse<MedicationCount> getMedicationCounts() async {
    if (await connectivityService.isConnected) {
      try {
        final result = await remoteDataSource.getMedicationCounts();
        return right(result);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left('Unexpected error');
      }
    } else {
      return left('No internet');
    }
  }

  @override
  AsyncResponse<List<MedicationEntity>> getMedicationsBySection(
      String section) async {
    if (await connectivityService.isConnected) {
      try {
        List<MedicationEntity> result =
            await remoteDataSource.getMedicationsBySection(section);
        return right(result);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left('Unexpected error');
      }
    } else {
      return left('No internet');
    }
  }

  @override
  AsyncResponse<void> confirmMedication(String medicationId, String section,
      {String? date}) async {
    final effectiveDate =
        date ?? DateTime.now().toIso8601String().split('T')[0];

    if (await connectivityService.isConnected) {
      try {
        await remoteDataSource.confirmMedication(medicationId, section,
            date: effectiveDate);

        return right(null);
      } on ApiException catch (e) {
        return left(e.message ?? 'Failed to confirm dose. Please try again.');
      } catch (e) {
        return left(
            'Something went wrong confirming this dose. Please try again.');
      }
    } else {
      return left('No internet connection. Cannot confirm medication offline.');
    }
  }

  @override
  AsyncResponse<MedicationListResponse> getAllMedications(
      {int page = 1, int pageSize = 10, bool forceRefresh = false}) async {
    if (await connectivityService.isConnected) {
      try {
        MedicationListResponse result = await remoteDataSource
            .getAllMedications(page: page, pageSize: pageSize);
        return right(result);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left('Unexpected error');
      }
    } else {
      return left('No internet');
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
        return right(result);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left('Unexpected error');
      }
    } else {
      return left('No internet');
    }
  }

  @override
  AsyncResponse<String> createMedication(CreateMedicationModel data) async {
    if (await connectivityService.isConnected) {
      try {
        final serverId = await remoteDataSource.createMedication(data);
        return right(serverId);
      } on ApiException catch (e) {
        return left(e.message ?? 'Failed to create medication');
      } catch (e) {
        return left('An unexpected error occurred');
      }
    } else {
      return left('No internet connection');
    }
  }

  @override
  AsyncResponse<MedicationDetailModel> getMedicationById(String id) async {
    if (await connectivityService.isConnected) {
      try {
        final result = await remoteDataSource.getMedicationById(id);
        return right(result);
      } on ApiException catch (e) {
        return left(e.message ?? 'Server error');
      } catch (e) {
        return left('Unexpected error');
      }
    } else {
      return left('No internet');
    }
  }

  @override
  AsyncResponse<String> updateMedication(
      String id, UpdateMedicationModel data) async {
    if (await connectivityService.isConnected) {
      try {
        final updatedId = await remoteDataSource.updateMedication(id, data);
        return right(updatedId);
      } on ApiException catch (e) {
        return left(e.message ?? 'Failed to update medication');
      } catch (e) {
        return left('An unexpected error occurred');
      }
    } else {
      return left('No internet connection');
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
