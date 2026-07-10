import 'package:flutter/material.dart';
import '../modals/discard_changes_modal.dart';

class UnsavedChangesGuard extends StatefulWidget {
  final Widget child;
  final bool Function() hasUnsavedChanges;

  const UnsavedChangesGuard({
    super.key,
    required this.child,
    required this.hasUnsavedChanges,
  });

  @override
  State<UnsavedChangesGuard> createState() => _UnsavedChangesGuardState();
}

class _UnsavedChangesGuardState extends State<UnsavedChangesGuard> {
  bool _allowPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (!widget.hasUnsavedChanges()) {
          setState(() => _allowPop = true);
          Future.microtask(() {
            if (context.mounted) Navigator.of(context).pop();
          });
          return;
        }

        final shouldPop = await DiscardChangesModal.show(context);
        if (shouldPop == true && context.mounted) {
          setState(() => _allowPop = true);
          Future.microtask(() {
            if (context.mounted) Navigator.of(context).pop();
          });
        }
      },
      child: widget.child,
    );
  }
}
