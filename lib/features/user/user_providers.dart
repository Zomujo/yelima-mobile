import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import 'data/datasources/user_remote_data_source.dart';
import 'data/datasources/user_remote_mutation_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';

export 'presentation/controllers/user_controller.dart'
    show userControllerProvider;

part 'user_providers.g.dart';

/// The profile on the server and in Firestore.
@Riverpod(keepAlive: true)
UserRemoteDataSource userRemoteDataSource(Ref ref) => UserRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    apiClient: ref.watch(apiClientProvider));

/// The profile, saved on the phone first and synced.
@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => UserRepositoryImpl(
      remoteDataSource: ref.watch(userRemoteDataSourceProvider),
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
      session: ref.watch(sessionEpochProvider),
      mutationSyncManager: ref.watch(mutationSyncManagerProvider),
    );

/// Lets queued profile changes reach the server.
void setUpUser(ProviderContainer c) =>
    c.read(mutationSyncManagerProvider).registerSource('user_profile',
        UserRemoteMutationSource(c.read(userRemoteDataSourceProvider)));
