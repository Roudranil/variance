// lib/presentation/features/settings/recurring/recurring_template_list_notifier.dart
//
// RecurringTemplateListNotifier — Riverpod AsyncNotifier for the Recurring
// Templates List screen (T-108, S-43).
//
// State: AsyncValue<List<RecurringTemplate>>
// Source: IRecurringTemplateRepository.watchAll() stream filtered to
//         is_installment = false (recurring only).
//
// The stream is bridged via Completer pattern (consistent with
// CategoryListNotifier). The notifier stays alive while the screen
// is mounted; auto-disposed when the route is popped.
//
// Spec: UX Flows §9.13, API Contracts §2.6.4
//
// Test cases
// (see test/presentation/features/settings/recurring/recurring_template_list_notifier_test.dart):
//   1. Emits data when repository stream emits templates.
//   2. Emits only non-installment templates (is_installment = false).
//   3. Emits AsyncError when stream errors.

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'recurring_template_list_notifier.g.dart';

/// Reactive list of all non-deleted recurring templates (non-installment).
///
/// Bridges [IRecurringTemplateRepository.watchAll] into Riverpod's
/// [AsyncNotifier] lifecycle. Automatically filters out installment plans
/// ([RecurringTemplate.isInstallment] = true).
@riverpod
class RecurringTemplateList extends _$RecurringTemplateList {
  @override
  Future<List<RecurringTemplate>> build() async {
    final repo = await ref.watch(recurringTemplateRepositoryProvider.future);
    final stream = repo.watchAll();

    // Completer bridges the one-shot Future required by AsyncNotifier.build
    // with the ongoing stream subscription.
    final completer = Completer<List<RecurringTemplate>>();

    final sub = stream.listen(
      (templates) {
        // Filter to recurring-only (non-installment).
        final recurring = templates.where((t) => !t.isInstallment).toList();
        if (!completer.isCompleted) {
          completer.complete(recurring);
        } else {
          if (ref.mounted) state = AsyncData(recurring);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          if (ref.mounted) {
            state = AsyncError<List<RecurringTemplate>>(error, stack);
          }
        }
      },
    );

    ref.onDispose(sub.cancel);
    return completer.future;
  }
}
