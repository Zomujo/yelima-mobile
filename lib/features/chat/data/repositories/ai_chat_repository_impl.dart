import 'package:clock/clock.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/failures/guard.dart';
import '../../../../core/managers/deletion_sync_manager.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/file_service.dart';
import '../../../../core/services/session_epoch.dart';
import '../../../../core/services/session_lifecycle_service.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/paginated_chat_result.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/ai_chat_local_datasource.dart';
import '../datasources/ai_chat_remote_datasource.dart';
import '../models/ai_chat_response.dart';
import '../services/audio_cache.dart';

/// Offline-first [AiChatRepository]; clears the chat and its voice notes when a session ends.
class AiChatRepositoryImpl
    implements AiChatRepository, SessionLifecycleHandler {
  AiChatRepositoryImpl({
    required AiChatLocalDataSource localDataSource,
    required AiChatRemoteDataSource remoteDataSource,
    required DeletionSyncManager deletionSyncManager,
    required ConnectivityService connectivityService,
    required MutationSyncManager mutationSyncManager,
    required FileService fileService,
    required AudioCache audioCache,
    required SessionEpoch session,
  })  : _local = localDataSource,
        _remote = remoteDataSource,
        _deletions = deletionSyncManager,
        _connectivity = connectivityService,
        _sync = mutationSyncManager,
        _files = fileService,
        _audio = audioCache,
        _session = session;

  final AiChatLocalDataSource _local;
  final AiChatRemoteDataSource _remote;
  final DeletionSyncManager _deletions;
  final ConnectivityService _connectivity;
  final MutationSyncManager _sync;
  final FileService _files;
  final AudioCache _audio;
  final SessionEpoch _session;

  @override
  String get serviceName => 'AiChat Repository';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async {
    try {
      for (final msg in await _local.getChats()) {
        if (msg.type == MessageType.audio) {
          await _files.deleteLocalAudioFile(msg.audioUrl);
        }
      }
      await _local.clearChats();
      // Cached voice notes too, before the database wipe drops the list of them.
      await _audio.clear();
    } catch (_) {}
  }

  @override
  Stream<void> get onSynced => _sync.onMutationSynced
      .where((e) => e == 'chat' || e.startsWith('remap:chat:'));

  @override
  AsyncResult<PaginatedChatResult> fetchPaginatedConversations(
          {required int page}) =>
      guardOnline(_connectivity, () async {
        final data = AiChatData.fromJson(await _remote.fetchChats(page: page));
        return PaginatedChatResult(
            messages: [for (final row in data.rows) row.toEntity()],
            totalPages: data.totalPages);
      });

  @override
  AsyncResult<List<AiChatMessage>> loadConversations() =>
      guard(_local.getChats);

  @override
  AsyncResult<void> saveConversations(List<AiChatMessage> conversations) =>
      guard(() => _local.saveChats(conversations));

  @override
  AsyncResult<void> deleteLocalMessageOnly(String id) =>
      guard(() => _local.deleteChat(id));

  @override
  AsyncResult<void> deleteMessage(String id) => guard(() async {
        final message =
            (await _local.getChats()).where((m) => m.id == id).firstOrNull;
        if (message?.type == MessageType.audio) {
          await _files.deleteLocalAudioFile(message!.audioUrl);
        }
        await _local.deleteChat(id);
        await _local.queueDeletion(id);
        _deletions.triggerSync();
      });

  @override
  AsyncResult<ChatReply> sendMessage(String message, {String? localChatId}) =>
      _sendOrQueue(
          'sendMessage',
          {'message': message, 'localChatId': localChatId},
          localChatId,
          () => _remote.sendMessage(message, localChatId: localChatId));

  @override
  AsyncResult<ChatReply> sendAudioMessage(
          {required String filePath, String? localChatId}) =>
      _sendOrQueue(
          'sendAudioMessage',
          // Only the file name: the app folder path can change between launches.
          {'filePath': filePath.split('/').last, 'localChatId': localChatId},
          localChatId,
          () => _remote.sendAudioMessage(
              filePath: filePath, localChatId: localChatId));

  /// Sends now, or queues the send when offline or when it fails; only a lost login is reported.
  AsyncResult<ChatReply> _sendOrQueue(
          String action,
          Map<String, dynamic> payload,
          String? localChatId,
          Future<Map<String, dynamic>> Function() send) =>
      guard(() async {
        if (await _connectivity.isConnected) {
          try {
            return chatReplyFromJson(await send(), localChatId);
          } catch (e) {
            if (AppFailure.from(e) is UnauthorizedFailure) rethrow;
          }
        }
        await _local.queueSend(
            entityId: localChatId ??
                'offline_chat_${clock.now().millisecondsSinceEpoch}',
            action: action,
            payload: payload);
        _sync.triggerSync();
        return const ChatReply.queued();
      });

  @override
  AsyncResult<AiChatMessage?> loadInitialMessage() =>
      guardOnline(_connectivity, () async {
        final json = await _remote.getInitialMessage();
        return json == null ? null : botMessageFromJson(json);
      });

  @override
  Future<String?> cachedAudioPath(List<String> ids) => _audio.pathFor(ids);

  @override
  AsyncResult<String> downloadAudio(String url, List<String> ids) =>
      guardOnline(_connectivity, () => _audio.download(url, ids));

  @override
  AsyncResult<void> syncRemoteConversations() =>
      guardOnline(_connectivity, () async {
        final epoch = _session.current;
        final data = AiChatData.fromJson(await _remote.fetchChats(page: 1));
        _session.ensure(epoch);

        final pendingDeletions = await _local.getPendingDeletions();
        final remoteMessages = [
          for (final row in data.rows)
            if (!pendingDeletions.contains(row.id)) row.toEntity()
        ];
        final localMessages = await _local.getChats();

        final messagesToKeep =
            _getPendingAndFailedLocalMessages(localMessages, remoteMessages);
        _mergeLocalDataIntoRemote(remoteMessages, localMessages);
        messagesToKeep
            .addAll(_getOldLocalMessages(localMessages, remoteMessages));

        await _purgeUnlinkedMediaAssets(
            localMessages, remoteMessages, messagesToKeep);

        await _local.clearChats();
        await _local.saveChats([...remoteMessages, ...messagesToKeep]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
      });

  List<AiChatMessage> _getPendingAndFailedLocalMessages(
      List<AiChatMessage> localMessages, List<AiChatMessage> remoteMessages) {
    final remoteMessageIds = remoteMessages.map((m) => m.id).toSet();
    final remoteLocalIds = remoteMessages
        .where((m) => m.localChatId != null)
        .map((m) => m.localChatId!)
        .toSet();

    final messagesToKeep = <AiChatMessage>[];
    for (final localMsg in localMessages) {
      if (localMsg.status != MessageStatus.failed &&
          localMsg.status != MessageStatus.sending) {
        continue;
      }

      final isDuplicate = remoteMessageIds.contains(localMsg.id) ||
          (localMsg.localChatId != null &&
              remoteLocalIds.contains(localMsg.localChatId));

      if (!isDuplicate) {
        messagesToKeep.add(localMsg);
      }
    }
    return messagesToKeep;
  }

  void _mergeLocalDataIntoRemote(
      List<AiChatMessage> remoteMessages, List<AiChatMessage> localMessages) {
    for (int i = 0; i < remoteMessages.length; i++) {
      final remoteMsg = remoteMessages[i];
      final localMsg = localMessages
          .where((m) =>
              m.id == remoteMsg.id ||
              (m.localChatId != null && m.localChatId == remoteMsg.localChatId))
          .firstOrNull;

      if (localMsg != null) {
        remoteMessages[i] = remoteMsg.copyWith(
          type: localMsg.type == MessageType.audio
              ? MessageType.audio
              : remoteMsg.type,
          audioUrl: remoteMsg.audioUrl ?? localMsg.audioUrl,
          suggestions: remoteMsg.suggestions.isEmpty
              ? localMsg.suggestions
              : remoteMsg.suggestions,
        );
      }
    }
  }

  List<AiChatMessage> _getOldLocalMessages(
      List<AiChatMessage> localMessages, List<AiChatMessage> remoteMessages) {
    DateTime? oldestRemote;
    if (remoteMessages.isNotEmpty) {
      oldestRemote = remoteMessages.last.createdAt;
      for (final m in remoteMessages) {
        if (m.createdAt.isBefore(oldestRemote!)) {
          oldestRemote = m.createdAt;
        }
      }
    }

    return localMessages.where((localMsg) {
      if (oldestRemote == null) return false;
      if (localMsg.status == MessageStatus.failed ||
          localMsg.status == MessageStatus.sending) {
        return false;
      }
      return localMsg.createdAt.isBefore(oldestRemote);
    }).toList();
  }

  Future<void> _purgeUnlinkedMediaAssets(
      List<AiChatMessage> localMessages,
      List<AiChatMessage> remoteMessages,
      List<AiChatMessage> messagesToKeep) async {
    final idsToKeep = messagesToKeep.map((m) => m.id).toSet();
    final remoteIds = remoteMessages.map((m) => m.id).toSet();

    for (final localMsg in localMessages) {
      if (!idsToKeep.contains(localMsg.id) &&
          !remoteIds.contains(localMsg.id)) {
        if (localMsg.type == MessageType.audio) {
          await _files.deleteLocalAudioFile(localMsg.audioUrl);
        }
      }
    }
  }
}
