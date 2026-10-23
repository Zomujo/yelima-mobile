import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import 'app_text.dart';

/// One summary pill for unsynced changes; failed ones take priority. Hidden when there are none.
class PendingChangesBadge extends StatelessWidget {
  const PendingChangesBadge({
    super.key,
    required this.waiting,
    required this.failed,
    this.onTap,
  });

  final Stream<int> waiting;
  final Stream<int> failed;

  /// Opens the failed-changes list, when there is one.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: failed,
      initialData: 0,
      builder: (context, failedSnap) => StreamBuilder<int>(
        stream: waiting,
        initialData: 0,
        builder: (context, waitingSnap) {
          final failedCount = failedSnap.data ?? 0;
          final waitingCount = waitingSnap.data ?? 0;
          if (failedCount > 0) {
            return _Pill(
              icon: Icons.error_outline,
              color: Colors.red.shade700,
              label: context.l10n.changesFailed(failedCount),
              onTap: onTap,
            );
          }
          if (waitingCount > 0) {
            return _Pill(
              icon: Icons.cloud_upload_outlined,
              color: AppColors.textGrey,
              label: context.l10n.changesWaiting(waitingCount),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.icon,
      required this.color,
      required this.label,
      this.onTap});

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(child: AppText.labelSmall(label, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
