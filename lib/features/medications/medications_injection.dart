import 'package:get_it/get_it.dart';

import 'data/datasources/medication_remote_datasource.dart';
import 'data/datasources/medication_remote_mutation_source.dart';
import 'domain/repositories/medication_repository.dart';
import 'data/repositories/medication_repository_impl.dart';
import 'domain/usecases/create_medication_usecase.dart';
import 'domain/usecases/update_medication_usecase.dart';
import 'presentation/controllers/all_medicines_controller.dart';
import 'presentation/controllers/medication_controller.dart';

void initMedications(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<MedicationRemoteDataSource>(
      () => MedicationRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<MedicationRemoteMutationSource>(
      () => MedicationRemoteMutationSource(sl()));

  // Repository
  sl.registerLazySingleton<MedicationRepository>(() => MedicationRepositoryImpl(
      remoteDataSource: sl(), connectivityService: sl(), db: sl()));

  // Use cases
  sl.registerLazySingleton<UpdateMedicationUseCase>(
      () => UpdateMedicationUseCase(sl()));
  sl.registerLazySingleton<CreateMedicationUseCase>(
      () => CreateMedicationUseCase(sl()));

  // Controllers
  sl.registerFactory(() => MedicationController(repository: sl()));
  sl.registerFactory(() => AllMedicinesController(repository: sl()));
}
