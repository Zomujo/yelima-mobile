import 'package:fpdart/fpdart.dart';

import '../../../../core/utils/custom_types.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/managers/deletion_sync_manager.dart';
import '../datasources/ai_chat_local_datasource.dart';
import '../datasources/ai_chat_remote_datasource.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/entities/paginated_chat_result.dart';
import '../../../../core/services/session_lifecycle_service.dart';

import '../models/ai_chat_response.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/services/file_service.dart';

class AiChatRepositoryImpl
    implements AiChatRepository, SessionLifecycleHandler {
  final AiChatLocalDataSource _localDataSource;
  final AiChatRemoteDataSource _remoteDataSource;
  final DeletionSyncManager _deletionSyncManager;
  final ConnectivityService _connectivityService;
  final MutationSyncManager _mutationSyncManager;
  final FileService _fileService;

  AiChatRepositoryImpl({
    required AiChatLocalDataSource localDataSource,
    required AiChatRemoteDataSource remoteDataSource,
    required DeletionSyncManager deletionSyncManager,
    required ConnectivityService connectivityService,
    required MutationSyncManager mutationSyncManager,
    required FileService fileService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _deletionSyncManager = deletionSyncManager,
        _connectivityService = connectivityService,
        _mutationSyncManager = mutationSyncManager,
        _fileService = fileService;

  /// Returns the designated service name for this repository.
  @override
  String get serviceName => 'AiChat Repository';

  /// Lifecycle hook invoked when a user session begins.
  @override
  Future<void> onSessionStarted(String userId) async {}

  /// Lifecycle hook invoked when a user session ends, clearing local data.
  @override
  Future<void> onSessionEnded() async {
    try {
      final localMessages = await _localDataSource.getChats();
      for (final msg in localMessages) {
        if (msg.type == MessageType.audio) {
          await _fileService.deleteLocalAudioFile(msg.audioUrl);
        }
      }
      await _localDataSource.clearChats();
    } catch (_) {}
  }

  /// Fetches paginated AI conversations from the remote source.
  @override
  AsyncResponse<PaginatedChatResult> fetchPaginatedConversations(
      {required int page}) async {
    return ExceptionWrapper.runAsyncWithNetworkCheck(
      () async {
        final apiResponseJson =
            await _remoteDataSource.fetchChats(page: page, limit: 20);
        final responseData = AiChatData.fromJson(apiResponseJson);
        final messages =
            responseData.rows.map((row) => row.toEntity()).toList();
        return right(PaginatedChatResult(
          messages: messages,
          totalPages: responseData.totalPages,
        ));
      },
      connectivityService: _connectivityService,
    );
  }

  /// Loads all cached AI conversations from the local database.
  @override
  AsyncResponse<List<AiChatMessage>> loadConversations() async {
    return ExceptionWrapper.runAsync(() async {
      final chats = await _localDataSource.getChats();
      return right(chats);
    });
  }

  /// Persists a list of AI conversations directly into the local database.
  @override
  AsyncResponse<void> saveConversations(
      List<AiChatMessage> conversations) async {
    return ExceptionWrapper.runAsync(() async {
      await _localDataSource.saveChats(conversations);
      return right(null);
    });
  }

  /// Remove all AI conversations from the local database.
  @override
  AsyncResponse<void> clearConversations() async {
    return ExceptionWrapper.runAsync(() async {
      await _localDataSource.clearChats();
      return right(null);
    });
  }

  /// Deletes a specific message locally without notifying the remote source.
  @override
  AsyncResponse<void> deleteLocalMessageOnly(String id) async {
    return ExceptionWrapper.runAsync(() async {
      await _localDataSource.deleteChat(id);
      return right(null);
    });
  }

  /// Deletes a message locally and enqueues a deletion mutation for synchronization.
  @override
  AsyncResponse<void> deleteMessage(String id) async {
    return ExceptionWrapper.runAsync(() async {
      final chats = await _localDataSource.getChats();
      final message = chats.where((m) => m.id == id).firstOrNull;
      if (message != null && message.type == MessageType.audio) {
        await _fileService.deleteLocalAudioFile(message.audioUrl);
      }

      await _localDataSource.deleteChat(id);
      await _localDataSource.queueDeletion(id);
      _deletionSyncManager.triggerSync();
      return right(null);
    });
  }

  Future<Map<String, dynamic>> _executeWithOfflineFallback({
    required String action,
    required Map<String, dynamic> payload,
    String? localChatId,
    required Future<Map<String, dynamic>> Function() remoteCall,
  }) async {
    final isConnected = await _connectivityService.isConnected;

    if (!isConnected) {
      await _localDataSource.queueOfflineMessageMutation(
        entityId: localChatId ??
            'offline_chat_${DateTime.now().millisecondsSinceEpoch}',
        action: action,
        payload: payload,
      );
      _mutationSyncManager.triggerSync();
      return <String, dynamic>{};
    }

    try {
      return await remoteCall();
    } catch (e) {
      if (e is ApiException && (e.code == '401' || e.code == '403')) {
        rethrow;
      }

      await _localDataSource.queueOfflineMessageMutation(
        entityId: localChatId ??
            'offline_chat_${DateTime.now().millisecondsSinceEpoch}',
        action: action,
        payload: payload,
      );

      _mutationSyncManager.triggerSync();

      return <String, dynamic>{};
    }
  }

  /// Sends a text message to the AI, queuing it locally if offline.
  @override
  AsyncResponse<Map<String, dynamic>> sendMessage(String message,
      {String? localChatId}) async {
    return ExceptionWrapper.runAsync<Map<String, dynamic>>(
      () async {
        final res = await _executeWithOfflineFallback(
          action: 'sendMessage',
          payload: {'message': message, 'localChatId': localChatId},
          localChatId: localChatId,
          remoteCall: () =>
              _remoteDataSource.sendMessage(message, localChatId: localChatId),
        );
        return right(res);
      },
      operationName: 'AiChatRepositoryImpl.sendMessage',
    );
  }

  /// Sends an audio file message to the AI, queuing it locally if offline.
  @override
  AsyncResponse<Map<String, dynamic>> sendAudioMessage({
    required String filePath,
    String? localChatId,
  }) async {
    return ExceptionWrapper.runAsync<Map<String, dynamic>>(
      () async {
        final filename = filePath.split('/').last;
        final res = await _executeWithOfflineFallback(
          action: 'sendAudioMessage',
          payload: {'filePath': filename, 'localChatId': localChatId},
          localChatId: localChatId,
          remoteCall: () => _remoteDataSource.sendAudioMessage(
              filePath: filePath, localChatId: localChatId),
        );
        return right(res);
      },
      operationName: 'AiChatRepositoryImpl.sendAudioMessage',
    );
  }

  /// Fetches the initial AI greeting message from the remote source.
  @override
  AsyncResponse<AiChatMessage?> loadInitialMessage() async {
    return ExceptionWrapper.runAsyncWithNetworkCheck(
      () async {
        final messageData = await _remoteDataSource.getInitialMessage();
        if (messageData == null) return right(null);

        List<String> suggestions = [];
        if (messageData['suggestions'] != null) {
          suggestions = List<String>.from(messageData['suggestions']);
        }

        final msg = AiChatMessage(
          id: messageData['_id'] as String,
          sender: 'bot',
          type: MessageType.text,
          value: messageData['text'] as String,
          createdAt: messageData['createdAt'] == null
              ? DateTime.now()
              : DateTime.parse(messageData['createdAt'] as String),
          status: MessageStatus.sent,
          suggestions: suggestions,
        );
        return right(msg);
      },
      connectivityService: _connectivityService,
    );
  }

  /// Synchronizes remote chat history with local caching while preserving pending offline messages.
  @override
  AsyncResponse<void> syncRemoteConversations() async {
    return ExceptionWrapper.runAsyncWithNetworkCheck(
      () async {
        final apiResponseJson =
            await _remoteDataSource.fetchChats(page: 1, limit: 20);
        final responseData = AiChatData.fromJson(apiResponseJson);
        var remoteMessages =
            responseData.rows.map((row) => row.toEntity()).toList();

        final pendingDeletions = await _localDataSource.getPendingDeletions();
        remoteMessages = remoteMessages
            .where((m) => !pendingDeletions.contains(m.id))
            .toList();

        final localMessages = await _localDataSource.getChats();

        final messagesToKeep =
            _getPendingAndFailedLocalMessages(localMessages, remoteMessages);
        _mergeAudioUrlsFromLocal(remoteMessages, localMessages);
        messagesToKeep
            .addAll(_getOldLocalMessages(localMessages, remoteMessages));

        await _purgeUnlinkedMediaAssets(
            localMessages, remoteMessages, messagesToKeep);

        await _localDataSource.clearChats();

        final combined = [...remoteMessages, ...messagesToKeep];
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        await _localDataSource.saveChats(combined);
        return right(null);
      },
      connectivityService: _connectivityService,
    );
  }

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

      // Strict match based on real ID or localChatId
      final isDuplicate = remoteMessageIds.contains(localMsg.id) ||
          (localMsg.localChatId != null &&
              remoteLocalIds.contains(localMsg.localChatId));

      if (!isDuplicate) {
        messagesToKeep.add(localMsg);
      }
    }
    return messagesToKeep;
  }

  void _mergeAudioUrlsFromLocal(
      List<AiChatMessage> remoteMessages, List<AiChatMessage> localMessages) {
    for (int i = 0; i < remoteMessages.length; i++) {
      final remoteMsg = remoteMessages[i];
      final localMsg = localMessages
          .where((m) =>
              m.id == remoteMsg.id ||
              (m.localChatId != null && m.localChatId == remoteMsg.localChatId))
          .firstOrNull;

      if (localMsg != null && localMsg.type == MessageType.audio) {
        remoteMessages[i] = remoteMsg.copyWith(
          type: MessageType.audio,
          audioUrl: remoteMsg.audioUrl ?? localMsg.audioUrl,
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
          await _fileService.deleteLocalAudioFile(localMsg.audioUrl);
        }
      }
    }
  }
}
