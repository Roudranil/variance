// lib/presentation/providers/category_providers.dart
//
// Riverpod providers for reactive category data.
//
// Provider graph:
//   categoryListProvider  ← categoryRepositoryProvider (stream)
//
// Rules (SDS §2.2.2, §2.2.3):
//   - All providers use @riverpod annotation.
//   - categoryListProvider is auto-disposed (no keepAlive) — the list screen
//     manages its own lifecycle.
//   - The stream emitted by the repository is converted to an AsyncValue via
//     the StreamController pattern: listen → emit state changes, cancel on
//     dispose, return a Completer future so `build` resolves once the first
//     event arrives.
//
// Test cases (see test/providers/category_providers_test.dart):
//   1. categoryListProvider emits AsyncValue.data on stream emission
//   2. categoryListProvider emits AsyncValue.error when stream errors

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/category.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'category_providers.g.dart';

// ---------------------------------------------------------------------------
// CategoryListNotifier
// ---------------------------------------------------------------------------

/// Reactive list of all non-deleted categories (both income and expense trees).
///
/// Bridges the repository [Stream] into Riverpod's [AsyncNotifier] lifecycle:
/// - Subscribes once in [build] and forwards each event to [state].
/// - Cancels the subscription via [ref.onDispose].
/// - Returns a [Completer] future so [build] resolves after the first event.
@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final repo = await ref.watch(categoryRepositoryProvider.future);
    final stream = repo.watchAll();

    // Completer bridges the one-shot Future<List<Category>> required by
    // AsyncNotifier.build() with the ongoing stream subscription.
    final completer = Completer<List<Category>>();

    final sub = stream.listen(
      (categories) {
        // Complete the build future on the first event.
        if (!completer.isCompleted) {
          completer.complete(categories);
        } else {
          // Guard: only update state while the notifier is still mounted.
          if (ref.mounted) state = AsyncData(categories);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          if (ref.mounted) state = AsyncError<List<Category>>(error, stack);
        }
      },
    );

    // Cancel the subscription when the notifier is disposed.
    ref.onDispose(sub.cancel);

    return completer.future;
  }
}
