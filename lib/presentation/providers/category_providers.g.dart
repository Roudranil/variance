// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive list of all non-deleted categories (both income and expense trees).
///
/// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle:
/// - Subscribes once in [build] and forwards each event to [state].
/// - Cancels the subscription via [ref.onDispose].
/// - Returns a [Completer] future so [build] resolves after the first event.

@ProviderFor(CategoryList)
final categoryListProvider = CategoryListProvider._();

/// Reactive list of all non-deleted categories (both income and expense trees).
///
/// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle:
/// - Subscribes once in [build] and forwards each event to [state].
/// - Cancels the subscription via [ref.onDispose].
/// - Returns a [Completer] future so [build] resolves after the first event.
final class CategoryListProvider
    extends $AsyncNotifierProvider<CategoryList, List<Category>> {
  /// Reactive list of all non-deleted categories (both income and expense trees).
  ///
  /// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle:
  /// - Subscribes once in [build] and forwards each event to [state].
  /// - Cancels the subscription via [ref.onDispose].
  /// - Returns a [Completer] future so [build] resolves after the first event.
  CategoryListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @$internal
  @override
  CategoryList create() => CategoryList();
}

String _$categoryListHash() => r'e8b6c8afd2db46d895aa79f34bab9ff6855cbf46';

/// Reactive list of all non-deleted categories (both income and expense trees).
///
/// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle:
/// - Subscribes once in [build] and forwards each event to [state].
/// - Cancels the subscription via [ref.onDispose].
/// - Returns a [Completer] future so [build] resolves after the first event.

abstract class _$CategoryList extends $AsyncNotifier<List<Category>> {
  FutureOr<List<Category>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
        AsyncValue<List<Category>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
