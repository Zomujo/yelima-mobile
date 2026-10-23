import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../../user/presentation/widgets/user_avatar.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// The patient's name, id, age and gender.
class HealthProfileCard extends StatelessWidget {
  final UserEntity user;

  const HealthProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final age =
        user.age == null ? l10n.notAvailable : '${user.age} ${l10n.yrs}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UserAvatar(user: user, size: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.titleMedium(user.fullName,
                        fontWeight: FontWeight.w600),
                    const SizedBox(height: 4),
                    AppText.bodySmall(
                        '${context.l10n.patientId}: ${user.patientId}',
                        color: AppColors.slate500),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.slate200),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _InfoStat(label: l10n.age, value: age)),
                const VerticalDivider(
                    color: AppColors.slate200, thickness: 1, width: 32),
                Expanded(
                    child: _InfoStat(
                        label: l10n.gender,
                        value: l10n.genderName(user.gender))),
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
        AppText.bodySmall(label, color: AppColors.slate500),
        const SizedBox(height: 4),
        AppText.titleMedium(value, fontWeight: FontWeight.w600),
      ],
    );
  }
}
