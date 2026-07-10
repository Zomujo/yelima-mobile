import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../../shared/utils/app_snackbar.dart';
import '../../../../injection_container.dart';
import '../controllers/ai_chat_controller.dart';
import '../widgets/ai_messages_list_view.dart';
import '../widgets/chat_input_area.dart';

import '../../../home/presentation/controllers/home_metrics_controller.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late HomeMetricsController _homeMetricsController;
  late final AiChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = sl<AiChatController>()
      ..addListener(_onChatControllerChanged);
  }

  void _onChatControllerChanged() {
    final error = _chatController.error;
    if (error != null && mounted) {
      AppSnackBar.showError(context, message: error);
      _chatController.clearError();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeMetricsController = context.read<HomeMetricsController>();
  }

  @override
  void dispose() {
    _chatController.removeListener(_onChatControllerChanged);
    _chatController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _homeMetricsController.fetchMetrics();
      } catch (_) {}
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chatController,
      child: Scaffold(
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppHeader(
      onBackPressed: () => context.pop(),
      backgroundColor: AppColors.globalBackground,
      titleWidget: Row(
        children: [
          const AppText.titleLarge(
            'Daily Check-in',
            fontWeight: FontWeight.bold,
            color: Color(0xFF5E6875),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E0), // Light orange/beige background
              borderRadius: BorderRadius.circular(12),
            ),
            child: const AppText.labelMedium(
              'AI Chat',
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
