// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'af955785d73acc6467ed036e0336375a4e66e5d1';

/// The loaded SharedPreferences; bootstrap overrides this with the real instance.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$sharedPrefsServiceHash() =>
    r'63b8923b69e381bbccaf5226ce0245f2ddaec656';

/// Typed access to saved settings.
///
/// Copied from [sharedPrefsService].
@ProviderFor(sharedPrefsService)
final sharedPrefsServiceProvider = Provider<SharedPrefsService>.internal(
  sharedPrefsService,
  name: r'sharedPrefsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPrefsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPrefsServiceRef = ProviderRef<SharedPrefsService>;
String _$firebaseAuthHash() => r'8c3e9d11b27110ca96130356b5ef4d5d34a5ffc2';

/// Firebase sign-in.
///
/// Copied from [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = Provider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = ProviderRef<FirebaseAuth>;
String _$firebaseMessagingHash() => r'6765ce963b9b8c50186b5132356d60eb68265741';

/// Firebase push messages.
///
/// Copied from [firebaseMessaging].
@ProviderFor(firebaseMessaging)
final firebaseMessagingProvider = Provider<FirebaseMessaging>.internal(
  firebaseMessaging,
  name: r'firebaseMessagingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseMessagingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseMessagingRef = ProviderRef<FirebaseMessaging>;
String _$sessionLifecycleHash() => r'6ef049c93d84d19a2b33e5af13410772aed81c96';

/// Runs session start and end steps in priority order.
///
/// Copied from [sessionLifecycle].
@ProviderFor(sessionLifecycle)
final sessionLifecycleProvider = Provider<SessionLifecycleService>.internal(
  sessionLifecycle,
  name: r'sessionLifecycleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionLifecycleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionLifecycleRef = ProviderRef<SessionLifecycleService>;
String _$sessionExpiryHash() => r'fb9b170527b0689db236bc5d52855742d196ae5f';

/// Whether the server said the session expired.
///
/// Copied from [sessionExpiry].
@ProviderFor(sessionExpiry)
final sessionExpiryProvider = Provider<SessionExpiry>.internal(
  sessionExpiry,
  name: r'sessionExpiryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionExpiryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionExpiryRef = ProviderRef<SessionExpiry>;
String _$sessionEpochHash() => r'91bf2c7f9cbd7065b459e162c741a6428232271c';

/// Counts sessions; highest priority, so late results are dropped before the wipe.
///
/// Copied from [sessionEpoch].
@ProviderFor(sessionEpoch)
final sessionEpochProvider = Provider<SessionEpoch>.internal(
  sessionEpoch,
  name: r'sessionEpochProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sessionEpochHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionEpochRef = ProviderRef<SessionEpoch>;
String _$apiClientHash() => r'6eed3fef80226ab67710ee5df7b3cc2985a0b139';

/// The API client.
///
/// Copied from [apiClient].
@ProviderFor(apiClient)
final apiClientProvider = Provider<APIClient>.internal(
  apiClient,
  name: r'apiClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$apiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiClientRef = ProviderRef<APIClient>;
String _$appDatabaseHash() => r'98a09c6cfd43966155dfbdb0787fa18c85438e13';

/// The encrypted local database.
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$vitalsDaoHash() => r'4c57e4963bb6d3a6075aa3e01f819c7fca7c574a';

/// Saved vital readings.
///
/// Copied from [vitalsDao].
@ProviderFor(vitalsDao)
final vitalsDaoProvider = Provider<VitalsDao>.internal(
  vitalsDao,
  name: r'vitalsDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$vitalsDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VitalsDaoRef = ProviderRef<VitalsDao>;
String _$aiChatDaoHash() => r'8268fc1e0b7564986499f3b2b832877a78279516';

/// Saved AI chat messages.
///
/// Copied from [aiChatDao].
@ProviderFor(aiChatDao)
final aiChatDaoProvider = Provider<AiChatDao>.internal(
  aiChatDao,
  name: r'aiChatDaoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiChatDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiChatDaoRef = ProviderRef<AiChatDao>;
String _$medicationsDaoHash() => r'0a79308f7ab6ad7d6fe94e47cddd4eba34336be6';

/// Saved medications.
///
/// Copied from [medicationsDao].
@ProviderFor(medicationsDao)
final medicationsDaoProvider = Provider<MedicationsDao>.internal(
  medicationsDao,
  name: r'medicationsDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$medicationsDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MedicationsDaoRef = ProviderRef<MedicationsDao>;
String _$connectivityHash() => r'c33b3427c8dd123d53c3ce3ff85f442d03e6f513';

/// Online/offline state.
///
/// Copied from [connectivity].
@ProviderFor(connectivity)
final connectivityProvider = Provider<ConnectivityService>.internal(
  connectivity,
  name: r'connectivityProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityRef = ProviderRef<ConnectivityService>;
String _$onlineHash() => r'de40306de0da48b8e99bdfa7e67a41b6a0eec87f';

/// Whether the phone is online, for screens that change when it isn't.
///
/// Copied from [online].
@ProviderFor(online)
final onlineProvider = StreamProvider<bool>.internal(
  online,
  name: r'onlineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$onlineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnlineRef = StreamProviderRef<bool>;
String _$fileServiceHash() => r'6d94df07e33d7d25eb737e51f4395bfaa63a5ae9';

/// Local file access.
///
/// Copied from [fileService].
@ProviderFor(fileService)
final fileServiceProvider = Provider<FileService>.internal(
  fileService,
  name: r'fileServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fileServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FileServiceRef = ProviderRef<FileService>;
String _$appStartupHash() => r'266f8598e3f0af86f68515f16b156d4bd1c226a5';

/// Startup progress for the splash screen and router.
///
/// Copied from [appStartup].
@ProviderFor(appStartup)
final appStartupProvider = Provider<AppStartupService>.internal(
  appStartup,
  name: r'appStartupProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appStartupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppStartupRef = ProviderRef<AppStartupService>;
String _$notificationServiceHash() =>
    r'63bb346f5fb591f4a743ff0f8e30cfe31cbb1083';

/// Local notifications and reminders.
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = ProviderRef<NotificationService>;
String _$fcmTokenServiceHash() => r'1f7e2962de6f1ead02022f389aa44118d1f5cc3f';

/// Registers this phone's push token with the server.
///
/// Copied from [fcmTokenService].
@ProviderFor(fcmTokenService)
final fcmTokenServiceProvider = Provider<FCMTokenService>.internal(
  fcmTokenService,
  name: r'fcmTokenServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmTokenServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenServiceRef = ProviderRef<FCMTokenService>;
String _$databaseLifecycleHandlerHash() =>
    r'840dd965da540c156a3fd200825385aec5129eaf';

/// Wipes the local database on logout.
///
/// Copied from [databaseLifecycleHandler].
@ProviderFor(databaseLifecycleHandler)
final databaseLifecycleHandlerProvider =
    Provider<DatabaseLifecycleHandler>.internal(
  databaseLifecycleHandler,
  name: r'databaseLifecycleHandlerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseLifecycleHandlerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseLifecycleHandlerRef = ProviderRef<DatabaseLifecycleHandler>;
String _$fcmLifecycleHandlerHash() =>
    r'02de8c4c9f0a6e45854725013fa20a6e666d096a';

/// Registers and removes the push token with the session.
///
/// Copied from [fcmLifecycleHandler].
@ProviderFor(fcmLifecycleHandler)
final fcmLifecycleHandlerProvider = Provider<FCMLifecycleHandler>.internal(
  fcmLifecycleHandler,
  name: r'fcmLifecycleHandlerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmLifecycleHandlerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmLifecycleHandlerRef = ProviderRef<FCMLifecycleHandler>;
String _$audioPlayerManagerHash() =>
    r'b9a3e795263299207b984ce31ecc0ca699fa5ab0';

/// Plays chat audio.
///
/// Copied from [audioPlayerManager].
@ProviderFor(audioPlayerManager)
final audioPlayerManagerProvider = Provider<AudioPlayerManager>.internal(
  audioPlayerManager,
  name: r'audioPlayerManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPlayerManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AudioPlayerManagerRef = ProviderRef<AudioPlayerManager>;
String _$voiceRecordingServiceHash() =>
    r'796d4588d9f5280578f406ae9c4e78ad73cedd56';

/// Records voice notes.
///
/// Copied from [voiceRecordingService].
@ProviderFor(voiceRecordingService)
final voiceRecordingServiceProvider = Provider<VoiceRecordingService>.internal(
  voiceRecordingService,
  name: r'voiceRecordingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voiceRecordingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoiceRecordingServiceRef = ProviderRef<VoiceRecordingService>;
String _$deletionSyncManagerHash() =>
    r'6e46b34a45f2223f42fd6b307db4b1ee756152a4';

/// Sends queued deletions; features add their sources.
///
/// Copied from [deletionSyncManager].
@ProviderFor(deletionSyncManager)
final deletionSyncManagerProvider = Provider<DeletionSyncManager>.internal(
  deletionSyncManager,
  name: r'deletionSyncManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deletionSyncManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletionSyncManagerRef = ProviderRef<DeletionSyncManager>;
String _$mutationSyncManagerHash() =>
    r'57b644dc8920dde6da0f6f05513e49912265137c';

/// Sends queued changes in order; features add their sources.
///
/// Copied from [mutationSyncManager].
@ProviderFor(mutationSyncManager)
final mutationSyncManagerProvider = Provider<MutationSyncManager>.internal(
  mutationSyncManager,
  name: r'mutationSyncManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mutationSyncManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MutationSyncManagerRef = ProviderRef<MutationSyncManager>;
String _$dayChangesHash() => r'9b2d547f3ecb8b1119c93b6af5c5e31b1bbf47bc';

/// Tells screens when the date changes.
///
/// Copied from [dayChanges].
@ProviderFor(dayChanges)
final dayChangesProvider = Provider<DayChanges>.internal(
  dayChanges,
  name: r'dayChangesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dayChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DayChangesRef = ProviderRef<DayChanges>;
String _$recentFetchesHash() => r'ea26aaf4822e2e1de9446e1a25625206dc5012a2';

/// Remembers recent server fetches, so screens don't refetch every visit.
///
/// Copied from [recentFetches].
@ProviderFor(recentFetches)
final recentFetchesProvider = Provider<RecentFetches>.internal(
  recentFetches,
  name: r'recentFetchesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentFetchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentFetchesRef = ProviderRef<RecentFetches>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
