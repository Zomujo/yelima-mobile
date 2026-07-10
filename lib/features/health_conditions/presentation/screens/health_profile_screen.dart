import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_header.dart';
import '../../../user/presentation/controllers/user_controller.dart';
import '../widgets/health_profile_card.dart';
import '../widgets/health_expansion_card.dart';
import '../widgets/health_info_card.dart';

class HealthProfileScreen extends StatelessWidget {
  const HealthProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>().userEntity;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppHeader(
        title: 'Health Profile',
        onBackPressed: () => context.pop(),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              if (user != null) HealthProfileCard(user: user),
              const SizedBox(height: 24),
              // Chronic Conditions
              if (user != null && user.conditions.isNotEmpty)
                HealthExpansionCard(
                  title: 'Chronic Conditions',
                  icon: Iconsax.activity,
                  child: Column(
                    children: user.conditions.map((condition) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HealthInfoCard(
                          title: condition[0].toUpperCase() +
                              condition.substring(1),
                          status: 'Active',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              if (user != null && user.conditions.isEmpty)
                const HealthExpansionCard(
                  title: 'Chronic Conditions',
                  icon: Iconsax.activity,
                  child: AppText.bodyMedium(
                    'No chronic conditions reported.',
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
