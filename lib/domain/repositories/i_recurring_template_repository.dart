// lib/domain/repositories/i_recurring_template_repository.dart
//
// Abstract repository interface for the RecurringTemplate aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';

/// Contract for all RecurringTemplate data-access operations.
abstract interface class IRecurringTemplateRepository {
  /// Watches all non-deleted templates (both recurring and installment).
  Stream<List<RecurringTemplate>> watchAll();

  /// Watches a single template by UUID.
  Stream<RecurringTemplate?> watchById(String id);

  /// Persists a new template.
  Future<Result<RecurringTemplate>> create(RecurringTemplate template);

  /// Updates an editable template (amount, accounts, category, title, etc.).
  Future<Result<RecurringTemplate>> update(RecurringTemplate template);

  /// Transitions a template to status = paused with the given [pauseUntil] epoch.
  ///
  /// [pauseUntil] is a Unix epoch second representing when the template should
  /// automatically resume. Must be strictly in the future.
  Future<Result<void>> pause(String id, {required int pauseUntil});

  /// Transitions a paused template back to status = active.
  Future<Result<void>> resume(String id);

  /// Soft-deletes a template; cancels all pending occurrences.
  Future<Result<void>> softDelete(String id);

  /// Returns all active templates whose next occurrence is on or before [asOf].
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf);
}
