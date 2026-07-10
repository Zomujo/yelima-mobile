import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: AppText.bodyMedium(
            'or use email',
            color: Color(0xFF94A3B8),
          ),
        ),
        Expanded(
          child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
        ),
      ],
    );
  }
}
