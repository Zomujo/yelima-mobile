import 'package:flutter/material.dart';

class AppStartupWidget extends StatelessWidget {
  final WidgetBuilder onLoaded;

  const AppStartupWidget({super.key, required this.onLoaded});

  @override
  Widget build(BuildContext context) {
    // For Riverpod: wrap with a Provider that watches an appStartupProvider.
    // For Provider: check SharedPrefsService / auth state directly.
    return onLoaded(context);
  }
}
