import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import '../../core/extensions/l10n_extension.dart';
import 'data/datasources/ai_chat_local_datasource.dart';
import 'data/datasources/ai_chat_remote_datasource.dart';
import 'data/datasources/ai_chat_remote_mutation_source.dart';
import 'data/repositories/ai_chat_repository_impl.dart';
import 'data/services/audio_cache.dart';
import 'domain/repositories/ai_chat_repository.dart';

part 'chat_providers.g.dart';

/// Chat messages saved on the phone.
@Riverpod(keepAlive: true)
AiChatLocalDataSource aiChatLocalDataSource(Ref ref) =>
    AiChatLocalDataSource(ref.watch(appDatabaseProvider));

/// The AI chat on the server, answering in the app's language.
@Riverpod(keepAlive: true)
AiChatRemoteDataSource aiChatRemoteDataSource(Ref ref) =>
    AiChatRemoteDataSource(ref.watch(apiClientProvider),
        languageCode: () =>
            l10nFor(ref.read(localeControllerProvider)).localeName);

/// AI chat conversations, saved on the phone first and synced.
@Riverpod(keepAlive: true)
AiChatRepository aiChatRepository(Ref ref) => AiChatRepositoryImpl(
      localDataSource: ref.watch(aiChatLocalDataSourceProvider),
      remoteDataSource: ref.watch(aiChatRemoteDataSourceProvider),
      deletionSyncManager: ref.watch(deletionSyncManagerProvider),
      connectivityService: ref.watch(connectivityProvider),
      mutationSyncManager: ref.watch(mutationSyncManagerProvider),
      fileService: ref.watch(fileServiceProvider),
      audioCache: AudioCache(ref.watch(appDatabaseProvider)),
      session: ref.watch(sessionEpochProvider),
    )..also(
        (r) => ref.watch(sessionLifecycleProvider).register(r, priority: 70));

/// Lets queued chat changes and deletions reach the server.
void setUpChat(ProviderContainer c) {
  c.read(deletionSyncManagerProvider)
      .registerSource('chat', c.read(aiChatRemoteDataSourceProvider));
  c.read(aiChatRepositoryProvider);
  c.read(mutationSyncManagerProvider).registerSource(
      'chat',
      AiChatRemoteMutationSource(
          c.read(aiChatRemoteDataSourceProvider), c.read(appDatabaseProvider)));
}
