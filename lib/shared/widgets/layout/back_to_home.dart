import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';

/// Makes back go home when this screen is the only one, e.g. opened from a notification.
class BackToHome extends StatelessWidget {
  const BackToHome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(RoutePaths.home);
      },
      child: child,
    );
  }
}
