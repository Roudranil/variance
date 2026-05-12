// lib/domain/usecases/transaction/post_pending_transactions_use_case.dart
//
// Use case: post entries for pending transactions whose date has arrived (T-60).
//
// Called on app launch (SCHED-01 integration point).
//
// Business rules:
//   - Query all transactions where status = 'pending' AND date_time <= now.
//   - For each: build balanced entries via LedgerEngine, persist entries,
//     set status = 'posted' — all in a single DB transaction per row.
//   - Failed rows are logged and skipped; other rows continue.
//
// Test cases (see test/unit/domain/usecases/post_pending_transactions_use_case_test.dart):
//   T-60.1. pending transaction past due → entries written, status → posted
//   T-60.2. pending transaction not yet due → skipped
//   T-60.3. no pending transactions → Ok(0)

import 'dart:developer' as dev;

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/services/posting_case_selector.dart';

/// Posts ledger entries for all pending transactions whose date_time is now or
/// in the past.
///
/// Called on app launch to sweep any transactions that became due while the app
/// was closed.
class PostPendingTransactionsUseCase {
  /// Creates a [PostPendingTransactionsUseCase].
  ///
  /// Parameters:
  /// - [repository]: Provides pending transaction reads and status updates.
  /// - [ledgerEngine]: Builds balanced entries for each due transaction.
  const PostPendingTransactionsUseCase(this._repository, this._ledgerEngine);

  final ITransactionRepository _repository;
  final LedgerEngine _ledgerEngine;

  /// Executes the sweep.
  ///
  /// Returns [Ok(int)] with the count of successfully posted transactions.
  Future<Result<int>> call() async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Fetch all pending transactions due now or in the past.
    final duePending = await _repository.getDuePendingTransactions(nowEpoch);

    int posted = 0;
    for (final tx in duePending) {
      try {
        await _postOne(tx, nowEpoch);
        posted++;
      } on Exception catch (e) {
        dev.log(
          'PostPendingTransactionsUseCase: failed to post ${tx.id} — $e',
          name: 'PostPendingTransactionsUseCase',
        );
        // Continue to next; do not abort the entire sweep on one failure.
      }
    }

    return Ok(posted);
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  Future<void> _postOne(Transaction tx, int nowEpoch) async {
    final postingCase = _postingCaseFor(tx);

    final ledgerInput = CreateTransactionInput(
      postingCase: postingCase,
      transactionId: tx.id,
      accountId: tx.accountSourceId ?? tx.accountDestinationId,
      destinationAccountId: tx.accountDestinationId,
      categoryId: tx.categoryId,
      feeCategoryId: null,
      amountMinor: tx.amountMinor,
      feeAmountMinor: null,
      currencyCode: tx.currencyCode,
      exchangeRateMicro: tx.exchangeRateMicro,
      nowEpoch: nowEpoch,
    );

    final buildResult = await _ledgerEngine.buildOnly(ledgerInput);
    switch (buildResult) {
      case Err(:final failure):
        throw Exception('ledger build failed: ${failure.message}');
      case Ok(:final value):
        final saveResult = await _repository.postPending(tx.id, value);
        switch (saveResult) {
          case Err(:final failure):
            throw Exception('postPending failed: ${failure.message}');
          case Ok():
            break;
        }
    }
  }

  PostingCase _postingCaseFor(Transaction tx) {
    return switch (tx.type) {
      TransactionType.expense => PostingCase.createExpense,
      TransactionType.income => PostingCase.createIncome,
      TransactionType.transfer => PostingCase.createTransfer,
    };
  }
}
