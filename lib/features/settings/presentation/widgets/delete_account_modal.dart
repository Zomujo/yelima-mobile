import 'package:yelima/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/layout/app_text.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../shared/widgets/modals/app_modal.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:yelima/core/extensions/l10n_extension.dart';
import '../../../../core/router/router.dart';
import 'package:yelima/shared/utils/run_with_loader.dart';

/// Confirms, then deletes the account (password users re-enter it).
class DeleteAccountModal extends StatefulWidget {
  const DeleteAccountModal({super.key});

  static void show(BuildContext context) {
    showAppDialog(context, const DeleteAccountModal());
  }

  @override
  State<DeleteAccountModal> createState() => _DeleteAccountModalState();
}

class _DeleteAccountModalState extends State<DeleteAccountModal> {
  final _passwordController = TextEditingController();
  bool _isPasswordProvider = false;
  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    _isPasswordProvider = context.read<AuthController>().reauthNeedsPassword;

    if (_isPasswordProvider) {
      _isButtonEnabled = false;
      _passwordController.addListener(() {
        setState(() {
          _isButtonEnabled = _passwordController.text.isNotEmpty;
        });
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalContainer(
      title: context.l10n.deleteAccount,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText.titleMedium(
            context.l10n.deleteAccountConfirmation,
            color: Colors.black54,
          ),
          if (_isPasswordProvider) ...[
            const SizedBox(height: 24),
            AppFormField(
              label: context.l10n.password,
              hintText: context.l10n.enterPasswordToConfirm,
              controller: _passwordController,
              isPassword: true,
            ),
          ],
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: context.l10n.cancel,
                  backgroundColor: AppColors.slate100,
                  foregroundColor: AppColors.slate600,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: context.l10n.delete,
                  backgroundColor:
                      _isButtonEnabled ? AppColors.red500 : Colors.grey,
                  onPressed: _isButtonEnabled
                      ? () async {
                          final controller = context.read<AuthController>();
                          // Read everything first: the modal and its context go away on pop.
                          final password = _isPasswordProvider
                              ? _passwordController.text
                              : null;
                          final host =
                              rootNavigatorKey.currentContext ?? context;
                          Navigator.of(context).pop();
                          await runWithLoader(host,
                              message: host.l10n.deletingAccount,
                              successMessage: host.l10n.accountDeleted,
                              action: () =>
                                  controller.deleteAccount(password: password));
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
