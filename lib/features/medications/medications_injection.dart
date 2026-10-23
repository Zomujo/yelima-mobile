import 'package:get_it/get_it.dart';

import '../../core/controllers/locale_controller.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/managers/mutation_sync_manager.dart';
import '../../core/services/session_lifecycle_service.dart';
import 'data/datasources/medication_remote_datasource.dart';
import 'data/datasources/medication_remote_mutation_source.dart';
import 'data/repositories/medication_repository_impl.dart';
import 'data/services/medication_alarm_sync_service.dart';
import 'data/services/seeded_medications_sync_service.dart';
import 'domain/repositories/medication_repository.dart';
import 'presentation/controllers/all_medicines_controller.dart';
import 'presentation/controllers/medication_controller.dart';

/// Registers the medications feature.
void initMedications(GetIt sl) {
  sl.registerLazySingleton<MedicationRemoteDataSource>(
      () => MedicationRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton<MedicationRepository>(() => MedicationRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        db: sl(),
        mutationSyncManager: sl(),
        notificationService: sl(),
        session: sl(),
        l10n: () => l10nFor(sl<LocaleController>().locale),
      ));

  final session = sl<SessionLifecycleService>();
  final seeded = SeededMedicationsSyncService(sl(), sl(), sl());
  session.register(seeded, priority: 90);
  sl.registerSingleton<SeededMedicationsSyncService>(seeded);
  session.register(MedicationAlarmSyncService(sl(), sl(), sl<LocaleController>()), priority: 80);

  sl.registerFactory(() => MedicationController(repository: sl()));
  sl.registerFactory(() => AllMedicinesController(repository: sl()));

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('medication', MedicationRemoteMutationSource(sl(), sl()));
}
