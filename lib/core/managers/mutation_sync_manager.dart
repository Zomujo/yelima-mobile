import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/i_remote_mutation.dart';
import '../db/app_database.dart';
import '../services/connectivity_service.dart';
import '../services/session_lifecycle_service.dart';
import '../failures/app_failure.dart';
import '../utils/logger.dart';

part 'mutation_attempt.dart';

/// Sends queued offline changes when online, retrying with backoff; rejected ones go to the failed list.
class MutationSyncManager implements SessionLifecycleHandler {
  final ConnectivityService _connectivityService;
  final AppDatabase _db;
  final Map<String, IRemoteMutationSource> _remoteSources;

  StreamSubscription? _networkSubscription;
  bool _isSyncing = false;
  bool _isSessionActive = false;

  final StreamController<String> _syncBroadcast =
      StreamController<String>.broadcast();
  Stream<String> get onMutationSynced => _syncBroadcast.stream;

  MutationSyncManager({
    required ConnectivityService connectivityService,
    required AppDatabase db,
    Map<String, IRemoteMutationSource> remoteSources = const {},
    List<Duration> retryDelays = const [
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 2),
      Duration(minutes: 5),
      Duration(minutes: 10),
    ],
  })  : _connectivityService = connectivityService,
        _db = db,
        _remoteSources = {...remoteSources},
        _retryDelays = retryDelays;

  /// Waits between automatic retries; the last one repeats.
  final List<Duration> _retryDelays;
  Timer? _retryTimer;
  int _retryAttempt = 0;

  Timer? _debounceTimer;
  Future<void>? _syncTask;

  @override
  String get serviceName => 'Mutation Sync';

  /// Reports how many queued changes were dropped because another user left them.
  void Function(int count)? onDiscarded;

  @override
  Future<void> onSessionStarted(String userId) async {
    _db.pendingMutationsDao.owner = userId;
    // Never send one user's changes with another user's login.
    final dropped = await _db.pendingMutationsDao.removeOtherOwners(userId);
    if (dropped > 0) onDiscarded?.call(dropped);
    _isSessionActive = true;
    triggerSync();
  }

  @override
  Future<void> onSessionEnded() async {
    _isSessionActive = false;
    _db.pendingMutationsDao.owner = null;
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    _retryAttempt = 0;
    if (_syncTask != null) {
      debugPrint(
          "MutationSyncManager: Awaiting in-flight sync task before ending session...");
      await _syncTask;
      debugPrint("MutationSyncManager: Sync task completed, session ending.");
    }
  }

  void init() {
    if (_networkSubscription != null) return;

    _networkSubscription =
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 3), () {
          debugPrint(
              "Network connection stable for 3s. Starting mutation sync...");
          triggerSync();
        });
      } else {
        _debounceTimer?.cancel();
      }
    });
  }

  Future<void> triggerSync() async {
    if (_isSessionActive && await _connectivityService.isConnected) {
      if (!_isSyncing) {
        _syncTask = _syncPendingMutations();
      }
      await _syncTask;
    }
  }

  /// Tries to send queued changes (up to 10s), then counts what is still unsent.
  Future<({int waiting, int failed})> flush() async {
    try {
      await triggerSync().timeout(const Duration(seconds: 10));
    } catch (e) {
      AppLogger.w('Flush failed or timed out: $e');
    }
    final dao = _db.pendingMutationsDao;
    return (
      waiting: (await dao.getAllPendingMutations()).length,
      failed: (await dao.getFailedMutations()).length,
    );
  }

  /// Entity types that have a registered source.
  @visibleForTesting
  Set<String> get sourceTypes => _remoteSources.keys.toSet();

  /// Lets a feature sync its queued changes of [entityType] through [source].
  void registerSource(String entityType, IRemoteMutationSource source) =>
      _remoteSources[entityType] = source;

  /// Live count of changes waiting to sync, for the "changes waiting" badge.
  Stream<int> watchWaitingCount() =>
      _db.pendingMutationsDao.watchWaitingCount();

  /// Live list of changes that were rejected or ran out of tries.
  Stream<List<PendingMutation>> watchFailed() =>
      _db.pendingMutationsDao.watchFailedMutations();

  /// Live count of changes that were rejected or ran out of tries.
  Stream<int> watchFailedCount() => _db.pendingMutationsDao.watchFailedCount();

  /// Puts a failed item back in the queue and syncs now.
  Future<void> retryFailed(String mutationId) async {
    await _db.pendingMutationsDao.resetRetries(mutationId);
    await triggerSync();
  }

  /// Drops a failed item for good.
  Future<void> discardFailed(String mutationId) =>
      _db.pendingMutationsDao.removePendingMutation(mutationId);

  /// Schedules the next automatic retry, waiting longer each time, and at least
  /// as long as the server asked ([serverWait], from a 429's `Retry-After`).
  void _scheduleRetry({Duration? serverWait}) {
    if (!_isSessionActive || _retryDelays.isEmpty) return;
    final backoff =
        _retryDelays[_retryAttempt.clamp(0, _retryDelays.length - 1)];
    final delay =
        serverWait != null && serverWait > backoff ? serverWait : backoff;
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, triggerSync);
  }

  Future<void> _syncPendingMutations() async {
    if (_isSyncing) return;
    _isSyncing = true;
    var needsRetry = false;
    Duration? serverWait;

    try {
      // Entities that failed in this run; skipped until the next run so one item can't burn its tries at once.
      final blockedKeys = <String>{};
      bool hasPendingMutations = true;
      while (hasPendingMutations && _isSessionActive) {
        final mutations =
            await _db.pendingMutationsDao.getAllPendingMutations();
        if (mutations.isEmpty) {
          break;
        }

        debugPrint("Found ${mutations.length} pending mutations to sync.");
        hasPendingMutations = false;

        for (final mutation in mutations) {
          if (!_isSessionActive) {
            debugPrint("Session ended during sync. Aborting batch.");
            break;
          }

          final entityKey = '${mutation.entityType}:${mutation.entityId}';
          if (blockedKeys.contains(entityKey)) {
            debugPrint(
                "Skipping mutation ${mutation.id}: an earlier mutation for $entityKey hasn't resolved yet.");
            continue;
          }

          final outcome = await _attemptMutation(mutation);

          if (outcome == _MutationOutcome.remapped) {
            debugPrint("ID remapped, breaking batch to refetch fresh state.");
            hasPendingMutations = true;
            break;
          }

          if (outcome == _MutationOutcome.blocked ||
              outcome == _MutationOutcome.retry) {
            blockedKeys.add(entityKey);
          }
          // Progress made: look again afterwards for items queued during this run.
          if (outcome == _MutationOutcome.resolved) hasPendingMutations = true;
          if (outcome == _MutationOutcome.retry) needsRetry = true;

          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      debugPrint("Mutation sync stopped: $e");
      final failure = AppFailure.from(e);
      // A lost login needs a new sign-in, not a timed retry.
      needsRetry = failure is! UnauthorizedFailure;
      if (failure is ServerFailure) serverWait = failure.retryAfter;
    } finally {
      _isSyncing = false;
    }
    if (needsRetry) {
      _scheduleRetry(serverWait: serverWait);
    } else {
      _retryAttempt = 0;
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    _networkSubscription?.cancel();
    _networkSubscription = null;
    _syncBroadcast.close();
  }
}
