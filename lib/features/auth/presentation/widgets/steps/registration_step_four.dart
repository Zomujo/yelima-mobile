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
  bool _isLoadingFacilities = false;
  bool _isDropdownVisible = false;
  List<FacilityModel> _options = [];
  FacilityModel? _selectedFacility;
  int _searchToken = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _searchController.text.isNotEmpty && _selectedFacility == null) {
        setState(() {
          _isDropdownVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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

  void _onSearchChanged(String query) async {
    if (_selectedFacility != null && query != _selectedFacility!.name) {
      setState(() {
        _selectedFacility = null;
      });
    }

    query = query.trim();
    if (query.isEmpty) {
      setState(() {
        _isDropdownVisible = false;
        _options = [];
      });
      return;
    }

    final token = ++_searchToken;
    setState(() {
      _isLoadingFacilities = true;
      _isDropdownVisible = true;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    if (token != _searchToken || !mounted) return;

    final userRepository = GetIt.instance<UserRepository>();
    final result = await userRepository.getFacilities(search: query, pageSize: 20);

    if (mounted && token == _searchToken) {
      setState(() {
        _isLoadingFacilities = false;
        _options = result.fold(
          (l) => [],
          (r) => r.rows,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: context.l10n.selectFacilityTitle,
      subtitle: context.l10n.selectFacilitySubtitle,
      continueText:
          _isSubmitting ? context.l10n.savingText : context.l10n.continueText,
      isContinueEnabled: _isFormValid,
      isSubmitting: _isSubmitting,
      onContinue: _handleContinue,
      onBack: widget.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            label: context.l10n.facilityLabel,
            hintText: context.l10n.searchFacilityHint,
            prefixIcon: Icons.search,
            isRequired: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => _selectedFacility == null ? 'Required' : null,
          ),
          if (_isDropdownVisible)
            Padding(
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
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _isLoadingFacilities 
                        ? 1 
                        : (_options.isEmpty ? 1 : _options.length),
                    separatorBuilder: (context, index) => const Divider(
                        height: 1, color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) {
                      if (_isLoadingFacilities) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: AppText.bodyMedium(
                            'Loading...',
                            color: AppColors.textGrey,
                          ),
                        );
                      }
                      
                      if (_options.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: AppText.bodyMedium(
                            context.l10n.noFacilitiesFound,
                            color: AppColors.textGrey,
                          ),
                        );
                      }

                      final option = _options[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFacility = option;
                            _searchController.text = option.name;
                            _isDropdownVisible = false;
                          });
                          FocusScope.of(context).unfocus();
                        },
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
        ],
      ),
    );
  }
}
