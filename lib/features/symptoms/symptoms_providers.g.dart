// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptoms_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$symptomsRemoteDataSourceHash() =>
    r'b3086c21d393a750cced1e171a2531d390df941f';

/// Symptoms on the server.
///
/// Copied from [symptomsRemoteDataSource].
@ProviderFor(symptomsRemoteDataSource)
final symptomsRemoteDataSourceProvider =
    Provider<SymptomsRemoteDataSource>.internal(
  symptomsRemoteDataSource,
  name: r'symptomsRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$symptomsRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SymptomsRemoteDataSourceRef = ProviderRef<SymptomsRemoteDataSource>;
String _$symptomsRepositoryHash() =>
    r'8fda639efff6c79d2c3f5406e4f79cfe3f537fa1';

/// Symptoms, saved on the phone first and synced.
///
/// Copied from [symptomsRepository].
@ProviderFor(symptomsRepository)
final symptomsRepositoryProvider = Provider<SymptomsRepository>.internal(
  symptomsRepository,
  name: r'symptomsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$symptomsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SymptomsRepositoryRef = ProviderRef<SymptomsRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
