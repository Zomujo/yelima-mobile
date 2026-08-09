import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../user/domain/entities/user_entity.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

class HealthProfileCard extends StatelessWidget {
  final UserEntity user;

  const HealthProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final initial =
        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U';
    final ageStr = user.age != null ? '${user.age} ${context.l10n.yrs}' : context.l10n.notAvailable;
    String genderStr = context.l10n.notAvailable;
    if (user.gender != null && user.gender!.isNotEmpty) {
      final g = user.gender!.toLowerCase();
      if (g == 'male') {
        genderStr = context.l10n.male;
      } else if (g == 'female') {
        genderStr = context.l10n.female;
      } else {
        genderStr = user.gender![0].toUpperCase() + user.gender!.substring(1).toLowerCase();
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium(user.fullName,
                        fontWeight: FontWeight.w600),
                    const SizedBox(height: 4),
                    AppText.bodySmall('${context.l10n.patientId}: ${user.patientId}',
                        color: const Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _InfoStat(label: context.l10n.age, value: ageStr)),
                const VerticalDivider(
                    color: Color(0xFFE2E8F0), thickness: 1, width: 32),
                Expanded(child: _InfoStat(label: context.l10n.gender, value: genderStr)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;

  const _InfoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppText.bodySmall(label, color: const Color(0xFF64748B)),
        const SizedBox(height: 4),
        AppText.titleMedium(value, fontWeight: FontWeight.w600),
      ],
    );
  }
}
