import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../user/presentation/controllers/user_controller.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>().userEntity;
    final fullName = user?.fullName ?? 'Unknown User';
    final initial = user?.firstName?.isNotEmpty == true
        ? user!.firstName![0].toUpperCase()
        : (fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U');

    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF34D399), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppText.titleLarge(
            fullName,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
          const SizedBox(height: 4),
          const AppText.bodyMedium(
            'Patient',
            color: Color(0xFF64748B),
          ),
        ],
      ),
    );
  }
}
