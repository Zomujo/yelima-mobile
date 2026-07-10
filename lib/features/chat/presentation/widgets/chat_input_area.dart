import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../controllers/ai_chat_controller.dart';
import 'audio/voice_recorder_widget.dart';

class ChatInputArea extends StatefulWidget {
  const ChatInputArea({super.key});

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final TextEditingController _controller = TextEditingController();
  bool _isRecording = false;

  void _handleSend() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      context.read<AiChatController>().sendMessage(text);
      _controller.clear();
    }
  }

  Future<void> _handleStartRecording() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      setState(() {
        _isRecording = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Microphone permission is required to send voice messages.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return VoiceRecorderWidget(
        onClose: () {
          setState(() {
            _isRecording = false;
          });
        },
      );
    }

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.globalBackground,
      padding: EdgeInsets.only(
          top: 8, bottom: 16 + bottomInset, left: 24, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 48,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
              ),
              child: Consumer<AiChatController>(
                builder: (context, controller, child) {
                  return TextField(
                    controller: _controller,
                    readOnly: controller.isSending,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    onSubmitted:
                        controller.isSending ? null : (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: controller.isSending
                          ? 'Sending...'
                          : 'Type your reply...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8), // Slate 400
                        fontSize: 16,
                        fontFamily: 'ProductSans',
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<AiChatController>(
            builder: (context, controller, child) {
              return ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final isTyping = value.text.trim().isNotEmpty;
                  final isSending = controller.isSending;

                  return GestureDetector(
                    onTap: (isTyping && !isSending)
                        ? _handleSend
                        : (isSending ? null : _handleStartRecording),
                    child: Opacity(
                      opacity: isSending ? 0.5 : 1.0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isTyping
                              ? AppColors.primary
                              : const Color(0xFFF6A96C),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isTyping ? Icons.send : Icons.mic_none_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
