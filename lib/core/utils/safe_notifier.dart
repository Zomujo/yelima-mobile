import 'package:flutter/foundation.dart';

/// A mixin that provides a safe way to call `notifyListeners()` on a `ChangeNotifier`.
/// It prevents "notifyListeners() called after dispose()" crashes that occur
/// when a controller finishes an async operation after being disposed.
mixin SafeNotifier on ChangeNotifier {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
