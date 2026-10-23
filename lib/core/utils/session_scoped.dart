import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../services/session_lifecycle_service.dart';

/// Gets session start/end calls while the controller lives, and stops them on dispose.
mixin SessionScoped on ChangeNotifier implements SessionLifecycleHandler {
  /// Starts receiving session events; call from the constructor.
  void joinSession() => _service?.register(this);

  SessionLifecycleService? get _service =>
      GetIt.instance.isRegistered<SessionLifecycleService>()
          ? GetIt.instance<SessionLifecycleService>()
          : null;

  @override
  void dispose() {
    _service?.unregister(this);
    super.dispose();
  }
}
