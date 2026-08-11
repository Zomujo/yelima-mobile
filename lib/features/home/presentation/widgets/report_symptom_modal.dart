import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/widgets/modals/app_modal.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n_extension.dart';
import 'package:provider/provider.dart';
import '../../../symptoms/presentation/controllers/symptoms_controller.dart';

class ReportSymptomModal extends StatefulWidget {
  const ReportSymptomModal({super.key});

  static void show(BuildContext context) {
    context.showModal(
      alignment: ModalAlignment.center,
      child: const ReportSymptomModal(),
    );
  }

  @override
  State<ReportSymptomModal> createState() => _ReportSymptomModalState();
}

class _ReportSymptomModalState extends State<ReportSymptomModal> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final note = _controller.text.trim();
    if (note.length <= 5) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Submit via backend
    await context.read<SymptomsController>().createSymptom(context, note);

    if (!mounted) return;

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    context.removeModal();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      isBottomSheet: false,
      onClose: context.removeModal,
      padding: const EdgeInsets.all(24),
      showCloseButton: false, // We build our own close button
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppText.headlineSmall(
                  context.l10n.reportSymptom,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), // Slate 100
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close,
                      size: 20, color: Color(0xFF64748B)),
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  onPressed: _isLoading ? null : context.removeModal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.bodyMedium(
            context.l10n.describeHowYouAreFeeling,
            color: AppColors.textGrey,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextFormField(
              controller: _controller,
              maxLines: 4,
              enabled: !_isLoading,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    value.trim().length <= 5) {
                  return 'Please enter more than 5 characters.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: context.l10n.reportSymptomHint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              final isValid = value.text.trim().length > 5;
              return AppButton(
                text: _isLoading ? context.l10n.submitting : context.l10n.submit,
                isDisabled: !isValid || _isLoading,
                onPressed: (isValid && !_isLoading) ? _sendRequest : null,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                borderRadius: 24,
              );
            },
          ),
        ],
      ),
    );
  }
}
