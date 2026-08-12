import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../../../user/presentation/controllers/user_controller.dart';
import '../../../../user/domain/repositories/user_repository.dart';
import '../../../../user/data/models/facility_model.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/step_layout.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../core/extensions/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';

class RegistrationStepFour extends StatefulWidget {
  const RegistrationStepFour({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  State<RegistrationStepFour> createState() => _RegistrationStepFourState();
}

class _RegistrationStepFourState extends State<RegistrationStepFour> {
  bool _isSubmitting = false;
  FacilityModel? _selectedFacility;
  int _searchToken = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if needed, but facility might not be available yet.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isFormValid => _selectedFacility != null;

  void _handleContinue() async {
    if (!_isFormValid || _isSubmitting) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
    });

    final userController = context.read<UserController>();
    final response = await userController.submitOnboarding(
      context,
      facilityId: _selectedFacility!.id,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (response.isRight()) {
        widget.onContinue();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = GetIt.instance<UserRepository>();

    return StepLayout(
      title: context.l10n.selectFacilityTitle,
      subtitle: context.l10n.selectFacilitySubtitle,
      continueText: _isSubmitting ? context.l10n.savingText : context.l10n.continueText,
      isContinueEnabled: _isFormValid,
      isSubmitting: _isSubmitting,
      onContinue: _handleContinue,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<FacilityModel>(
            optionsBuilder: (TextEditingValue textEditingValue) async {
              final query = textEditingValue.text.trim();
              if (query.isEmpty) {
                return const Iterable<FacilityModel>.empty();
              }

              final token = ++_searchToken;
              await Future.delayed(const Duration(milliseconds: 350));
              if (token != _searchToken || !mounted) {
                return const Iterable<FacilityModel>.empty();
              }

              final result = await userRepository.getFacilities(search: query, pageSize: 20);
              return result.fold(
                (l) => const Iterable<FacilityModel>.empty(),
                (r) {
                  if (r.rows.isEmpty) {
                    return [FacilityModel(id: 'empty_result', name: context.l10n.noFacilitiesFound)];
                  }
                  return r.rows;
                },
              );
            },
            displayStringForOption: (FacilityModel option) => option.name,
            onSelected: (FacilityModel selection) {
              if (selection.id == 'empty_result') return;
              setState(() {
                _selectedFacility = selection;
              });
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
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          itemBuilder: (BuildContext context, int index) {
                            final FacilityModel option = options.elementAt(index);
                            
                            if (option.id == 'empty_result') {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                child: AppText.bodyMedium(
                                  option.name,
                                  color: AppColors.textGrey,
                                ),
                              );
                            }

                            return InkWell(
                              onTap: () => onSelected(option),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                child: AppText.bodyMedium(
                                  option.name,
                                  color: const Color(0xFF1E293B),
                                ),
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
              if (_searchController != textEditingController) {
                textEditingController.addListener(() {
                  if (_selectedFacility != null &&
                      textEditingController.text != _selectedFacility!.name) {
                    setState(() {
                      _selectedFacility = null;
                    });
                  }
                });
              }

              return AppFormField(
                controller: textEditingController,
                focusNode: focusNode,
                onFieldSubmitted: (_) => onFieldSubmitted(),
                label: context.l10n.facilityLabel,
                hintText: context.l10n.searchFacilityHint,
                prefixIcon: Icons.search,
                isRequired: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
