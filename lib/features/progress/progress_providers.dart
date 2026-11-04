import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import 'data/datasources/progress_remote_datasource.dart';
import 'data/repositories/progress_repository_impl.dart';
import 'domain/repositories/progress_repository.dart';

part 'progress_providers.g.dart';

/// Vital trends from the server.
@Riverpod(keepAlive: true)
ProgressRemoteDataSource progressRemoteDataSource(Ref ref) =>
    ProgressRemoteDataSource(ref.watch(apiClientProvider));

/// Vital trends, cached and merged with readings on the phone.
@Riverpod(keepAlive: true)
ProgressRepository progressRepository(Ref ref) => ProgressRepositoryImpl(
      remoteDataSource: ref.watch(progressRemoteDataSourceProvider),
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
      session: ref.watch(sessionEpochProvider),
      recent: ref.watch(recentFetchesProvider),
    );
