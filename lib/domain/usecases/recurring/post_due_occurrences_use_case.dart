// lib/domain/usecases/recurring/post_due_occurrences_use_case.dart
//
// Use case: post all due recurring occurrences on app launch or background
// sweep (T-101, SCHED-01).
//
// Behaviour:
//   1. Auto-resume all paused templates whose pause_until ≤ asOf.
//   2. Fetch all pending occurrences with scheduled_date ≤ asOf.
//   3. For each pending occurrence (auto_post templates only):
//      a. Load the parent template.
//      b. Skip if template is not active or not auto_post.
//      c. Build a Transaction from the template fields.
//      d. Call LedgerEngine.buildOnly to get balanced entries.
//      e. Call ITransactionRepository.createWithEntries atomically.
//      f. Call markPosted(occurrenceId, transactionId).
//   4. Return Ok(count) where count is the number successfully posted.
//
// Spec: T-101, API Contracts §2.6.3, SCHED-01
//
// Test cases (see test/unit/domain/usecases/post_due_occurrences_use_case_test.dart):
//   1. zero due → Ok(0), no transactions created
//   2. one due auto_post expense → Ok(1), transaction created, occurrence posted
//   3. multiple due → Ok(n), all posted
//   4. paused template auto-resumed before posting
//   5. remind_and_confirm template → skipped, not posted

import 'dart:developer' as dev;

import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/services/posting_case_selector.dart';

// ignore: prefer_const_constructors — Uuid must not be const
final _uuid = Uuid();

/// Posts all auto_post occurrences whose `scheduled_date ≤ asOf`.
///
/// Also auto-resumes any paused templates whose `pause_until ≤ asOf` before
/// the posting loop, per SCHED-01 specification.
///
/// Returns [Ok(n)] where n is the number of occurrences successfully posted.
/// Called on every app launch ([AppInitializer]) and by the background
/// [PostingSweeperWorker].
class PostDueOccurrencesUseCase {
  /// Creates a [PostDueOccurrencesUseCase].
  ///
  /// Parameters:
  /// - [templateRepository]: Repository for reading and updating templates.
  /// - [occurrenceRepository]: Repository for pending occurrence queries and
  ///   status mutations.
  /// - [transactionRepository]: Repository for atomically writing transactions
  ///   and their ledger entries.
  /// - [ledgerEngine]: Builds balanced entry sets from [CreateTransactionInput].
  const PostDueOccurrencesUseCase(
    this._templateRepository,
    this._occurrenceRepository,
    this._transactionRepository,
    this._ledgerEngine,
  );

  final IRecurringTemplateRepository _templateRepository;
  final IScheduledOccurrenceRepository _occurrenceRepository;
  final ITransactionRepository _transactionRepository;
  final LedgerEngine _ledgerEngine;

  // Singleton selector — stateless, safe to share.
  static const _selector = PostingCaseSelector();

