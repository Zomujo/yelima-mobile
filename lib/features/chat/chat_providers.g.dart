// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiChatLocalDataSourceHash() =>
    r'3be541da31ad5b0fc8df9698dfb732119998994f';

/// Chat messages saved on the phone.
///
/// Copied from [aiChatLocalDataSource].
@ProviderFor(aiChatLocalDataSource)
final aiChatLocalDataSourceProvider = Provider<AiChatLocalDataSource>.internal(
  aiChatLocalDataSource,
  name: r'aiChatLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiChatLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiChatLocalDataSourceRef = ProviderRef<AiChatLocalDataSource>;
String _$aiChatRemoteDataSourceHash() =>
    r'52e769b99f015e3ace08ff81579fa0f8f5f7fc7a';

/// The AI chat on the server, answering in the app's language.
///
/// Copied from [aiChatRemoteDataSource].
@ProviderFor(aiChatRemoteDataSource)
final aiChatRemoteDataSourceProvider =
    Provider<AiChatRemoteDataSource>.internal(
  aiChatRemoteDataSource,
  name: r'aiChatRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiChatRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiChatRemoteDataSourceRef = ProviderRef<AiChatRemoteDataSource>;
String _$aiChatRepositoryHash() => r'cfd57f4c5255ad1acb52085e2c8295b847bd5781';

/// AI chat conversations, saved on the phone first and synced.
///
/// Copied from [aiChatRepository].
@ProviderFor(aiChatRepository)
final aiChatRepositoryProvider = Provider<AiChatRepository>.internal(
  aiChatRepository,
  name: r'aiChatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aiChatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiChatRepositoryRef = ProviderRef<AiChatRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
