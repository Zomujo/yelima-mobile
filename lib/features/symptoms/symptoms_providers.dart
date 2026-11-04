import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import 'data/datasources/symptoms_remote_data_source.dart';
import 'data/datasources/symptoms_remote_mutation_source.dart';
import 'data/repositories/symptoms_repository_impl.dart';
import 'domain/repositories/symptoms_repository.dart';

part 'symptoms_providers.g.dart';

/// Symptoms on the server.
@Riverpod(keepAlive: true)
SymptomsRemoteDataSource symptomsRemoteDataSource(Ref ref) =>
    SymptomsRemoteDataSource(apiClient: ref.watch(apiClientProvider));

/// Symptoms, saved on the phone first and synced.
@Riverpod(keepAlive: true)
SymptomsRepository symptomsRepository(Ref ref) => SymptomsRepositoryImpl(
      remoteDataSource: ref.watch(symptomsRemoteDataSourceProvider),
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
      session: ref.watch(sessionEpochProvider),
      recent: ref.watch(recentFetchesProvider),
      mutationSyncManager: ref.watch(mutationSyncManagerProvider),
    );

/// Lets queued symptom changes reach the server.
void setUpSymptoms(ProviderContainer c) => c
    .read(mutationSyncManagerProvider)
    .registerSource(
        'symptom',
        SymptomsRemoteMutationSource(
            c.read(symptomsRemoteDataSourceProvider), c.read(appDatabaseProvider)));
