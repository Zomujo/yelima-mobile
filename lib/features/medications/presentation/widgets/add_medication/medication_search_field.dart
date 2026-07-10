import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../data/models/seeded_medication_model.dart';
import '../../controllers/add_medication_form_controller.dart';
import '../../controllers/all_medicines_controller.dart';

class MedicationSearchField extends StatefulWidget {
  const MedicationSearchField({super.key});

  @override
  State<MedicationSearchField> createState() => _MedicationSearchFieldState();
}

class _MedicationSearchFieldState extends State<MedicationSearchField> {
  int _searchToken = 0;

  @override
  Widget build(BuildContext context) {
    final formController = context.read<AddMedicationFormController>();
    
    return Consumer<AllMedicinesController>(
      builder: (context, controller, child) {
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

            await controller.fetchPreloadedMedications(search: query, limit: 20);

            final results = controller.preloadedState.data?.rows ?? [];
            return results.where((m) => m.name.toLowerCase().contains(query.toLowerCase()));
          },
          displayStringForOption: (SeededMedicationModel option) => option.name,
          onSelected: (SeededMedicationModel selection) {
            formController.updateSelectedPreloadedMedication(selection);
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
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 48,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        itemBuilder: (BuildContext context, int index) {
                          final SeededMedicationModel option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              child: AppText.bodyMedium(option.name, color: const Color(0xFF1E293B)),
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
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            formController.nameController.text = textEditingController.text;

            if (formController.boundSearchController != textEditingController) {
              formController.boundSearchController = textEditingController;
              textEditingController.addListener(() {
                formController.nameController.text = textEditingController.text;
                if (formController.state.selectedPreloadedMedication != null &&
                    textEditingController.text != formController.state.selectedPreloadedMedication!.name) {
                  formController.updateSelectedPreloadedMedication(null);
                }
              });
            }

            return AppFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (_) => onFieldSubmitted(),
              label: 'Medication',
              hintText: 'Search or enter medication name',
              prefixIcon: Icons.search,
              isRequired: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            );
          },
        );
      }
    );
  }
}
