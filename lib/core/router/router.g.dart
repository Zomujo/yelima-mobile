// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$redirectRefreshHash() => r'c25b21cbf500125663d84eaf161d02eb8cdbe5e0';

/// Fires on every login or profile change, so the redirect rules run again.
///
/// Copied from [redirectRefresh].
@ProviderFor(redirectRefresh)
final redirectRefreshProvider = Provider<Listenable>.internal(
  redirectRefresh,
  name: r'redirectRefreshProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$redirectRefreshHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RedirectRefreshRef = ProviderRef<Listenable>;
String _$appRouterHash() => r'17ac241bd525eee426d46fdbf11ecbd5d674dadf';

/// The app's routes and redirect rules.
///
/// Copied from [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = Provider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppRouterRef = ProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
