import 'package:flutter/material.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_motion.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/widgets/motion/fade_switch.dart';

/// One dose in today's list, with its confirm button.
class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String purpose;
  final String time;
  final bool isTaken;
  final bool isOverdue;
  final bool isEarly;
  final bool isConfirming;
  final VoidCallback? onConfirm;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.purpose,
    required this.time,
    required this.isTaken,
    this.isOverdue = false,
    this.isEarly = false,
    this.isConfirming = false,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isOverdue
        ? Colors.red.shade300
        : (isTaken ? const Color(0xFF82C76F) : AppColors.slate100);
    final backgroundColor = isOverdue ? const Color(0xFFFEF2F2) : Colors.white;
    final timeColor = isOverdue ? Colors.red : AppColors.textGrey;

    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.medium),
      curve: AppMotion.move,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          if (!isTaken)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The pill icon folds away once the dose is taken.
          FadeSwitch(
            alignment: AlignmentDirectional.centerStart,
            child: isTaken
                ? const SizedBox.shrink()
                : _PillIcon(isOverdue: isOverdue),
          ),
          Expanded(child: _DoseInfo(card: this, timeColor: timeColor)),
          _DoseAction(card: this),
        ],
      ),
    );
  }
}

/// The pill badge at the start of a dose not yet taken.
class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.isOverdue});

  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.1)
              : AppColors.slate100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Image(image: AppImages.mediIcon, height: 20, width: 20),
        ),
      ),
    );
  }
}

/// The green tick shown once a dose is taken.
class _TakenTick extends StatelessWidget {
  const _TakenTick();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF82C76F), width: 2),
      ),
      child: const Icon(Icons.check, size: 18, color: Color(0xFF82C76F)),
    );
  }
}

/// Name, dosage, purpose and time of a dose.
class _DoseInfo extends StatelessWidget {
  const _DoseInfo({required this.card, required this.timeColor});

  final MedicationCard card;
  final Color timeColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: AppText.bodyLarge(card.name,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate800,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 4),
            AppText.bodyMedium(card.dosage, color: AppColors.textGrey),
          ],
        ),
        if (card.purpose.isNotEmpty) ...[
          const SizedBox(height: 4),
          AppText.labelMedium(
            card.purpose,
            color: const Color(0xFF8F9299),
            fontWeight: FontWeight.w200,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: timeColor),
            const SizedBox(width: 4),
            AppText.labelMedium(card.time, color: timeColor),
          ],
        ),
      ],
    );
  }
}

/// Confirm (or Wait) button, which turns into a spinner and then a tick.
class _DoseAction extends StatelessWidget {
  const _DoseAction({required this.card});

  final MedicationCard card;

  @override
  Widget build(BuildContext context) {
    return FadeSwitch(
      alignment: Alignment.center,
      scaleFrom: 0.6,
      child: switch ((card.isTaken, card.isConfirming)) {
        (true, _) => const _TakenTick(),
        (_, true) => const SizedBox(
            width: 36,
            height: 36,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        _ => AppButton(
            text: card.isEarly ? context.l10n.wait : context.l10n.confirm,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            borderRadius: 20,
            isDisabled: card.isEarly,
            onPressed: card.isEarly ? null : (card.onConfirm ?? () {}),
            fontSize: 14,
            backgroundColor: card.isEarly
                ? Colors.grey.shade400
                : (card.isOverdue ? Colors.red : AppColors.primary),
          ),
      },
    );
  }
}
