import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import 'ai_chat_state.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../../../core/managers/mutation_sync_manager.dart';

class AiChatController extends ChangeNotifier with SafeNotifier {
  final AiChatRepository _repository;
  final ConnectivityService _connectivityService;
  final MutationSyncManager _mutationSyncManager;

  AiChatController(
      this._repository, this._connectivityService, this._mutationSyncManager) {
    _init();
  }

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<String>? _syncSubscription;
  Future<void>? _activeSync;

  AiChatState _state = const AiChatState();
  AiChatState get state => _state;

  set state(AiChatState value) {
    if (_state == value) return;
    _state = value;
    if (!_state.syncPending) {
      notifyListeners();
    }
  }

  // Expose messages and booleans for compatibility with UI (to minimize UI breakage)
  List<AiChatMessage> get messages => state.messages;
  bool get isLoading => state.isLoading;
  bool get isLoadingMore => state.isLoadingMore;
  bool get hasMoreMessages => state.hasMoreMessages;
  bool get isOnline => state.isOnline;
  bool get isSending => state.isSending;
  String? get error => state.error;

  void clearError() {
    state = state.copyWith(error: null);
  }

  static const int _pageSize = 20;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final isConnected = await _connectivityService.isConnected;
    state = state.copyWith(isOnline: isConnected);

    // Listen for connection changes
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      final wasOffline = !state.isOnline;
      state = state.copyWith(isOnline: isConnected);

