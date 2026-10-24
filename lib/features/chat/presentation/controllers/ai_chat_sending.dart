part of 'ai_chat_controller.dart';

/// Sending text and voice notes: shown at once, then updated from the server's reply.
extension AiChatSending on AiChatController {
  /// Sends a text message; a retry passes the failed message's [localChatId].
  Future<void> sendMessage(String text, {String? localChatId}) async {
    if (text.trim().isEmpty) return;
    await _send(
      localChatId,
      (localId) => AiChatMessage(
        id: localId,
        sender: 'user',
        type: MessageType.text,
        value: text,
        createdAt: clock.now(),
        status: MessageStatus.sending,
        localChatId: localId,
      ),
      (localId) => _repository.sendMessage(text, localChatId: localId),
    );
  }

  /// Sends a voice note; a retry passes the failed message's [localChatId].
  Future<void> sendAudioMessage(String filePath,
      {String durationStr = "Voice Message", String? localChatId}) async {
    await _send(
      localChatId,
      (localId) => AiChatMessage(
        id: localId,
        sender: 'user',
        type: MessageType.audio,
        value: durationStr,
        createdAt: clock.now(),
        status: MessageStatus.sending,
        localChatId: localId,
        audioUrl: filePath,
      ),
      (localId) => _repository.sendAudioMessage(
          filePath: filePath, localChatId: localId),
    );
  }

  /// Shows [draft] optimistically, sends it, then applies the server's reply.
  ///
  /// The same [reuseId] on a retry lets the server answer once, not twice.
  Future<void> _send(
    String? reuseId,
    AiChatMessage Function(String localId) draft,
    AsyncResult<ChatReply> Function(String localId) call,
  ) async {
    if (state.isSending) return;

    state = state.copyWith(isSending: true);
    if (_activeSync != null) await _activeSync;

    final localId = reuseId ?? const Uuid().v4();
    state = state.copyWith(messages: [draft(localId), ...state.messages]);

    final res = await call(localId);
    // Closed (e.g. logout) while waiting: don't write into the next session.
    if (isDisposed) return;
    final msgs = List<AiChatMessage>.from(state.messages);
    final index = msgs.indexWhere((m) => m.localChatId == localId);

    res.fold(
      (err) {
        if (index != -1) {
          msgs[index] = msgs[index].copyWith(status: MessageStatus.failed);
        }
        state = state.copyWith(messages: msgs, isSending: false, error: err);
      },
      (reply) {
        final bot = reply.bot;
        if (index != -1) {
          msgs[index] = msgs[index].copyWith(
            id: reply.userMessageId ?? msgs[index].id,
            // No answer yet means the send was queued for later.
            status: bot == null ? MessageStatus.sending : MessageStatus.sent,
          );
        }
        if (bot != null) {
          msgs
            ..removeWhere((m) => m.id == bot.id)
            ..insert(0, bot);
        }
        state = state.copyWith(messages: msgs, isSending: false);
      },
    );
    await _repository.saveConversations(msgs);
    _triggerPendingSyncIfAny();
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

    final id = failedMsg.localChatId;
    if (failedMsg.type == MessageType.audio && failedMsg.audioUrl != null) {
      await sendAudioMessage(failedMsg.audioUrl!, localChatId: id);
    } else {
      await sendMessage(failedMsg.value, localChatId: id);
    }
  }
}
