// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$medicationRemoteDataSourceHash() =>
    r'93e5345e1536df72406a1dfd39ade5adab08d0a4';

/// Medications on the server.
///
/// Copied from [medicationRemoteDataSource].
@ProviderFor(medicationRemoteDataSource)
final medicationRemoteDataSourceProvider =
    Provider<MedicationRemoteDataSource>.internal(
  medicationRemoteDataSource,
  name: r'medicationRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$medicationRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MedicationRemoteDataSourceRef = ProviderRef<MedicationRemoteDataSource>;
String _$medicationRepositoryHash() =>
    r'09931d573a5f72653ea442f63659f944be011de6';

/// Medications, doses and adherence, saved on the phone first and synced.
///
/// Copied from [medicationRepository].
@ProviderFor(medicationRepository)
final medicationRepositoryProvider = Provider<MedicationRepository>.internal(
  medicationRepository,
  name: r'medicationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$medicationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MedicationRepositoryRef = ProviderRef<MedicationRepository>;
String _$seededMedicationsHash() => r'63ba605a39a474aead013d3ededc138a8e0549c2';

/// The medicine list used for search suggestions.
///
/// Copied from [seededMedications].
@ProviderFor(seededMedications)
final seededMedicationsProvider =
    Provider<SeededMedicationsSyncService>.internal(
  seededMedications,
  name: r'seededMedicationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$seededMedicationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SeededMedicationsRef = ProviderRef<SeededMedicationsSyncService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
