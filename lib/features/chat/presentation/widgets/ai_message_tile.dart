import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../controllers/ai_chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'audio/audio_message_bubble.dart';

class AiMessageTile extends StatelessWidget {
  final AiChatMessage message;

  const AiMessageTile({super.key, required this.message});

  void _showLongPressMenu(BuildContext context) {
    final chatController = context.read<AiChatController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.status == MessageStatus.failed)
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: const AppText.bodyMedium('Retry Message'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  if (message.localChatId != null) {
                    chatController.retryMessage(message);
                  }
                },
              ),
            if (message.status != MessageStatus.sending)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const AppText.bodyMedium('Delete Message',
                    color: Colors.red),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  chatController.deleteMessage(message.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: GestureDetector(
                onLongPress: () => _showLongPressMenu(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isUser ? const Radius.circular(4) : null,
                      bottomLeft: !isUser ? const Radius.circular(4) : null,
                    ),
                    border:
                        isUser ? null : Border.all(color: Colors.grey.shade300),
                  ),
                  child: message.type == MessageType.audio &&
                          message.audioUrl != null
                      ? AudioMessageBubble(
                          audioUrl: message.audioUrl!,
                          isUser: isUser,
                          durationString: message.value.isNotEmpty ? message.value : "00:00",
                          messageId: message.id,
                          localChatId: message.localChatId,
                        )
                      : (!isUser
                          ? MarkdownBody(
                              data: message.value,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontFamily: 'ProductSans',
                                ),
                                strong: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontFamily: 'ProductSans',
                                  fontWeight: FontWeight.bold,
                                ),
                                listBullet: const TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            )
                          : AppText.bodyMedium(
                              message.value,
                              color: Colors.white,
                            )),
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              if (message.status == MessageStatus.sending)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (message.status == MessageStatus.failed)
                GestureDetector(
                  onTap: () {
                    if (message.localChatId != null) {
                      context
                          .read<AiChatController>()
                          .retryMessage(message);
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      AppText.labelSmall('Retry', color: Colors.red),
                    ],
                  ),
                )
              else
                const Icon(Icons.check_circle,
                    size: 16, color: AppColors.primary),
            ],
          ],
        ),
        if (!isUser && message.suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40), // Align with bubble
            child: Consumer<AiChatController>(
              builder: (context, controller, child) {
                final isSending = controller.isSending;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: message.suggestions.map((suggestion) {
                    return ActionChip(
                      label: AppText.labelMedium(
                        suggestion,
                        color: isSending ? Colors.grey : Colors.black54,
                      ),
                      backgroundColor: isSending
                          ? Colors.grey.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSending ? Colors.grey : AppColors.primary,
                        ),
                      ),
                      onPressed: isSending
                          ? null
                          : () {
                              controller.sendMessage(suggestion);
                            },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
