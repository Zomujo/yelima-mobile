// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appointmentRemoteDataSourceHash() =>
    r'cd68c81d0e6be89667ca256c6a967d15a7bd7176';

/// Appointments from the server.
///
/// Copied from [appointmentRemoteDataSource].
@ProviderFor(appointmentRemoteDataSource)
final appointmentRemoteDataSourceProvider =
    Provider<AppointmentRemoteDataSource>.internal(
  appointmentRemoteDataSource,
  name: r'appointmentRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appointmentRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppointmentRemoteDataSourceRef
    = ProviderRef<AppointmentRemoteDataSource>;
String _$appointmentRepositoryHash() =>
    r'c5d09013b61884b1844c315a2e59618f6d5a7e89';

/// Appointments, cached on the phone.
///
/// Copied from [appointmentRepository].
@ProviderFor(appointmentRepository)
final appointmentRepositoryProvider = Provider<AppointmentRepository>.internal(
  appointmentRepository,
  name: r'appointmentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appointmentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppointmentRepositoryRef = ProviderRef<AppointmentRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
