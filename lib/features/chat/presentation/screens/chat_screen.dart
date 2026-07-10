import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../widgets/chat_action_card.dart';
import '../../../../core/constants/app_sizes.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.globalBackground,
      appBar: const AppHeader(
        title: 'Chat',
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          ChatActionCard(
            title: 'Daily Check-in (AI Chat)',
            subtitle: 'Health assistant',
            description:
                'Ask health questions, log how you\'re feeling,\nand get personalised guidance.',
            gradient: AppColors.orangeGradient,
            onTap: () {
              context.push(RoutePaths.aiChat);
            },
          ),
          const SizedBox(height: 16),
          ChatActionCard(
            title: 'Healthcare Professional',
            subtitle: 'Direct messaging',
            description:
                'Send a message directly to your assigned\nHealthcare Professional.',
            gradient: AppColors.greenGradient,
            badgeText: 'Coming soon',
            onTap: () {},
          ),
          const SizedBox(height: 40),
          const AppText.labelMedium(
            'RECENT MESSAGES',
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
                const AppText.bodyMedium(
                  'No recent messages.',
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
