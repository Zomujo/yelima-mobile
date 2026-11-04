import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import 'data/datasources/vitals_remote_datasource.dart';
import 'data/datasources/vitals_remote_mutation_source.dart';
import 'data/repositories/vitals_repository_impl.dart';
import 'data/services/severity_rules_store.dart';
import 'domain/repositories/vitals_repository.dart';

part 'vitals_providers.g.dart';

/// Vital readings on the server.
@Riverpod(keepAlive: true)
VitalsRemoteDataSource vitalsRemoteDataSource(Ref ref) =>
    VitalsRemoteDataSource(apiClient: ref.watch(apiClientProvider));

/// The server's rules for grading readings, saved for offline use.
@Riverpod(keepAlive: true)
SeverityRulesStore severityRules(Ref ref) => SeverityRulesStore(
        ref.watch(apiClientProvider), ref.watch(sharedPrefsServiceProvider))
    ..also((r) => ref.watch(sessionLifecycleProvider).register(r, priority: 50));

/// Vital readings, saved on the phone first and synced.
@Riverpod(keepAlive: true)
VitalsRepository vitalsRepository(Ref ref) {
  final rules = ref.watch(severityRulesProvider);
  return VitalsRepositoryImpl(
    remoteDataSource: ref.watch(vitalsRemoteDataSourceProvider),
    connectivityService: ref.watch(connectivityProvider),
    session: ref.watch(sessionEpochProvider),
    db: ref.watch(appDatabaseProvider),
    severityRules: () => rules.current,
    recent: ref.watch(recentFetchesProvider),
    mutationSyncManager: ref.watch(mutationSyncManagerProvider),
  );
}

/// Loads the grading rules with the session and lets queued readings reach the server.
void setUpVitals(ProviderContainer c) {
  c.read(severityRulesProvider);
  c.read(mutationSyncManagerProvider).registerSource(
      'vital_history',
      VitalsRemoteMutationSource(
          c.read(vitalsRemoteDataSourceProvider), c.read(appDatabaseProvider)));
}
