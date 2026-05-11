// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_category_wizard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier owning the category deletion wizard state.
///
/// The [categoryId] identifies the category being deleted. The notifier
/// queries template and transaction counts at initialization and drives the
/// step machine.

@ProviderFor(DeleteCategoryWizard)
final deleteCategoryWizardProvider = DeleteCategoryWizardFamily._();

/// Riverpod notifier owning the category deletion wizard state.
///
/// The [categoryId] identifies the category being deleted. The notifier
/// queries template and transaction counts at initialization and drives the
/// step machine.
final class DeleteCategoryWizardProvider
    extends $NotifierProvider<DeleteCategoryWizard, DeleteCategoryWizardState> {
  /// Riverpod notifier owning the category deletion wizard state.
  ///
  /// The [categoryId] identifies the category being deleted. The notifier
  /// queries template and transaction counts at initialization and drives the
  /// step machine.
  DeleteCategoryWizardProvider._(
      {required DeleteCategoryWizardFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'deleteCategoryWizardProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteCategoryWizardHash();

  @override
  String toString() {
    return r'deleteCategoryWizardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeleteCategoryWizard create() => DeleteCategoryWizard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteCategoryWizardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteCategoryWizardState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteCategoryWizardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteCategoryWizardHash() =>
    r'd85bfef8a932f07e2e4d8758e91192cd561562fe';

/// Riverpod notifier owning the category deletion wizard state.
///
/// The [categoryId] identifies the category being deleted. The notifier
/// queries template and transaction counts at initialization and drives the
/// step machine.

final class DeleteCategoryWizardFamily extends $Family
    with
        $ClassFamilyOverride<DeleteCategoryWizard, DeleteCategoryWizardState,
            DeleteCategoryWizardState, DeleteCategoryWizardState, String> {
  DeleteCategoryWizardFamily._()
      : super(
          retry: null,
          name: r'deleteCategoryWizardProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Riverpod notifier owning the category deletion wizard state.
  ///
  /// The [categoryId] identifies the category being deleted. The notifier
  /// queries template and transaction counts at initialization and drives the
  /// step machine.

  DeleteCategoryWizardProvider call(
    String categoryId,
  ) =>
      DeleteCategoryWizardProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'deleteCategoryWizardProvider';
}

/// Riverpod notifier owning the category deletion wizard state.
///
/// The [categoryId] identifies the category being deleted. The notifier
/// queries template and transaction counts at initialization and drives the
/// step machine.

abstract class _$DeleteCategoryWizard
    extends $Notifier<DeleteCategoryWizardState> {
  late final _$args = ref.$arg as String;
  String get categoryId => _$args;

  DeleteCategoryWizardState build(
    String categoryId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<DeleteCategoryWizardState, DeleteCategoryWizardState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DeleteCategoryWizardState, DeleteCategoryWizardState>,
        DeleteCategoryWizardState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
