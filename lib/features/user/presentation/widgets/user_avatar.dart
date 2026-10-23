import 'package:flutter/material.dart';

import '../../domain/entities/user_entity.dart';

/// A green circle with the patient's initial.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 100});

  final UserEntity? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = user?.initial ?? '';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF34D399), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(initial.isEmpty ? 'U' : initial,
          style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
    );
  }
}
