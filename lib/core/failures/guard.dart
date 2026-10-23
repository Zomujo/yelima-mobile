import 'package:fpdart/fpdart.dart';

import '../utils/logger.dart';
import 'app_failure.dart';

/// Where unplanned errors get reported; bootstrap points this at Crashlytics.
void Function(Object error, StackTrace stack) reportUnexpectedFailure =
    (_, __) {};

/// Runs [action] and returns its value, or the [AppFailure] it failed with.
AsyncResult<T> guard<T>(Future<T> Function() action) async {
  try {
    return right(await action());
  } catch (error, stack) {
    final failure = AppFailure.from(error);
    if (failure is UnexpectedFailure) {
      AppLogger.e('Unexpected failure', error, stack);
      reportUnexpectedFailure(error, stack);
    } else {
      AppLogger.w('$failure');
    }
    return left(failure);
  }
}
