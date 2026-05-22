// lib/domain/usecases/recurring/post_due_occurrences_use_case.dart
//
// Use case: post all due recurring occurrences on app launch or background
// sweep (T-101, T-120, SCHED-01).
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
//   4. Fetch stacked remind_and_confirm occurrences older than 24h (T-120).
//   5. Sort stacked ascending by scheduled_date; post each in order using
//      original scheduled_date as transaction date.
//   6. Return Ok(PostingResult) with separate auto_post and auto_approved counts.
//
// Spec: T-101, T-120, API Contracts §2.6.3, SCHED-01
//
// Test cases (see test/unit/domain/usecases/post_due_occurrences_use_case_test.dart):
//   1. zero due → Ok(PostingResult(0, 0)), no transactions created
//   2. one due auto_post expense → Ok(PostingResult(1, 0))
//   3. multiple due → Ok(PostingResult(n, 0)), all posted
//   4. paused template auto-resumed before posting
//   5. remind_and_confirm template → skipped from auto_post loop
// (see test/unit/domain/usecases/recurring/post_due_stacked_occurrences_test.dart):
//   T-120.1 zero stacked → autoApprovedCount = 0
//   T-120.2 one stacked > 24h → posted, count = 1
//   T-120.3 multiple stacked → chronological order
//   T-120.4 original scheduled_date used as tx date
//   T-120.5 < 24h occurrence NOT auto-approved
//   T-120.6 auto_post and auto_approved counted separately

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

// ---------------------------------------------------------------------------
// PostingResult
// ---------------------------------------------------------------------------

/// Result returned by [PostDueOccurrencesUseCase.call].
///
/// Separates auto-post count (auto_post templates) from auto-approved count
/// (remind_and_confirm templates that were stacked > 24h — T-120).
class PostingResult {
  /// Creates a [PostingResult].
  ///
  /// Parameters:
  /// - [autoPostedCount]: Occurrences from auto_post templates that were
  ///   posted in this sweep.
  /// - [autoApprovedCount]: Stacked remind_and_confirm occurrences that were
  ///   auto-approved (older than 24h) in this sweep.
  const PostingResult({
    required this.autoPostedCount,
    required this.autoApprovedCount,
  });

  /// Zero occurrences of either type.
  static const zero = PostingResult(autoPostedCount: 0, autoApprovedCount: 0);

  /// Count of auto_post template occurrences successfully posted.
  final int autoPostedCount;

  /// Count of stacked remind_and_confirm occurrences auto-approved.
  final int autoApprovedCount;

  /// Total occurrences posted (auto + approved).
  int get totalPosted => autoPostedCount + autoApprovedCount;
}

// ---------------------------------------------------------------------------
// Use case
// ---------------------------------------------------------------------------

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
  /// Returns [Ok(PostingResult)] with separate counts for auto-posted
  /// (auto_post templates) and auto-approved (stacked remind_and_confirm > 24h)
  /// occurrences. Errors in individual occurrences are logged and skipped;
  /// overall failure only occurs when the occurrence query itself fails.
  ///
  /// Parameters:
  /// - [asOf]: The reference date; occurrences with scheduled_date ≤ asOf
  ///   are considered due. Defaults to [DateTime.now()] when not provided.
  Future<Result<PostingResult>> call({DateTime? asOf}) async {
    final effectiveAsOf = asOf ?? DateTime.now();

    // Step 1: auto-resume paused templates whose pause_until <= asOf.
    await _autoResumePausedTemplates(effectiveAsOf);

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

    // Step 2: fetch all pending auto_post occurrences due on or before asOf.
    final pending = await _occurrenceRepository.getPendingDue(effectiveAsOf);

    // Step 3: post each due auto_post occurrence.
    var autoPosted = 0;
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
        autoPosted++;
      }
    }

    // Step 4: auto-approve stacked remind_and_confirm occurrences > 24h (T-120).
    var autoApproved = 0;
    try {
      final stacked =
          await _occurrenceRepository.getStackedRemindAndConfirm(effectiveAsOf);

      // Sort ascending by scheduled_date (repository may already sort, but
      // we guarantee it here per T-120 spec).
      final sorted = List<ScheduledOccurrence>.of(stacked)
        ..sort(
          (a, b) => a.scheduledDate.compareTo(b.scheduledDate),
        );

      for (final occurrence in sorted) {
        final template = templateCache[occurrence.templateId];
        if (template == null) {
          dev.log(
            'PostDueOccurrencesUseCase: template not found for stacked '
            'occurrence ${occurrence.id}; skipping.',
            name: 'PostDueOccurrencesUseCase',
          );
          continue;
        }

        // Only remind_and_confirm templates are eligible for auto-approval.
        if (template.postingBehaviour != PostingBehaviour.remindAndConfirm) {
          continue;
        }

        // Template must be active.
        if (template.status != RecurringTemplateStatus.active) {
          continue;
        }

        final result = await _postOccurrence(
          occurrence,
          template,
          isAutoApproved: true,
        );
        if (result case Ok()) {
          autoApproved++;
        }
      }
    } on Object catch (e) {
      // Auto-approval failure is non-fatal — log and return partial counts.
      dev.log(
        'PostDueOccurrencesUseCase: stacked auto-approval error: $e',
        name: 'PostDueOccurrencesUseCase',
      );
    }

    return Ok(
      PostingResult(
        autoPostedCount: autoPosted,
        autoApprovedCount: autoApproved,
      ),
    );
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
  /// When [isAutoApproved] is true, the transaction is posted with
  /// [TransactionPurpose.system] and uses the original [scheduled_date]
  /// as the transaction date (T-120). Duplicate-detection and overdraft
  /// warnings are suppressed for auto-approved occurrences.
  ///
  /// Parameters:
  /// - [occurrence]: The pending occurrence to post.
  /// - [template]: Parent recurring template providing financial fields.
  /// - [isAutoApproved]: Whether this is a stacked remind_and_confirm
  ///   occurrence being auto-approved (T-120). Defaults to false.
  Future<Result<void>> _postOccurrence(
    ScheduledOccurrence occurrence,
    RecurringTemplate template, {
    bool isAutoApproved = false,
  }) async {
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
