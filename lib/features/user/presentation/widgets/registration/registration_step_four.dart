import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/user/presentation/controllers/user_controller.dart';
import 'package:yelima/features/user/domain/models/facility_model.dart';
import 'package:yelima/shared/widgets/layout/step_layout.dart';
import 'package:yelima/shared/widgets/forms/app_form_field.dart';
import 'package:yelima/shared/widgets/forms/search_suggestions.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:yelima/shared/utils/run_with_loader.dart';

/// Registration step 4: pick the health facility.
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
  bool _isLoadingFacilities = false;
  bool _isDropdownVisible = false;
  List<FacilityModel> _options = [];
  FacilityModel? _selectedFacility;
  final _search = LatestSearch();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus &&
          _searchController.text.isNotEmpty &&
          _selectedFacility == null) {
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

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    final users = context.read<UserController>();
    final saved = await runWithLoader(context,
        message: context.l10n.completingProfile,
        action: () => users.submitOnboarding(_selectedFacility!.id));
    if (saved && mounted) widget.onContinue();
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

    setState(() {
      _isLoadingFacilities = true;
      _isDropdownVisible = true;
    });
    final users = context.read<UserController>();
    final result = await _search.run(() => users.searchFacilities(query));
    if (result == null || !mounted) return;
    setState(() {
      _isLoadingFacilities = false;
      _options = result.getOrElse((_) => const []);
    });
  }

  void _select(FacilityModel option) {
    setState(() {
      _selectedFacility = option;
      _searchController.text = option.name;
      _isDropdownVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: context.l10n.selectFacilityTitle,
      subtitle: context.l10n.selectFacilitySubtitle,
      isContinueEnabled: _selectedFacility != null,
      onContinue: _continue,
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
            validator: (v) =>
                _selectedFacility == null ? context.l10n.requiredField : null,
          ),
          if (_isDropdownVisible)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SuggestionList(
                items: [for (final o in _options) o.name],
                message: _isLoadingFacilities
                    ? context.l10n.loading
                    : _options.isEmpty
                        ? context.l10n.noFacilitiesFound
                        : null,
                onTap: (i) => _select(_options[i]),
              ),
            ),
        ],
      ),
    );
  }
}
