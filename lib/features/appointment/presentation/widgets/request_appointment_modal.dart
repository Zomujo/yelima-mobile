import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/app_text.dart';
import '../../../../../shared/widgets/layout/app_button.dart';
import '../../../../../shared/widgets/modals/app_modal.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../controllers/appointment_controller.dart';

class RequestAppointmentModal extends StatefulWidget {
  const RequestAppointmentModal({super.key});

  static void show(BuildContext context) {
    context.showModal(
      alignment: ModalAlignment.center,
      child: const RequestAppointmentModal(),
    );
  }

  @override
  State<RequestAppointmentModal> createState() =>
      _RequestAppointmentModalState();
}

class _RequestAppointmentModalState extends State<RequestAppointmentModal> {
  final _controller = TextEditingController();
  String? _errorMessage;

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
        _errorMessage = null;
      });
    }

    // Use read so we don't rebuild on every isRequestingAppointment change
    final appointmentController = context.read<AppointmentController>();

    final error = await appointmentController.requestAppointment(
      note: note,
    );

    if (!mounted) return;

    if (error == null) {
      context.showSuccessSnackBar('Appointment request sent successfully!');
      context.removeModal();
    } else {
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      isBottomSheet: false,
      onClose: context.removeModal,
      padding: const EdgeInsets.all(24),
      showCloseButton: false, // We will build our own close button
      child: Consumer<AppointmentController>(
        builder: (context, appointmentController, child) {
          final isLoading = appointmentController.state.isRequestingAppointment;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: AppText.headlineSmall(
                      'Request an appointment',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
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
                      // Disable close while loading
                      onPressed: isLoading ? null : context.removeModal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const AppText.bodyMedium(
                'Describe what you need so your HCP can prepare.',
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
                  // Disable the text field while sending
                  enabled: !isLoading,
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
                    hintText: 'e.g. My BP readings have been high this week...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppText.bodyMedium(
                    _errorMessage!,
                    color: Colors.redAccent,
                  ),
                ),
              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final isValid = value.text.trim().length > 5;
                  return AppButton(
                    text: isLoading ? 'Sending...' : 'Send request',
                    isDisabled: !isValid || isLoading,
                    onPressed: (isValid && !isLoading) ? _sendRequest : null,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    borderRadius: 24,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
