import 'package:get_it/get_it.dart';

import '../../core/services/recent_fetches.dart';

import '../../core/managers/mutation_sync_manager.dart';
import '../../core/services/session_lifecycle_service.dart';
import 'data/datasources/vitals_remote_datasource.dart';
import 'data/datasources/vitals_remote_mutation_source.dart';
import 'data/repositories/vitals_repository_impl.dart';
import 'data/services/severity_rules_store.dart';
import 'domain/repositories/vitals_repository.dart';

/// Registers the vitals feature.
void initVitals(GetIt sl) {
  sl.registerLazySingleton<VitalsRemoteDataSource>(
      () => VitalsRemoteDataSource(apiClient: sl()));
  final rules = SeverityRulesStore(sl(), sl());
  sl<SessionLifecycleService>().register(rules, priority: 50);
  sl.registerLazySingleton<VitalsRepository>(() => VitalsRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        session: sl(),
        db: sl(),
        severityRules: () => rules.current,
        recent: sl<RecentFetches>(),
      ));

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('vital_history', VitalsRemoteMutationSource(sl(), sl()));
}
