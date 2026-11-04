// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_details_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$medicineDetailsFormControllerHash() =>
    r'52b3dacf202b9abbbcf98eb3f5d09f5483d13f61';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MedicineDetailsFormController
    extends BuildlessAutoDisposeNotifier<MedicineDetailsState> {
  late final String medicationId;

  MedicineDetailsState build(
    String medicationId,
  );
}

/// One medication's details screen: its data, dose history and edit form.
///
/// Copied from [MedicineDetailsFormController].
@ProviderFor(MedicineDetailsFormController)
const medicineDetailsFormControllerProvider =
    MedicineDetailsFormControllerFamily();

/// One medication's details screen: its data, dose history and edit form.
///
/// Copied from [MedicineDetailsFormController].
class MedicineDetailsFormControllerFamily extends Family<MedicineDetailsState> {
  /// One medication's details screen: its data, dose history and edit form.
  ///
  /// Copied from [MedicineDetailsFormController].
  const MedicineDetailsFormControllerFamily();

  /// One medication's details screen: its data, dose history and edit form.
  ///
  /// Copied from [MedicineDetailsFormController].
  MedicineDetailsFormControllerProvider call(
    String medicationId,
  ) {
    return MedicineDetailsFormControllerProvider(
      medicationId,
    );
  }

  @override
  MedicineDetailsFormControllerProvider getProviderOverride(
    covariant MedicineDetailsFormControllerProvider provider,
  ) {
    return call(
      provider.medicationId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'medicineDetailsFormControllerProvider';
}

/// One medication's details screen: its data, dose history and edit form.
///
/// Copied from [MedicineDetailsFormController].
class MedicineDetailsFormControllerProvider
    extends AutoDisposeNotifierProviderImpl<MedicineDetailsFormController,
        MedicineDetailsState> {
  /// One medication's details screen: its data, dose history and edit form.
  ///
  /// Copied from [MedicineDetailsFormController].
  MedicineDetailsFormControllerProvider(
    String medicationId,
  ) : this._internal(
          () => MedicineDetailsFormController()..medicationId = medicationId,
          from: medicineDetailsFormControllerProvider,
          name: r'medicineDetailsFormControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$medicineDetailsFormControllerHash,
          dependencies: MedicineDetailsFormControllerFamily._dependencies,
          allTransitiveDependencies:
              MedicineDetailsFormControllerFamily._allTransitiveDependencies,
          medicationId: medicationId,
        );

  MedicineDetailsFormControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.medicationId,
  }) : super.internal();

  final String medicationId;

  @override
  MedicineDetailsState runNotifierBuild(
    covariant MedicineDetailsFormController notifier,
  ) {
    return notifier.build(
      medicationId,
    );
  }

  @override
  Override overrideWith(MedicineDetailsFormController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MedicineDetailsFormControllerProvider._internal(
        () => create()..medicationId = medicationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        medicationId: medicationId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<MedicineDetailsFormController,
      MedicineDetailsState> createElement() {
    return _MedicineDetailsFormControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MedicineDetailsFormControllerProvider &&
        other.medicationId == medicationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, medicationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MedicineDetailsFormControllerRef
    on AutoDisposeNotifierProviderRef<MedicineDetailsState> {
  /// The parameter `medicationId` of this provider.
  String get medicationId;
}

class _MedicineDetailsFormControllerProviderElement
    extends AutoDisposeNotifierProviderElement<MedicineDetailsFormController,
        MedicineDetailsState> with MedicineDetailsFormControllerRef {
  _MedicineDetailsFormControllerProviderElement(super.provider);

  @override
  String get medicationId =>
      (origin as MedicineDetailsFormControllerProvider).medicationId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
