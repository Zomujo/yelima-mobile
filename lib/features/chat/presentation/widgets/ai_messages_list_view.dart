import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../controllers/ai_chat_controller.dart';
import 'ai_message_tile.dart';
import 'date_separator.dart';

class AiMessagesListView extends StatefulWidget {
  const AiMessagesListView({super.key});

  @override
  State<AiMessagesListView> createState() => _AiMessagesListViewState();
}

class _AiMessagesListViewState extends State<AiMessagesListView> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.hasClients) {
      final show = _scrollController.position.pixels > 300;
      if (show != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = show;
        });
      }
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final controller = context.read<AiChatController>();
      if (!controller.isLoadingMore && controller.hasMoreMessages) {
        controller.loadMoreMessages();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiChatController>(
      builder: (context, controller, child) {
        final messages = controller.messages;

        if (controller.isLoading && messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (controller.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Loading more messages...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final message = messages[index];
                bool showDateSeparator = false;

                if (index == messages.length - 1) {
                  showDateSeparator = true;
                } else {
                  final olderMessage = messages[index + 1];
                  final currentMessageDate = DateTime(message.createdAt.year,
                      message.createdAt.month, message.createdAt.day);
                  final olderMessageDate = DateTime(olderMessage.createdAt.year,
                      olderMessage.createdAt.month, olderMessage.createdAt.day);

                  if (currentMessageDate != olderMessageDate) {
                    showDateSeparator = true;
                  }
                }

                if (showDateSeparator) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DateSeparator(date: message.createdAt),
                      AiMessageTile(
                        key: ValueKey(message.localChatId ?? message.id),
                        message: message,
                      ),
                    ],
                  );
                }

                return AiMessageTile(
                  key: ValueKey(message.localChatId ?? message.id),
                  message: message,
                );
              },
            ),

            // Scroll to bottom button
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedScale(
                scale: _showScrollToBottom ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: FloatingActionButton.small(
                  onPressed: _scrollToBottom,
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 4,
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
