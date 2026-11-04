import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/utils/failure_message.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../../auth_providers.dart';
import '../widgets/auth_layout.dart';
import '../widgets/logout_flow.dart';

/// Locks the app until the user signs in again or logs out.
class SessionExpiredScreen extends ConsumerStatefulWidget {
  const SessionExpiredScreen({super.key});

  @override
  ConsumerState<SessionExpiredScreen> createState() =>
      _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends ConsumerState<SessionExpiredScreen> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _signInAgain() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(authControllerProvider.notifier)
        .reauthenticate(password: _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = result.fold((f) => f.message(context.l10n), (_) => null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authControllerProvider.notifier);
    final l10n = context.l10n;
    return AuthLayout(
      title: l10n.sessionExpiredTitle,
      subtitle: l10n.sessionExpiredBody,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (auth.reauthNeedsPassword) ...[
              AppFormField(
                key: const ValueKey('reauth-password'),
                controller: _password,
                label: l10n.passwordLabel,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signInAgain(),
              ),
              const SizedBox(height: 16),
            ],
            if (_error != null) ...[
              Text(_error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
            ],
            AppButton(
              text: l10n.signInAgain,
              isLoading: _busy,
              onPressed: _signInAgain,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _busy ? null : () => logOutWithSyncCheck(context),
              child: Text(l10n.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
