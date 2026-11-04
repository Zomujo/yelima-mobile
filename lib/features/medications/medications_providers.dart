import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/core_providers.dart';
import '../../core/extensions/l10n_extension.dart';
import 'data/datasources/medication_remote_datasource.dart';
import 'data/datasources/medication_remote_mutation_source.dart';
import 'data/repositories/medication_repository_impl.dart';
import 'data/services/medication_alarm_sync_service.dart';
import 'data/services/seeded_medications_sync_service.dart';
import 'domain/repositories/medication_repository.dart';

part 'medications_providers.g.dart';

/// Medications on the server.
@Riverpod(keepAlive: true)
MedicationRemoteDataSource medicationRemoteDataSource(Ref ref) =>
    MedicationRemoteDataSource(apiClient: ref.watch(apiClientProvider));

/// Medications, doses and adherence, saved on the phone first and synced.
@Riverpod(keepAlive: true)
MedicationRepository medicationRepository(Ref ref) => MedicationRepositoryImpl(
      remoteDataSource: ref.watch(medicationRemoteDataSourceProvider),
      connectivityService: ref.watch(connectivityProvider),
      db: ref.watch(appDatabaseProvider),
      mutationSyncManager: ref.watch(mutationSyncManagerProvider),
      notificationService: ref.watch(notificationServiceProvider),
      session: ref.watch(sessionEpochProvider),
      l10n: () => l10nFor(ref.read(localeControllerProvider)),
      recent: ref.watch(recentFetchesProvider),
    );

/// The medicine list used for search suggestions.
@Riverpod(keepAlive: true)
SeededMedicationsSyncService seededMedications(Ref ref) =>
    SeededMedicationsSyncService(ref.watch(medicationRemoteDataSourceProvider),
        ref.watch(appDatabaseProvider), ref.watch(connectivityProvider))
      ..also(
          (s) => ref.watch(sessionLifecycleProvider).register(s, priority: 90));

/// Schedules reminders with the session and lets queued changes reach the server.
void setUpMedications(ProviderContainer c) {
  c.read(seededMedicationsProvider);
  // Reminders are rescheduled in the new language when it changes.
  final language = ValueNotifier(c.read(localeControllerProvider));
  c.listen(localeControllerProvider, (_, locale) => language.value = locale);
  c.read(sessionLifecycleProvider).register(
      MedicationAlarmSyncService(c.read(medicationRepositoryProvider),
          c.read(notificationServiceProvider), language),
      priority: 80);
  c.read(mutationSyncManagerProvider).registerSource(
      'medication',
      MedicationRemoteMutationSource(c.read(medicationRemoteDataSourceProvider),
          c.read(appDatabaseProvider)));
}
