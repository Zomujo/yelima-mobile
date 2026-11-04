// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeControllerHash() => r'c17c7223e88a2653c38b0bf3f75373cf3ac0bd20';

/// The chosen app language (null until one is picked), saved between launches.
///
/// Copied from [LocaleController].
@ProviderFor(LocaleController)
final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>.internal(
  LocaleController.new,
  name: r'localeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleController = Notifier<Locale?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
