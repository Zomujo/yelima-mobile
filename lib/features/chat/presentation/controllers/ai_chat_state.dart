import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/ai_chat_message.dart';

part 'ai_chat_state.freezed.dart';

/// The chat screen's messages and loading flags.
@freezed
abstract class AiChatState with _$AiChatState {
  const factory AiChatState({
    @Default([]) List<AiChatMessage> messages,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMoreMessages,
    @Default(true) bool isOnline,
    @Default(false) bool isSending,
    @Default(false) bool syncPending,
    AppFailure? error,
    @Default(1) int currentPage,
  }) = _AiChatState;
}
