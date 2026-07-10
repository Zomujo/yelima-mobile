import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../user/presentation/controllers/user_controller.dart';

class EditProfileAvatar extends StatelessWidget {
  const EditProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserController>().userEntity;
    final fullName = user?.fullName ?? 'Unknown User';
    final initial = user?.firstName?.isNotEmpty == true
        ? user!.firstName![0].toUpperCase()
        : (fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U');

    return Center(
      child: Container(
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
    );
  }
}
