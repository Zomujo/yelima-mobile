import 'package:get_it/get_it.dart';

import '../../core/controllers/locale_controller.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/managers/deletion_sync_manager.dart';
import '../../core/managers/mutation_sync_manager.dart';
import '../../core/services/session_lifecycle_service.dart';
import 'data/datasources/ai_chat_local_datasource.dart';
import 'data/datasources/ai_chat_remote_datasource.dart';
import 'data/datasources/ai_chat_remote_mutation_source.dart';
import 'data/repositories/ai_chat_repository_impl.dart';
import 'data/services/audio_cache.dart';
import 'domain/repositories/ai_chat_repository.dart';

/// Registers the chat feature.
void initChat(GetIt sl) {
  sl.registerLazySingleton(() => AiChatLocalDataSource(sl()));
  sl.registerLazySingleton(() => AiChatRemoteDataSource(sl(),
      languageCode: () => l10nFor(sl<LocaleController>().locale).localeName));
  sl<DeletionSyncManager>()
      .registerSource('chat', sl<AiChatRemoteDataSource>());

  final repository = AiChatRepositoryImpl(
    localDataSource: sl(),
    remoteDataSource: sl(),
    deletionSyncManager: sl(),
    connectivityService: sl(),
    mutationSyncManager: sl(),
    fileService: sl(),
    audioCache: AudioCache(sl()),
    session: sl(),
  );
  sl.registerSingleton<AiChatRepository>(repository);
  sl<SessionLifecycleService>().register(repository, priority: 70);

  // Registered last: the source needs this feature's datasources above.
  sl<MutationSyncManager>()
      .registerSource('chat', AiChatRemoteMutationSource(sl(), sl()));
}