  /// Executes the posting sweep as of [asOf].
  ///
  /// Returns [Ok(n)] where n is the number of occurrences posted.
  /// Errors in individual occurrences are logged and skipped; overall
  /// failure only occurs when the occurrence query itself fails.
  ///
  /// Parameters:
  /// - [asOf]: The reference date; occurrences with scheduled_date ≤ asOf
  ///   are considered due. Defaults to [DateTime.now()] when not provided.
  Future<Result<int>> call({DateTime? asOf}) async {
    final effectiveAsOf = asOf ?? DateTime.now();

    // Step 1: auto-resume paused templates whose pause_until <= asOf.
    await _autoResumePausedTemplates(effectiveAsOf);

    // Step 2: fetch all pending occurrences due on or before asOf.
    final pending = await _occurrenceRepository.getPendingDue(effectiveAsOf);

    if (pending.isEmpty) return const Ok(0);

    // Build a template cache from watchAll (one stream read for all templates).
    final templateCache = <String, RecurringTemplate>{};
    try {
      final allTemplates = await _templateRepository.watchAll().first;
      for (final t in allTemplates) {
        templateCache[t.id] = t;
      }
    } on Object catch (e) {
      dev.log(
        'PostDueOccurrencesUseCase: failed to load templates: $e',
        name: 'PostDueOccurrencesUseCase',
      );
      return Err(DatabaseFailure('Failed to load recurring templates: $e'));
    }

    // Step 3: post each due occurrence.
    var posted = 0;
    for (final occurrence in pending) {
      final template = templateCache[occurrence.templateId];
      if (template == null) {
        dev.log(
          'PostDueOccurrencesUseCase: template not found for occurrence '
          '${occurrence.id}; skipping.',
          name: 'PostDueOccurrencesUseCase',
        );
        continue;
      }

      // Only auto-post templates are posted in the sweep.
      if (template.postingBehaviour != PostingBehaviour.autoPost) {
        continue;
      }

      // Template must be active (not paused, deleted, archived).
      if (template.status != RecurringTemplateStatus.active) {
        continue;
      }

      final result = await _postOccurrence(occurrence, template);
      if (result case Ok()) {
        posted++;
      }
    }

    return Ok(posted);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Resumes all paused templates whose pause_until ≤ [asOf] (epoch seconds).
  Future<void> _autoResumePausedTemplates(DateTime asOf) async {
    try {
      final allTemplates = await _templateRepository.watchAll().first;
      final asOfEpoch = asOf.millisecondsSinceEpoch ~/ 1000;
      for (final t in allTemplates) {
        if (t.status == RecurringTemplateStatus.paused &&
            t.pauseUntil != null &&
            t.pauseUntil! <= asOfEpoch) {
          await _templateRepository.resume(t.id);
        }
      }
    } on Object catch (e) {
      // Auto-resume failure is non-fatal — log and continue.
      dev.log(
        'PostDueOccurrencesUseCase: auto-resume error: $e',
        name: 'PostDueOccurrencesUseCase',
      );
    }
  }

  /// Posts a single occurrence by building a transaction from its template.
  ///
  /// Returns [Ok(null)] on success or [Err] on failure.
  ///
  /// Parameters:
  /// - [occurrence]: The pending occurrence to post.
  /// - [template]: Parent recurring template providing financial fields.
  Future<Result<void>> _postOccurrence(
    ScheduledOccurrence occurrence,
    RecurringTemplate template,
  ) async {
    try {
      final txId = _uuid.v4();
      final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Convert scheduled_date (epoch days) to epoch seconds for dateTime.
      final dateTimeSecs = occurrence.scheduledDate * 86400;

      // Determine the TransactionType and LedgerEventType from the template.
      final (type, eventType) = switch (template.transactionType) {
        'income' => (
            TransactionType.income,
            LedgerEventType.recurringAutoPostIncome,
          ),
        'transfer' => (
            TransactionType.transfer,
            LedgerEventType.recurringAutoPostTransfer,
          ),
        _ => (
            TransactionType.expense,
            LedgerEventType.recurringAutoPostExpense,
          ),
      };

      final postingCase = _selector.select(
        eventType: eventType,
        entityState: const EntityState(),
      );

      // Build the Transaction entity.
      final draft = Transaction(
        id: txId,
        type: type,
        status: TransactionStatus.posted,
        purpose: TransactionPurpose.system,
        dateTime: dateTimeSecs,
        amountMinor: template.amountMinor,
        currencyCode: template.currencyCode,
        accountSourceId: template.accountSourceId,
        accountDestinationId: template.accountDestinationId,
        categoryId: template.categoryId,
        subcategoryId: template.subcategoryId,
        payeeId: template.payeeId,
        title: template.title ?? 'Recurring: ${template.transactionType}',
        createdAt: nowEpoch,
        updatedAt: nowEpoch,
      );

      // Build balanced ledger entries via LedgerEngine.
      final ledgerInput = CreateTransactionInput(
        postingCase: postingCase,
        transactionId: txId,
        amountMinor: template.amountMinor,
        currencyCode: template.currencyCode,
        nowEpoch: nowEpoch,
        accountId: template.accountSourceId ?? template.accountDestinationId,
        destinationAccountId: template.accountDestinationId,
        categoryId: template.categoryId,
        isRecurringAutoPost: true,
      );

      final entriesResult = await _ledgerEngine.buildOnly(ledgerInput);
      if (entriesResult case Err(:final failure)) {
        dev.log(
          'PostDueOccurrencesUseCase: buildOnly failed for occurrence '
          '${occurrence.id}: ${failure.message}',
          name: 'PostDueOccurrencesUseCase',
        );
        return Err(failure);
      }
      final entries = (entriesResult as Ok<List<Entry>>).value;

      // Write transaction + entries atomically.
      final saveResult = await _transactionRepository.createWithEntries(
        draft,
        entries,
      );
      if (saveResult case Err(:final failure)) {
        dev.log(
          'PostDueOccurrencesUseCase: save failed for occurrence '
          '${occurrence.id}: ${failure.message}',
          name: 'PostDueOccurrencesUseCase',
        );
        return Err(failure);
      }

      // Mark occurrence as posted.
      await _occurrenceRepository.markPosted(occurrence.id, txId);
      return const Ok(null);
    } on Object catch (e) {
      dev.log(
        'PostDueOccurrencesUseCase: unexpected error posting occurrence '
        '${occurrence.id}: $e',
        name: 'PostDueOccurrencesUseCase',
      );
      return Err(DatabaseFailure('Unexpected error: $e'));
    }
  }
}
