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

  AiChatController(this._repository, this._connectivityService, this._mutationSyncManager) {
    _init();
  }

  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<String>? _syncSubscription;
  Future<void>? _activeSync;

  AiChatState _state = const AiChatState();
  AiChatState get state => _state;

  void _setState(AiChatState newState) {
    _state = newState;
    if (!_state.syncPending) {
      notifyListeners();
    }
  }

  // Expose messages and booleans for compatibility with UI (to minimize UI breakage)
  List<AiChatMessage> get messages => _state.messages;
  bool get isLoading => _state.isLoading;
  bool get isLoadingMore => _state.isLoadingMore;
  bool get hasMoreMessages => _state.hasMoreMessages;
  bool get isOnline => _state.isOnline;
  bool get isSending => _state.isSending;
  String? get error => _state.error;

  void clearError() {
    _setState(_state.copyWith(error: null));
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
    _setState(_state.copyWith(isOnline: isConnected));

    // Listen for connection changes
    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      final wasOffline = !_state.isOnline;
      _setState(_state.copyWith(isOnline: isConnected));

      if (isConnected && wasOffline) {
        syncConversations();
      }
    });

    // Listen for background sync completion
    _syncSubscription = _mutationSyncManager.onMutationSynced.listen((entityType) {
      if (entityType == 'chat' || entityType == 'ai_chat_message') {
        syncConversations();
      }
    });

    await syncConversations();
  }

  Future<void> syncConversations() async {
    if (_state.isSending || _state.isLoadingMore) {
      _setState(_state.copyWith(syncPending: true));
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
    _setState(_state.copyWith(isLoading: true));

    final localRes = await _repository.loadConversations();
    localRes
        .fold((err) => _setState(_state.copyWith(error: err, isLoading: false)),
            (localMsgs) async {
      var messages = List<AiChatMessage>.from(localMsgs);

      bool stateChanged = false;
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].status == MessageStatus.sending) {
          messages[i] = messages[i].copyWith(status: MessageStatus.failed);
          stateChanged = true;
        }
      }
      if (stateChanged) {
        await _repository.saveConversations(messages);
      }

      int currentPage = _state.currentPage;
      if (messages.isNotEmpty) {
        currentPage = (messages.length / _pageSize).ceil();
        if (currentPage < 1) currentPage = 1;
      }

      _setState(_state.copyWith(
        messages: messages,
        currentPage: currentPage,
      ));

      if (!_state.isOnline) {
        _setState(_state.copyWith(isLoading: false));
        return;
      }

      await _repository.syncRemoteConversations();

      final newLocalRes = await _repository.loadConversations();
      newLocalRes.fold(
          (err) => _setState(_state.copyWith(error: err, isLoading: false)),
          (newLocalMsgs) async {
        messages = List.from(newLocalMsgs);

        if (messages.isEmpty) {
          final initialRes = await _repository.loadInitialMessage();
          initialRes.fold(
              (err) {
            // Ignore offline errors during background sync to avoid infinite snackbar loops
            if (err.contains('No internet connection')) {
              _setState(_state.copyWith(isLoading: false));
            } else {
              _setState(_state.copyWith(error: err, isLoading: false));
            }
          },
              (initialMsg) async {
            if (initialMsg != null) {
              messages = [initialMsg];
              await _repository.saveConversations(messages);
            }
            _setState(_state.copyWith(
              messages: messages,
              isLoading: false,
            ));
          });
        } else {
          _setState(_state.copyWith(
            messages: messages,
            isLoading: false,
          ));
        }
      });
    });
  }

  Future<void> loadMoreMessages() async {
    if (_state.isLoadingMore || !_state.hasMoreMessages) return;

    _setState(_state.copyWith(isLoadingMore: true));

    if (_activeSync != null) await _activeSync;

    final targetPage = _state.currentPage + 1;
    final result =
        await _repository.fetchPaginatedConversations(page: targetPage);

    result.fold((err) {
      _setState(_state.copyWith(
        error: err,
        isLoadingMore: false,
      ));
      _triggerPendingSyncIfAny();
    }, (paginated) async {
      if (paginated.messages.isNotEmpty) {
        paginated.messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final updatedConversations = [
          ..._state.messages,
          ...paginated.messages,
        ];

        final uniqueMessages = <String, AiChatMessage>{};
        for (var msg in updatedConversations) {
          uniqueMessages[msg.id] = msg;
        }

        final newMessages = uniqueMessages.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        await _repository.saveConversations(newMessages);

        _setState(_state.copyWith(
          messages: newMessages,
          currentPage: targetPage,
          hasMoreMessages: targetPage < paginated.totalPages,
          isLoadingMore: false,
        ));
      } else {
        _setState(_state.copyWith(
          hasMoreMessages: false,
          isLoadingMore: false,
        ));
      }
      _triggerPendingSyncIfAny();
    });
  }

  void _triggerPendingSyncIfAny() {
    if (_state.syncPending) {
      _setState(_state.copyWith(syncPending: false));
      syncConversations();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _state.isSending) return;

    _setState(_state.copyWith(isSending: true));

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

    _setState(_state.copyWith(
      messages: [userMsg, ..._state.messages],
    ));

    final res = await _repository.sendMessage(text, localChatId: localId);

    res.fold((err) {
      final messages = List<AiChatMessage>.from(_state.messages);
      final index = messages.indexWhere((m) => m.localChatId == localId);
      if (index != -1) {
        messages[index] =
            messages[index].copyWith(status: MessageStatus.failed);
      }
      _setState(_state.copyWith(
        messages: messages,
        isSending: false,
        error: err,
      ));
      _repository.saveConversations(messages);
      _triggerPendingSyncIfAny();
    }, (botData) {
      final messages = List<AiChatMessage>.from(_state.messages);

      final index = messages.indexWhere((m) => m.localChatId == localId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: botData.isEmpty ? MessageStatus.sending : MessageStatus.sent);
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

        messages.insert(0, botMsg);
      }
      
      _setState(_state.copyWith(
        messages: messages,
        isSending: false,
      ));
      _repository.saveConversations(messages);
      _triggerPendingSyncIfAny();
    });
  }

  Future<void> sendAudioMessage(String filePath,
      [String durationStr = "Voice Message"]) async {
    if (_state.isSending) return;

    _setState(_state.copyWith(isSending: true));

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

    _setState(_state.copyWith(
      messages: [userMsg, ..._state.messages],
    ));

    final res = await _repository.sendAudioMessage(
        filePath: filePath, localChatId: localId);

    res.fold((err) {
      final messages = List<AiChatMessage>.from(_state.messages);
      final index = messages.indexWhere((m) => m.localChatId == localId);
      if (index != -1) {
        messages[index] =
            messages[index].copyWith(status: MessageStatus.failed);
      }
      _setState(_state.copyWith(
        messages: messages,
        isSending: false,
        error: err,
      ));
      _repository.saveConversations(messages);
      _triggerPendingSyncIfAny();
    }, (botData) async {
      final messages = List<AiChatMessage>.from(_state.messages);

      final index = messages.indexWhere((m) => m.localChatId == localId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: botData.isEmpty ? MessageStatus.sending : MessageStatus.sent);
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

        messages.insert(0, botMsg);
      }

      _setState(_state.copyWith(
        messages: messages,
        isSending: false,
      ));
      _repository.saveConversations(messages);

      _triggerPendingSyncIfAny();
    });
  }

  Future<void> retryMessage(AiChatMessage failedMsg) async {
    if (_state.isSending || _state.isLoading) return;

    final updatedMessages = List<AiChatMessage>.from(_state.messages);
    final index = updatedMessages.indexWhere((m) => m.id == failedMsg.id);
    if (index != -1) {
      updatedMessages.removeAt(index);
    }
    _setState(_state.copyWith(messages: updatedMessages));
    _repository.deleteLocalMessageOnly(failedMsg.id);

    if (failedMsg.type == MessageType.audio && failedMsg.audioUrl != null) {
      await sendAudioMessage(failedMsg.audioUrl!);
    } else {
      await sendMessage(failedMsg.value);
    }
  }

  Future<void> deleteMessage(String id) async {
    await _repository.deleteMessage(id);

    final updatedMessages = List<AiChatMessage>.from(_state.messages);
    updatedMessages.removeWhere((msg) => msg.id == id);
    _setState(_state.copyWith(messages: updatedMessages));
  }
}
