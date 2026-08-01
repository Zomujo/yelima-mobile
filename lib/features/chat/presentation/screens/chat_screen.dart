import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../widgets/chat_action_card.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: AppHeader(
        title: context.l10n.chatTitle,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          ChatActionCard(
            title: context.l10n.dailyCheckInAIChat,
            subtitle: context.l10n.healthAssistant,
            description: context.l10n.aiChatDescription,
            gradient: AppColors.orangeGradient,
            onTap: () {
              context.push(RoutePaths.aiChat);
            },
          ),
          const SizedBox(height: 16),
          ChatActionCard(
            title: context.l10n.healthcareProfessional,
            subtitle: context.l10n.directMessaging,
            description: context.l10n.hcpDescription,
            gradient: AppColors.greenGradient,
            badgeText: context.l10n.comingSoon,
            onTap: () {},
          ),
          const SizedBox(height: 40),
          AppText.labelMedium(
            context.l10n.recentMessages,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 84),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey.shade300,
                  size: 48,
                ),
                const SizedBox(height: 16),
                AppText.bodyMedium(
                  context.l10n.noRecentMessages,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
          // Bottom padding for navbar
          SizedBox(height: AppSizes.bottomNavClearance(context)),
        ],
      ),
    );
  }
}
