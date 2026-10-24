import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/failures/app_failure.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/safe_notifier.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/paginated_chat_result.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import 'ai_chat_state.dart';

part 'ai_chat_sending.dart';

/// The AI chat: history, paging, sending with offline queueing, retry and delete.
class AiChatController extends ChangeNotifier with SafeNotifier {
  AiChatController(this._repository, this._connectivityService) {
    _init();
  }

  final AiChatRepository _repository;
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;
  StreamSubscription<void>? _syncSubscription;
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

  List<AiChatMessage> get messages => state.messages;
  bool get isLoading => state.isLoading;
  bool get isLoadingMore => state.isLoadingMore;
  bool get hasMoreMessages => state.hasMoreMessages;
  bool get isOnline => state.isOnline;
  bool get isSending => state.isSending;
  AppFailure? get error => state.error;

  /// Marks the error as shown.
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

    _connectivitySubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      final wasOffline = !state.isOnline;
      state = state.copyWith(isOnline: isConnected);

      if (isConnected && wasOffline) {
        syncConversations();
      }
    });

    _syncSubscription = _repository.onSynced.listen((_) => syncConversations());

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
    await localRes.fold(
      (err) async => state = state.copyWith(error: err, isLoading: false),
      (localMsgs) async {
        final msgs = [
          for (final m in localMsgs)
            m.status == MessageStatus.sending
                ? m.copyWith(status: MessageStatus.failed)
                : m,
        ];
        if (localMsgs.any((m) => m.status == MessageStatus.sending)) {
          await _repository.saveConversations(msgs);
        }

        final currentPage =
            msgs.isEmpty ? state.currentPage : (msgs.length / _pageSize).ceil();
        state = state.copyWith(messages: msgs, currentPage: currentPage);

        if (!state.isOnline) {
          state = state.copyWith(isLoading: false);
          return;
        }

        await _repository.syncRemoteConversations();
        if (isDisposed) return;
        await _reloadAfterRemoteSync();
      },
    );
  }

  /// Reloads local messages after a remote sync, fetching the greeting for an empty chat.
  Future<void> _reloadAfterRemoteSync() async {
    final newLocalRes = await _repository.loadConversations();
    await newLocalRes.fold(
      (err) async => state = state.copyWith(error: err, isLoading: false),
      (msgs) async {
        if (msgs.isNotEmpty) {
          state = state.copyWith(messages: msgs, isLoading: false);
          return;
        }
        final initialRes = await _repository.loadInitialMessage();
        await initialRes.fold(
          (f) async => state = state.copyWith(
              // Being offline during a background sync is not worth a message.
              error: f is NetworkFailure ? null : f,
              isLoading: false),
          (initialMsg) async {
            final withGreeting = initialMsg == null ? msgs : [initialMsg];
            if (initialMsg != null) {
              await _repository.saveConversations(withGreeting);
            }
            state = state.copyWith(messages: withGreeting, isLoading: false);
          },
        );
      },
    );
  }

  /// Loads the next page of older messages from the server.
  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMoreMessages) return;

    state = state.copyWith(isLoadingMore: true);
    if (_activeSync != null) await _activeSync;

    final targetPage = state.currentPage + 1;
    final result =
        await _repository.fetchPaginatedConversations(page: targetPage);
    if (isDisposed) return;

    await result.fold(
      (err) async {
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

  /// Deletes a chat message from local storage and state.
  Future<void> deleteMessage(String id) async {
    await _repository.deleteMessage(id);

    final updatedMessages = List<AiChatMessage>.from(state.messages);
    updatedMessages.removeWhere((msg) => msg.id == id);

    state = state.copyWith(messages: updatedMessages);
  }
}
