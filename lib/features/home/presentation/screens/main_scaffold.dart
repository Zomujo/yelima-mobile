import 'package:flutter/material.dart';
import 'package:yelima/features/home/presentation/widgets/home_bottom_navbar.dart';
import 'package:yelima/shared/widgets/modals/exit_confirmation_modal.dart';

/// The tab screens with the floating bottom bar.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent default back-button quit behaviour
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ExitConfirmationModal.show(context);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: child),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }
}
