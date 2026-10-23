import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
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
  int _searchToken = 0;

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

          final token = ++_searchToken;
          await Future.delayed(const Duration(milliseconds: 350));
          if (token != _searchToken || !mounted) {
            return const Iterable<SeededMedicationModel>.empty();
          }

          return formController.search(query);
        },
        displayStringForOption: (SeededMedicationModel option) => option.name,
        onSelected: (SeededMedicationModel selection) {
          formController.pick(selection);
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                shadowColor: Colors.black.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.slate200),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 48,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: AppColors.slate200),
                      itemBuilder: (BuildContext context, int index) {
                        final SeededMedicationModel option =
                            options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                            child: AppText.bodyMedium(option.name,
                                color: AppColors.slate800),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
            validator: (v) => v == null || v.trim().isEmpty
                ? context.l10n.requiredField
                : null,
          );
        },
      );
  }
}
