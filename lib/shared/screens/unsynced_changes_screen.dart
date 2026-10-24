import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../core/db/app_database.dart';
import '../../core/db/daos/pending_mutations_dao.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/managers/mutation_sync_manager.dart';
import '../../core/utils/app_date_formats.dart';
import '../widgets/layout/app_header.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/layout/app_text.dart';

/// Lists changes that couldn't sync, with Retry and Discard for each.
class UnsyncedChangesScreen extends StatefulWidget {
  const UnsyncedChangesScreen({super.key, required this.sync});

  final MutationSyncManager sync;

  @override
  State<UnsyncedChangesScreen> createState() => _UnsyncedChangesScreenState();
}

class _UnsyncedChangesScreenState extends State<UnsyncedChangesScreen> {
  late final _failed = widget.sync.watchFailed();

  Future<void> _discard(PendingMutation change) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangeTitle),
        content: Text(l10n.discardChangeBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.discard)),
        ],
      ),
    );
    if (ok == true) await widget.sync.discardFailed(change.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      appBar: AppHeader(title: l10n.unsyncedChangesTitle),
      body: StreamBuilder<List<PendingMutation>>(
        stream: _failed,
        builder: (context, snap) {
          final changes = snap.data ?? const [];
          if (changes.isEmpty) {
            return Center(child: AppText.bodyLarge(l10n.allChangesSynced));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: changes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _ChangeTile(
              change: changes[i],
              onRetry: () => widget.sync.retryFailed(changes[i].id),
              onDiscard: () => _discard(changes[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ChangeTile extends StatelessWidget {
  const _ChangeTile(
      {required this.change, required this.onRetry, required this.onDiscard});

  final PendingMutation change;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  String _kind(BuildContext context) {
    final l10n = context.l10n;
    return switch (change.entityType) {
      'medication' => l10n.changeKindMedication,
      'vital_history' => l10n.changeKindReading,
      'symptom' => l10n.changeKindSymptom,
      'chat' => l10n.changeKindChat,
      'user_profile' => l10n.changeKindProfile,
      _ => l10n.changeKindOther,
    };
  }

  /// The server only takes doses from the last 48 h, so retrying can't help.
  bool get _tooLate =>
      change.action == 'confirmMedication' &&
      clock.now().difference(change.createdAt) > const Duration(hours: 48);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rejected = change.retryCount >= PendingMutationsDao.rejected;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: AppText.titleMedium(
          '${_kind(context)} · ${AppDateFormats.appointmentCard.format(change.createdAt)}'),
      subtitle: AppText.bodyMedium(_tooLate
          ? l10n.doseTooLate
          : rejected
              ? l10n.changeRejected
              : l10n.changeGaveUp),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (!_tooLate)
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          TextButton(onPressed: onDiscard, child: Text(l10n.discard)),
        ],
      ),
    );
  }
}
