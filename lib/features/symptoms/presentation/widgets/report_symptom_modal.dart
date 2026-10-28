import 'package:flutter/material.dart';
import 'package:yelima/core/theme/app_colors.dart';
import 'package:yelima/shared/widgets/layout/app_text.dart';
import 'package:yelima/shared/widgets/layout/app_button.dart';
import 'package:yelima/shared/widgets/modals/app_modal.dart';
import 'package:yelima/shared/widgets/modals/discard_changes_modal.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import 'package:provider/provider.dart';
import 'package:yelima/features/symptoms/presentation/controllers/symptoms_controller.dart';
import 'package:yelima/shared/utils/run_with_loader.dart';

/// Asks how the patient feels and reports it as a symptom.
class ReportSymptomModal extends StatefulWidget {
  const ReportSymptomModal({super.key, required this.text});

  /// The note being written; made by [show] so closing can check it, freed here.
  final TextEditingController text;

  /// The server's limit for a symptom description.
  static const maxLength = 1000;

  static Future<void> show(BuildContext context) {
    final text = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) => OverlayModal(
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 300),
        onDismiss: () => Navigator.of(context).pop(),
        confirmDismiss: () => canClose(context, text),
        child: ReportSymptomModal(text: text),
      ),
    );
  }

  /// True when nothing was written, or the patient agrees to drop it.
  static Future<bool> canClose(
          BuildContext context, TextEditingController text) async =>
      text.text.trim().isEmpty ||
      await DiscardChangesModal.show(context) == true;

  @override
  State<ReportSymptomModal> createState() => _ReportSymptomModalState();
}

class _ReportSymptomModalState extends State<ReportSymptomModal> {
  TextEditingController get _controller => widget.text;
  bool _isLoading = false;

  @override
  void dispose() {
    // Here, after the closing animation, not as soon as the dialog pops.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (await ReportSymptomModal.canClose(context, _controller) && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _sendRequest() async {
    final note = _controller.text.trim();
    if (note.length <= 5) return;

    setState(() => _isLoading = true);
    final controller = context.read<SymptomsController>();
    await runWithLoader(
      context,
      message: context.l10n.reportingSymptom,
      successMessage: context.l10n.symptomReported,
      action: () => controller.createSymptom(note),
    );
    if (!mounted) return;

    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      isBottomSheet: false,
      onClose: _close,
      padding: const EdgeInsets.all(24),
      showCloseButton: false,
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
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.slate100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close,
                      size: 20, color: AppColors.slate500),
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  onPressed: _isLoading ? null : _close,
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
              maxLength: ReportSymptomModal.maxLength,
              enabled: !_isLoading,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    value.trim().length <= 5) {
                  return context.l10n.enterMoreThanFiveChars;
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
                text:
                    _isLoading ? context.l10n.submitting : context.l10n.submit,
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