      if (isConnected && wasOffline) {
        syncConversations();
      }
    });

    // Listen for background sync completion
    _syncSubscription =
        _mutationSyncManager.onMutationSynced.listen((entityType) {
      if (entityType == 'chat' || entityType == 'ai_chat_message') {
        syncConversations();
      }
    });

    await syncConversations();
  }

  /// Synchronizes local chat conversations with the remote server.
  Future<void> syncConversations() async {
    if (state.isSending || state.isLoadingMore) {
      state = state.copyWith(syncPending: true);
      return;
    }

    final future = _syncConversationsInternal();
    _activeSync = future;
    try {
      await future;
    } finally {
      _activeSync = null;
    }
  }

  Future<void> _syncConversationsInternal() async {
    state = state.copyWith(isLoading: true);

    final localRes = await _repository.loadConversations();
    localRes.fold(
      (err) => state = state.copyWith(error: err, isLoading: false),
      (localMsgs) async {
        var msgs = List<AiChatMessage>.from(localMsgs);

        bool stateChanged = false;
        for (int i = 0; i < msgs.length; i++) {
          if (msgs[i].status == MessageStatus.sending) {
            msgs[i] = msgs[i].copyWith(status: MessageStatus.failed);
            stateChanged = true;
          }
        }
        if (stateChanged) {
          await _repository.saveConversations(msgs);
        }

        int currentPage = state.currentPage;
        if (msgs.isNotEmpty) {
          currentPage = (msgs.length / _pageSize).ceil();
          if (currentPage < 1) currentPage = 1;
        }

        state = state.copyWith(messages: msgs, currentPage: currentPage);

        if (!state.isOnline) {
          state = state.copyWith(isLoading: false);
          return;
        }

        await _repository.syncRemoteConversations();

        final newLocalRes = await _repository.loadConversations();
        newLocalRes.fold(
          (err) => state = state.copyWith(error: err, isLoading: false),
          (newLocalMsgs) async {
            msgs = List.from(newLocalMsgs);

            if (msgs.isEmpty) {
              final initialRes = await _repository.loadInitialMessage();
              initialRes.fold(
                (err) {
                  // Ignore offline errors during background sync
                  if (err.contains('No internet connection')) {
                    state = state.copyWith(isLoading: false);
                  } else {
                    state = state.copyWith(error: err, isLoading: false);
                  }
                },
                (initialMsg) async {
                  if (initialMsg != null) {
                    msgs = [initialMsg];
                    await _repository.saveConversations(msgs);
                  }
                  state = state.copyWith(messages: msgs, isLoading: false);
                },
              );
            } else {
              state = state.copyWith(messages: msgs, isLoading: false);
            }
          },
        );
      },
    );
  }

  /// Fetches older paginated conversations from the database.
  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMoreMessages) return;

    state = state.copyWith(isLoadingMore: true);
    if (_activeSync != null) await _activeSync;

    final targetPage = state.currentPage + 1;
    final result =
        await _repository.fetchPaginatedConversations(page: targetPage);

    result.fold(
      (err) {
        state = state.copyWith(error: err, isLoadingMore: false);
        _triggerPendingSyncIfAny();
      },
      (paginated) async {
        if (paginated.messages.isNotEmpty) {
          paginated.messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          final updatedConversations = [
            ...state.messages,
            ...paginated.messages
          ];
          final uniqueMessages = <String, AiChatMessage>{};

          for (var msg in updatedConversations) {
            uniqueMessages[msg.id] = msg;
          }

          final newMessages = uniqueMessages.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          await _repository.saveConversations(newMessages);

          state = state.copyWith(
            messages: newMessages,
            currentPage: targetPage,
            hasMoreMessages: targetPage < paginated.totalPages,
            isLoadingMore: false,
          );
        } else {
          state = state.copyWith(hasMoreMessages: false, isLoadingMore: false);
        }
        _triggerPendingSyncIfAny();
      },
    );
  }

  void _triggerPendingSyncIfAny() {
    if (state.syncPending) {
      state = state.copyWith(syncPending: false);
      syncConversations();
    }
  }

  /// Sends a text message to the AI Chat API.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return;

    state = state.copyWith(isSending: true);
    if (_activeSync != null) await _activeSync;

    final localId = const Uuid().v4();
    final userMsg = AiChatMessage(
      id: localId,
      sender: 'user',
      type: MessageType.text,
      value: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      localChatId: localId,
    );

    state = state.copyWith(messages: [userMsg, ...state.messages]);

    final res = await _repository.sendMessage(text, localChatId: localId);

    res.fold(
      (err) {
        final msgs = List<AiChatMessage>.from(state.messages);
        final index = msgs.indexWhere((m) => m.localChatId == localId);

        if (index != -1) {
          msgs[index] = msgs[index].copyWith(status: MessageStatus.failed);
        }

        state = state.copyWith(messages: msgs, isSending: false, error: err);
        _repository.saveConversations(msgs);
        _triggerPendingSyncIfAny();
      },
      (botData) {
        final msgs = List<AiChatMessage>.from(state.messages);
        final index = msgs.indexWhere((m) => m.localChatId == localId);

        if (index != -1) {
          msgs[index] = msgs[index].copyWith(
              status:
                  botData.isEmpty ? MessageStatus.sending : MessageStatus.sent);
        }

        if (botData.isNotEmpty) {
          List<String> suggestions = [];
          if (botData['suggestions'] != null) {
            suggestions = List<String>.from(botData['suggestions']);
          }

          final botMsg = AiChatMessage(
            id: botData['_id'] as String,
            sender: 'bot',
            type: MessageType.text,
            value: botData['text'] as String,
            createdAt: DateTime.now(),
            status: MessageStatus.sent,
            suggestions: suggestions,
            localChatId: localId,
          );

          msgs.insert(0, botMsg);
        }

        state = state.copyWith(messages: msgs, isSending: false);
        _repository.saveConversations(msgs);
        _triggerPendingSyncIfAny();
      },
    );
  }

  /// Sends a voice note/audio file to the AI Chat API.
  Future<void> sendAudioMessage(String filePath,
      [String durationStr = "Voice Message"]) async {
    if (state.isSending) return;

    state = state.copyWith(isSending: true);
    if (_activeSync != null) await _activeSync;

    final localId = const Uuid().v4();
    final userMsg = AiChatMessage(
      id: localId,
      sender: 'user',
      type: MessageType.audio,
      value: durationStr,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      localChatId: localId,
      audioUrl: filePath,
    );

    state = state.copyWith(messages: [userMsg, ...state.messages]);

    final res = await _repository.sendAudioMessage(
        filePath: filePath, localChatId: localId);

    res.fold(
      (err) {
        final msgs = List<AiChatMessage>.from(state.messages);
        final index = msgs.indexWhere((m) => m.localChatId == localId);

        if (index != -1) {
          msgs[index] = msgs[index].copyWith(status: MessageStatus.failed);
        }

        state = state.copyWith(messages: msgs, isSending: false, error: err);
        _repository.saveConversations(msgs);
        _triggerPendingSyncIfAny();
      },
      (botData) async {
        final msgs = List<AiChatMessage>.from(state.messages);
        final index = msgs.indexWhere((m) => m.localChatId == localId);

        if (index != -1) {
          msgs[index] = msgs[index].copyWith(
              status:
                  botData.isEmpty ? MessageStatus.sending : MessageStatus.sent);
        }

        if (botData.isNotEmpty) {
          List<String> suggestions = [];
          if (botData['suggestions'] != null) {
            suggestions = List<String>.from(botData['suggestions']);
          }

          final botMsg = AiChatMessage(
            id: botData['_id'] as String,
            sender: 'bot',
            type: MessageType.text,
            value: botData['text'] as String,
            createdAt: DateTime.now(),
            status: MessageStatus.sent,
            suggestions: suggestions,
            localChatId: localId,
          );

          msgs.insert(0, botMsg);
        }

        state = state.copyWith(messages: msgs, isSending: false);
        _repository.saveConversations(msgs);
        _triggerPendingSyncIfAny();
      },
    );
  }

  /// Retries sending a previously failed message.
  Future<void> retryMessage(AiChatMessage failedMsg) async {
    if (state.isSending || state.isLoading) return;

    final updatedMessages = List<AiChatMessage>.from(state.messages);
    final index = updatedMessages.indexWhere((m) => m.id == failedMsg.id);

    if (index != -1) {
      updatedMessages.removeAt(index);
    }

    state = state.copyWith(messages: updatedMessages);
    _repository.deleteLocalMessageOnly(failedMsg.id);

    if (failedMsg.type == MessageType.audio && failedMsg.audioUrl != null) {
      await sendAudioMessage(failedMsg.audioUrl!);
    } else {
      await sendMessage(failedMsg.value);
    }
  }

  /// Deletes a chat message from local storage and state.
  Future<void> deleteMessage(String id) async {
    await _repository.deleteMessage(id);

    final updatedMessages = List<AiChatMessage>.from(state.messages);
    updatedMessages.removeWhere((msg) => msg.id == id);

    state = state.copyWith(messages: updatedMessages);
  }
}
