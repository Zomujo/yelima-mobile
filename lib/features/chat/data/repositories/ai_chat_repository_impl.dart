import 'package:fpdart/fpdart.dart';

import '../../../../core/utils/custom_types.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/managers/deletion_sync_manager.dart';
import '../datasources/ai_chat_local_datasource.dart';
import '../datasources/ai_chat_remote_datasource.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/services/session_lifecycle_service.dart';

import '../models/ai_chat_response.dart';
import '../../../../core/managers/mutation_sync_manager.dart';
import '../../../../core/utils/file_helper.dart';
import 'package:get_it/get_it.dart';

class PaginatedChatResult {
  final List<AiChatMessage> messages;
  final int totalPages;

  PaginatedChatResult({required this.messages, required this.totalPages});
}

class AiChatRepositoryImpl
    implements AiChatRepository, SessionLifecycleHandler {
  final AiChatLocalDataSource _localDataSource;
  final AiChatRemoteDataSource _remoteDataSource;
  final DeletionSyncManager _deletionSyncManager;
  final ConnectivityService _connectivityService;
  final AppDatabase _db;

  AiChatRepositoryImpl({
    required AiChatLocalDataSource localDataSource,
    required AiChatRemoteDataSource remoteDataSource,
    required DeletionSyncManager deletionSyncManager,
    required ConnectivityService connectivityService,
    required AppDatabase db,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _deletionSyncManager = deletionSyncManager,
        _connectivityService = connectivityService,
        _db = db;

  @override
  String get serviceName => 'AiChat Repository';

  @override
  Future<void> onSessionStarted(String userId) async {}

  @override
  Future<void> onSessionEnded() async {
    try {
      final localMessages = await _localDataSource.getChats();
      for (final msg in localMessages) {
        if (msg.type == MessageType.audio) {
          await FileHelper.deleteLocalAudioFile(msg.audioUrl);
        }
      }
      await _localDataSource.clearChats();
    } catch (_) {}
  }

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

  @override
  AsyncResponse<List<AiChatMessage>> loadConversations() async {
    return ExceptionWrapper.runAsync(() async {
      final chats = await _localDataSource.getChats();
      return right(chats);
    });
  }

  @override
  AsyncResponse<void> saveConversations(
      List<AiChatMessage> conversations) async {
    return ExceptionWrapper.runAsync(() async {
      await _localDataSource.saveChats(conversations);
      return right(null);
    });
  }

  @override
  AsyncResponse<void> clearConversations() async {
    return ExceptionWrapper.runAsync(() async {
      await _localDataSource.clearChats();
      return right(null);
    });
  }

  @override
  AsyncResponse<void> deleteLocalMessageOnly(String id) async {
    return ExceptionWrapper.runAsync(() async {
      await _localDataSource.deleteChat(id);
      return right(null);
    });
  }

  @override
  AsyncResponse<void> deleteMessage(String id) async {
    return ExceptionWrapper.runAsync(() async {
      final chats = await _localDataSource.getChats();
      final message = chats.where((m) => m.id == id).firstOrNull;
      if (message != null && message.type == MessageType.audio) {
        await FileHelper.deleteLocalAudioFile(message.audioUrl);
      }

      await _localDataSource.deleteChat(id);
      await _localDataSource.queueDeletion(id);
      _deletionSyncManager.triggerSync();
      return right(null);
    });
  }

  @override
  AsyncResponse<Map<String, dynamic>> sendMessage(String message,
      {String? localChatId}) async {
    return ExceptionWrapper.runAsync<Map<String, dynamic>>(
      () async {
        final isConnected = await _connectivityService.isConnected;

        if (!isConnected) {
          await _db.pendingMutationsDao.queueMutation(
            entityId: localChatId ??
                'offline_chat_${DateTime.now().millisecondsSinceEpoch}',
            entityType: 'chat',
            action: 'sendMessage',
            payload: {
              'message': message,
              'localChatId': localChatId,
            },
          );
          try {
            if (GetIt.instance.isRegistered<MutationSyncManager>()) {
              GetIt.instance<MutationSyncManager>().triggerSync();
            }
          } catch (_) {}
          // Return a stub so the UI doesn't crash but knows it's pending
          return right({});
        }

        try {
          final res = await _remoteDataSource.sendMessage(message,
              localChatId: localChatId);
          return right(res);
        } catch (e) {
          await _db.pendingMutationsDao.queueMutation(
            entityId: localChatId ??
                'offline_chat_${DateTime.now().millisecondsSinceEpoch}',
            entityType: 'chat',
            action: 'sendMessage',
            payload: {
              'message': message,
              'localChatId': localChatId,
            },
          );
          if (e is ApiException && (e.code == '401' || e.code == '403')) {
            rethrow;
          }
          return right({});
        }
      },
      operationName: 'AiChatRepositoryImpl.sendMessage',
    );
  }

  @override
  AsyncResponse<Map<String, dynamic>> sendAudioMessage({
    required String filePath,
    String? localChatId,
  }) async {
    return ExceptionWrapper.runAsync<Map<String, dynamic>>(
      () async {
        final isConnected = await _connectivityService.isConnected;

        // Edge Case 25 fix: Always store filename rather than absolute path if possible
        final filename = filePath.split('/').last;

        if (!isConnected) {
          await _db.pendingMutationsDao.queueMutation(
            entityId: localChatId ??
                'offline_chat_${DateTime.now().millisecondsSinceEpoch}',
            entityType: 'chat',
            action: 'sendAudioMessage',
            payload: {
              'filePath': filename,
              'localChatId': localChatId,
            },
          );
          try {
            if (GetIt.instance.isRegistered<MutationSyncManager>()) {
              GetIt.instance<MutationSyncManager>().triggerSync();
            }
          } catch (_) {}
          return right({});
        }

        try {
          final res = await _remoteDataSource.sendAudioMessage(
            filePath: filePath,
            localChatId: localChatId,
          );
          return right(res);
        } catch (e) {
          await _db.pendingMutationsDao.queueMutation(
            entityId: localChatId ??
                'offline_chat_${DateTime.now().millisecondsSinceEpoch}',
            entityType: 'chat',
            action: 'sendAudioMessage',
            payload: {
              'filePath': filename,
              'localChatId': localChatId,
            },
          );
          if (e is ApiException && (e.code == '401' || e.code == '403')) {
            rethrow;
          }
          return right({});
        }
      },
      operationName: 'AiChatRepositoryImpl.sendAudioMessage',
    );
  }

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

        final remoteMessageIds = remoteMessages.map((m) => m.id).toSet();
        final localMessages = await _localDataSource.getChats();

        final messagesToKeep = <AiChatMessage>[];

        for (final localMsg in localMessages) {
          if (localMsg.status != MessageStatus.failed &&
              localMsg.status != MessageStatus.sending) {
            continue;
          }

          final isDuplicate = remoteMessageIds.contains(localMsg.id) ||
              (localMsg.localChatId != null &&
                  remoteMessages.any((remoteMsg) =>
                      remoteMsg.localChatId == localMsg.localChatId)) ||
              remoteMessages.any((remoteMsg) =>
                  remoteMsg.sender == localMsg.sender &&
                  remoteMsg.value == localMsg.value &&
                  remoteMsg.createdAt
                          .difference(localMsg.createdAt)
                          .inMinutes
                          .abs() <
                      5);

          if (!isDuplicate) {
            messagesToKeep.add(localMsg);
          }
        }

        for (int i = 0; i < remoteMessages.length; i++) {
          final remoteMsg = remoteMessages[i];
          final localMsg = localMessages
              .where((m) =>
                  m.id == remoteMsg.id ||
                  (m.localChatId != null &&
                      m.localChatId == remoteMsg.localChatId))
              .firstOrNull;

          if (localMsg != null) {
            if (localMsg.type == MessageType.audio) {
              remoteMessages[i] = remoteMsg.copyWith(
                type: MessageType.audio,
                audioUrl: remoteMsg.audioUrl ?? localMsg.audioUrl,
              );
            }
          }
        }

        DateTime? oldestRemote;
        if (remoteMessages.isNotEmpty) {
          oldestRemote = remoteMessages.last.createdAt;
          for (final m in remoteMessages) {
            if (m.createdAt.isBefore(oldestRemote!)) {
              oldestRemote = m.createdAt;
            }
          }
        }

        final oldLocalMessages = localMessages.where((localMsg) {
          if (oldestRemote == null) return false;
          if (localMsg.status == MessageStatus.failed ||
              localMsg.status == MessageStatus.sending) {
            return false;
          }
          return localMsg.createdAt.isBefore(oldestRemote);
        }).toList();

        messagesToKeep.addAll(oldLocalMessages);

        // Edge Case 26: Delete orphaned local audio files
        final idsToKeep = messagesToKeep.map((m) => m.id).toSet();
        final remoteIds = remoteMessages.map((m) => m.id).toSet();

        for (final localMsg in localMessages) {
          if (!idsToKeep.contains(localMsg.id) &&
              !remoteIds.contains(localMsg.id)) {
            // This message is being wiped.
            if (localMsg.type == MessageType.audio) {
              await FileHelper.deleteLocalAudioFile(localMsg.audioUrl);
            }
          }
        }

        await _localDataSource.clearChats();

        final combined = [...remoteMessages, ...messagesToKeep];
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        await _localDataSource.saveChats(combined);
        return right(null);
      },
      connectivityService: _connectivityService,
    );
  }
}
