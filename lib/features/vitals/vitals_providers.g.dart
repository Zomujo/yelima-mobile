// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vitalsRemoteDataSourceHash() =>
    r'152fe00bdcfab987828db72e4695f3c0a2f46b3f';

/// Vital readings on the server.
///
/// Copied from [vitalsRemoteDataSource].
@ProviderFor(vitalsRemoteDataSource)
final vitalsRemoteDataSourceProvider =
    Provider<VitalsRemoteDataSource>.internal(
  vitalsRemoteDataSource,
  name: r'vitalsRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vitalsRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VitalsRemoteDataSourceRef = ProviderRef<VitalsRemoteDataSource>;
String _$severityRulesHash() => r'557d72bb861ffa82f05896a7a1bd289887725bb6';

/// The server's rules for grading readings, saved for offline use.
///
/// Copied from [severityRules].
@ProviderFor(severityRules)
final severityRulesProvider = Provider<SeverityRulesStore>.internal(
  severityRules,
  name: r'severityRulesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$severityRulesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SeverityRulesRef = ProviderRef<SeverityRulesStore>;
String _$vitalsRepositoryHash() => r'd9ddda14a71f79f2aba8684a8caba248f6362acf';

/// Vital readings, saved on the phone first and synced.
///
/// Copied from [vitalsRepository].
@ProviderFor(vitalsRepository)
final vitalsRepositoryProvider = Provider<VitalsRepository>.internal(
  vitalsRepository,
  name: r'vitalsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vitalsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VitalsRepositoryRef = ProviderRef<VitalsRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
