import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/extensions/l10n_extension.dart';
import '../../core/failures/app_failure.dart';

import '../widgets/loaders/global_async_loader.dart';
import 'app_snackbar.dart';
import 'failure_message.dart';

/// Shows the loader with [message] while [action] runs, then its error (or
/// [successMessage]) as a snackbar, and returns whether it succeeded.
///
/// A cancelled action shows nothing.
// TODO(P5): drop the String error once every feature returns AppFailure.
Future<bool> runWithLoader<T>(
  BuildContext context, {
  required String message,
  required Future<Either<Object, T>> Function() action,
  String? successMessage,
}) async {
  final l10n = context.l10n;
  GlobalAsyncLoader.show(context, message: message);
  final result = await action();
  final ok = result.isRight();
  GlobalAsyncLoader.hide();

  final host = context.mounted ? context : null;
  result.fold(
    (error) {
      final text = error is AppFailure ? error.message(l10n) : '$error';
      if (text != null && text.isNotEmpty) {
        AppSnackBar.showError(host, message: text);
      }
    },
    (_) {
      if (successMessage != null) {
        AppSnackBar.showSuccess(host, message: successMessage);
      }
    },
  );
  return ok;
}
