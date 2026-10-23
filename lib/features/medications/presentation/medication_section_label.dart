import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../domain/entities/medication_section.dart';

/// The translated name of a dose section.
extension MedicationSectionLabel on MedicationSection {
  String label(AppLocalizations l10n) => switch (this) {
        MedicationSection.morning => l10n.morningLabel,
        MedicationSection.afternoon => l10n.afternoonLabel,
        MedicationSection.evening => l10n.eveningLabel,
      };
}
