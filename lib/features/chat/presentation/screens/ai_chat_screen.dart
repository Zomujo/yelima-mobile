import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../../../../shared/utils/failure_message.dart';
import '../controllers/ai_chat_controller.dart';
import '../controllers/ai_chat_state.dart';
import '../widgets/ai_messages_list_view.dart';
import '../widgets/chat_input_area.dart';

import '../../../home/presentation/controllers/home_metrics_controller.dart';

/// The AI daily check-in chat.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  late final HomeMetricsController _homeMetricsController;

  @override
  void initState() {
    super.initState();
    _homeMetricsController = ref.read(homeMetricsControllerProvider.notifier);
  }

  void _onChatChanged(AiChatState? _, AiChatState chat) {
    final error = chat.error;
    if (error != null && mounted) {
      AppSnackBar.showError(context,
          message: error.message(context.l10n) ?? '');
      ref.read(aiChatControllerProvider.notifier).clearError();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _homeMetricsController.fetchMetrics();
      } catch (_) {}
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the chat alive while this screen is open and shows its errors.
    ref.listen(aiChatControllerProvider, _onChatChanged);
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: _buildAppBar(context),
      body: const Column(
        children: [
          Expanded(
            child: AiMessagesListView(),
          ),
          SafeArea(
            top: false,
            child: ChatInputArea(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppHeader(
      onBackPressed: () => context.pop(),
      backgroundColor: AppColors.globalBackground,
      titleWidget: Row(
        children: [
          AppText.titleLarge(
            context.l10n.dailyCheckInTitle,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5E6875),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppText.labelMedium(
              context.l10n.aiChat,
              color: AppColors.slate600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
