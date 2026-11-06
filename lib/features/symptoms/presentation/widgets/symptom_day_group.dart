import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_formats.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/motion/entrance.dart';
import '../../domain/entities/symptom_entity.dart';
import 'symptom_card.dart';

/// One day's label and its symptoms; the just-reported one slides in once.
class SymptomDayGroup extends StatelessWidget {
  const SymptomDayGroup({
    super.key,
    required this.day,
    required this.symptoms,
    this.arrivedId,
  });

  final DateTime day;
  final List<SymptomEntity> symptoms;

  /// The symptom that was just reported, if it is in this group.
  final String? arrivedId;

  @override
  Widget build(BuildContext context) {
    Widget card(SymptomEntity s) {
      final card = SymptomCard(
          key: ValueKey(s.id),
          content: s.description,
          time: AppDateFormats.timeShort.format(s.onsetDate.toLocal()));
      if (s.id != arrivedId) return card;
      // Drops into place from just above, once.
      return Entrance(rise: -12, playOnce: 'symptom/${s.id}', child: card);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 16),
          child: AppText.bodyMedium(
            context.l10n.dayLabel(day),
            color: AppColors.textGrey,
          ),
        ),
        for (final s in symptoms) card(s),
      ],
    );
  }
}
