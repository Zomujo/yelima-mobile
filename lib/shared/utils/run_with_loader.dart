import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';

import '../widgets/loaders/global_async_loader.dart';
import 'app_snackbar.dart';

/// Shows the loader with [message] while [action] runs, then its error (or
/// [successMessage]) as a snackbar, and returns whether it succeeded.
///
/// An empty error means the user cancelled, so nothing is shown. With
/// [keepLoaderOnSuccess] the loader stays up for whatever happens next.
Future<bool> runWithLoader<T>(
  BuildContext context, {
  required String message,
  required Future<Either<String, T>> Function() action,
  String? successMessage,
  bool keepLoaderOnSuccess = false,
}) async {
  GlobalAsyncLoader.show(context, message: message);
  final result = await action();
  final ok = result.isRight();
  if (!ok || !keepLoaderOnSuccess) GlobalAsyncLoader.hide();

  final host = context.mounted ? context : null;
  result.fold(
    (error) {
      if (error.isNotEmpty) AppSnackBar.showError(host, message: error);
    },
    (_) {
      if (successMessage != null) {
        AppSnackBar.showSuccess(host, message: successMessage);
      }
    },
  );
  return ok;
}
