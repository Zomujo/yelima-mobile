import 'package:flutter/material.dart';

class RegistrationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onClose;

  const RegistrationAppBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 2,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Close Button
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Progress Bar
            Expanded(
              child: Row(
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFFFDBA74) : const Color(0xFFE2E8F0), // Orange vs Light Grey
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 16),
            
            // Step Indicator Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FCE3), // Mint green
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$currentStep of $totalSteps',
                style: const TextStyle(
                  color: Color(0xFF059669), // Dark emerald green text
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
