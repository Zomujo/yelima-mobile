import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/widgets/forms/app_text_field.dart';
import '../../../../shared/widgets/layout/app_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/logout_flow.dart';

class SessionExpiredScreen extends StatefulWidget {
  const SessionExpiredScreen({super.key});

  @override
  State<SessionExpiredScreen> createState() => _SessionExpiredScreenState();
}

class _SessionExpiredScreenState extends State<SessionExpiredScreen> {
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
    final error = await context
        .read<AuthController>()
        .reauthenticate(password: _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error == null ? null : context.l10n.reauthFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
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
              AppTextField(
                key: const ValueKey('reauth-password'),
                controller: _password,
                labelText: l10n.passwordLabel,
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
