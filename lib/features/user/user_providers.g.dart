// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRemoteDataSourceHash() =>
    r'6267c1e21b32c605fd4eca6207a088f4a33b6f4f';

/// The profile on the server and in Firestore.
///
/// Copied from [userRemoteDataSource].
@ProviderFor(userRemoteDataSource)
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>.internal(
  userRemoteDataSource,
  name: r'userRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRemoteDataSourceRef = ProviderRef<UserRemoteDataSource>;
String _$userRepositoryHash() => r'd0b8eec8d4c94ab6f1bbf0f4c01ea59f540c7067';

/// The profile, saved on the phone first and synced.
///
/// Copied from [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = Provider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = ProviderRef<UserRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
