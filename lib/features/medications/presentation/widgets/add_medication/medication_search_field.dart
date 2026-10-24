import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/forms/search_suggestions.dart';
import 'package:yelima/features/medications/domain/models/seeded_medication_model.dart';
import '../../controllers/add_medication_form_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';

/// Medication name field that suggests known medications as the user types.
class MedicationSearchField extends StatefulWidget {
  const MedicationSearchField({super.key});

  @override
  State<MedicationSearchField> createState() => _MedicationSearchFieldState();
}

class _MedicationSearchFieldState extends State<MedicationSearchField> {
  final _search = LatestSearch();

  /// Autocomplete owns its text field; its text is copied into the form's name.
  TextEditingController? _bound;

  @override
  Widget build(BuildContext context) {
    final formController = context.read<AddMedicationFormController>();

    return Autocomplete<SeededMedicationModel>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        final query = textEditingValue.text.trim();
        if (query.isEmpty) {
          return const Iterable<SeededMedicationModel>.empty();
        }

        final found = await _search.run(() => formController.search(query));
        return found == null || !mounted
            ? const Iterable<SeededMedicationModel>.empty()
            : found;
      },
      displayStringForOption: (SeededMedicationModel option) => option.name,
      onSelected: (SeededMedicationModel selection) {
        formController.pick(selection);
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SuggestionList(
            width: MediaQuery.of(context).size.width - 48,
            items: [for (final o in options) o.name],
            onTap: (i) => onSelected(options.elementAt(i)),
          ),
        ),
      ),
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        if (_bound != textEditingController) {
          _bound = textEditingController;
          textEditingController.addListener(() {
            formController.nameController.text = textEditingController.text;
            final picked = formController.picked;
            if (picked != null && textEditingController.text != picked.name) {
              formController.pick(null);
            }
          });
        }

        return AppFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (_) => onFieldSubmitted(),
          label: context.l10n.medicationLabel,
          hintText: context.l10n.searchOrEnterMedicationName,
          prefixIcon: Icons.search,
          isRequired: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) =>
              v == null || v.trim().isEmpty ? context.l10n.requiredField : null,
        );
      },
    );
  }
}
