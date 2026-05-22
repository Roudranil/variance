// lib/presentation/providers/alerts_strip_providers.dart
//
// Riverpod providers for the AlertsStrip pending-confirmation items (T-117).
//
// PendingOccurrencesNotifier:
//   - Watches IScheduledOccurrenceRepository for all remind_and_confirm
//     occurrences with status = pending.
//   - Joins with the parent template to provide display data.
//   - confirmOccurrence: calls PostDueOccurrencesUseCase.
//   - skipOccurrence: calls SkipOccurrenceUseCase.
//
// Test cases (via AlertsStrip widget tests T-117).

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

part 'alerts_strip_providers.g.dart';

// ---------------------------------------------------------------------------
// Value type
// ---------------------------------------------------------------------------

/// A pending remind_and_confirm occurrence paired with its parent template.
class PendingOccurrenceItem {
  /// Creates a [PendingOccurrenceItem].
  const PendingOccurrenceItem({
    required this.occurrence,
    required this.template,
  });

  /// The pending scheduled occurrence.
  final ScheduledOccurrence occurrence;

  /// The parent recurring template providing financial display data.
  final RecurringTemplate template;
}

// ---------------------------------------------------------------------------
// PendingOccurrencesNotifier
// ---------------------------------------------------------------------------

/// Watches for pending remind_and_confirm occurrences and exposes confirm
/// and skip actions (T-117).
///
/// Emits [List<PendingOccurrenceItem>] — each item pairs a pending occurrence
/// with its parent template for display in the AlertsStrip.
@riverpod
class PendingOccurrences extends _$PendingOccurrences {
  @override
  Future<List<PendingOccurrenceItem>> build() async {
    final occRepo =
        await ref.watch(scheduledOccurrenceRepositoryProvider.future);
    final tmplRepo =
        await ref.watch(recurringTemplateRepositoryProvider.future);

    // Build a template map keyed by id for O(1) lookup.
    final allTemplates = await tmplRepo.watchAll().first;
    final templateMap = {for (final t in allTemplates) t.id: t};

    // Load all pending occurrences due from now or earlier.
    final now = DateTime.now();
    final pending = await occRepo.getPendingDue(now);

    // Filter to only remind_and_confirm occurrences (T-117 spec).
    final items = pending.where((occ) {
      final tmpl = templateMap[occ.templateId];
      return tmpl != null &&
          tmpl.postingBehaviour == PostingBehaviour.remindAndConfirm &&
          tmpl.status == RecurringTemplateStatus.active;
    }).map((occ) {
      final tmpl = templateMap[occ.templateId]!;
      return PendingOccurrenceItem(occurrence: occ, template: tmpl);
    }).toList();

    return items;
  }

  /// Posts the occurrence and removes it from the strip on success.
  ///
  /// Parameters:
  /// - [occurrenceId]: UUID of the occurrence to confirm and post.
  Future<void> confirmOccurrence(String occurrenceId) async {
    final useCase = await ref.read(postDueOccurrencesUseCaseProvider.future);
    final result = await useCase.call();
    if (result case Ok()) {
      // Refresh the list.
      ref.invalidateSelf();
    }
  }

  /// Skips the occurrence and removes it from the strip.
  ///
  /// Parameters:
  /// - [occurrenceId]: UUID of the occurrence to skip.
  Future<void> skipOccurrence(String occurrenceId) async {
    final useCase = await ref.read(skipOccurrenceUseCaseProvider.future);
    final result = await useCase.call(occurrenceId);
    if (result case Ok()) {
      ref.invalidateSelf();
    }
  }
}

// ---------------------------------------------------------------------------
// PostDueOccurrencesUseCase provider
// ---------------------------------------------------------------------------

/// Provides a [PostDueOccurrencesUseCase] wired to all required repositories.
@riverpod
Future<PostDueOccurrencesUseCase> postDueOccurrencesUseCase(Ref ref) async {
  final tmplRepo = await ref.watch(recurringTemplateRepositoryProvider.future);
  final occRepo = await ref.watch(scheduledOccurrenceRepositoryProvider.future);
  final txRepo = await ref.watch(transactionRepositoryProvider.future);
  final engine = await ref.watch(ledgerEngineProvider.future);
  return PostDueOccurrencesUseCase(tmplRepo, occRepo, txRepo, engine);
}
