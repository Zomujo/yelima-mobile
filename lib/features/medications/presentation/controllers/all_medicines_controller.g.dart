// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_medicines_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allMedicinesControllerHash() =>
    r'd5e4b22738daba6096c519db4be4136cec95544b';

/// The all-medicines list, kept live from the phone's database; null until loaded.
///
/// Copied from [AllMedicinesController].
@ProviderFor(AllMedicinesController)
final allMedicinesControllerProvider =
    NotifierProvider<AllMedicinesController, List<MedicationEntity>?>.internal(
  AllMedicinesController.new,
  name: r'allMedicinesControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allMedicinesControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllMedicinesController = Notifier<List<MedicationEntity>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
