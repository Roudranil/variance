// lib/domain/usecases/transaction/create_transaction_use_case.dart
//
// Use case: create a new transaction and post it to the ledger.
//
// Covers:
//   T-49 — income and expense transaction creation
//   T-50 — transfer (same-currency, cross-currency, transfer-with-fee)
//
// Business rules enforced here:
//   1. amount > 0 (ValidationFailure)
//   2. account_source_id must be present for expense and transfer (ValidationFailure)
//   3. account_destination_id must be present for income and transfer (ValidationFailure)
//   4. category_id required for income and expense; null for transfer (ValidationFailure)
//   5. date_time must not be zero (ValidationFailure)
//   6. For cross-currency transfers: exchange_rate_micro must be non-null (ValidationFailure)
//   7. For transfer-with-fee: compound_group_id is auto-generated (UUID v4)
//   8. LedgerEngine.post() generates balanced entries atomically
//   9. Transaction header + entries are written in a single DB transaction
//
// Test cases (see test/unit/domain/usecases/create_transaction_use_case_test.dart):
//   1. valid expense → Ok(Transaction); entries created
//   2. valid income → Ok(Transaction); entries created
//   3. valid same-currency transfer → Ok(Transaction); entries created
//   4. valid cross-currency transfer → Ok(Transaction); exchange_rate_micro stored
//   5. valid transfer-with-fee → Ok(Transaction); compound_group_id set; fee entries created
//   6. amount = 0 → Err(ValidationFailure)
//   7. expense missing category_id → Err(ValidationFailure)
//   8. income missing account_destination_id → Err(ValidationFailure)
//   9. transfer with same currency missing exchange_rate_micro → Ok (no rate needed)
//  10. cross-currency transfer missing exchange_rate_micro → Err(ValidationFailure)
//  11. expense missing account_source_id → Err(ValidationFailure)

import 'dart:developer' as dev;

import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/services/posting_case_selector.dart';

// ignore: prefer_const_constructors — Uuid() must not be const
final _uuid = Uuid();

/// Creates a new transaction and posts it to the ledger atomically.
///
/// Validates all business rules before any write. Delegates entry generation
/// to [LedgerEngine] and persistence to [TransactionRepositoryImpl].
class CreateTransactionUseCase {
  /// Creates a [CreateTransactionUseCase].
  ///
  /// Parameters:
  /// - [repository]: The concrete repository for writing transactions.
  /// - [ledgerEngine]: Engine for building and persisting balanced entries.
  const CreateTransactionUseCase(this._repository, this._ledgerEngine);

  final ITransactionRepository _repository;
  final LedgerEngine _ledgerEngine;

  /// Validates and persists [draft], then posts balanced ledger entries.
  ///
  /// Returns [Ok] wrapping the persisted [Transaction] on success.
  /// Returns [Err] wrapping a [Failure] on validation or DB error.
  ///
  /// Parameters:
  /// - [draft]: A fully formed [Transaction] with a pre-assigned UUID.
  ///   For transfer-with-fee, [draft.compoundRole] = 'primary';
  ///   the fee leg is constructed internally.
  /// - [feeCategoryId]: For transfer-with-fee: the category UUID for the fee
  ///   expense leg. Pass null for plain transfers.
  /// - [feeAmountMinor]: For transfer-with-fee: fee amount in minor units.
  ///   Pass null for plain transfers.
  Future<Result<Transaction>> call(
    Transaction draft, {
    String? feeCategoryId,
    int? feeAmountMinor,
  }) async {
    // --- Validation ---
    final validationError = _validate(
      draft,
      feeCategoryId: feeCategoryId,
      feeAmountMinor: feeAmountMinor,
    );
    if (validationError != null) return Err(validationError);

    // --- Determine posting case ---
    final postingCase = _selectPostingCase(
      draft,
      hasFee: feeCategoryId != null,
    );

    // --- Assign compound group for transfer-with-fee ---
    final Transaction txnToWrite;
    if (postingCase == PostingCase.createTransferWithFee) {
      final groupId = _uuid.v4();
      txnToWrite = draft.copyWith(
        compoundGroupId: groupId,
        compoundRole: 'primary',
      );
    } else {
      txnToWrite = draft;
    }

    // --- Build the nowEpoch for entry createdAt ---
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // --- Post ledger entries via LedgerEngine ---
    final ledgerInput = CreateTransactionInput(
      postingCase: postingCase,
      transactionId: txnToWrite.id,
      accountId: txnToWrite.accountSourceId ?? txnToWrite.accountDestinationId,
      destinationAccountId: txnToWrite.accountDestinationId,
      categoryId: txnToWrite.categoryId,
      feeCategoryId: feeCategoryId,
      amountMinor: txnToWrite.amountMinor,
      feeAmountMinor: feeAmountMinor,
      currencyCode: txnToWrite.currencyCode,
      exchangeRateMicro: txnToWrite.exchangeRateMicro,
      nowEpoch: nowEpoch,
    );

    // Build entries without persisting — the repository write is atomic below.
    final buildResult = await _ledgerEngine.buildOnly(ledgerInput);
    final List<Entry> entries;
    switch (buildResult) {
      case Ok(:final value):
        entries = value;
      case Err(:final failure):
        dev.log(
          'CreateTransactionUseCase: ledger build failed: ${failure.message}',
          name: 'CreateTransactionUseCase',
        );
        return Err(failure);
    }

    // --- Persist transaction header + entries atomically (SDS §1.6.2) ---
    final saveResult = await _repository.createWithEntries(txnToWrite, entries);
    return switch (saveResult) {
      Ok(:final value) => Ok(value),
      Err(:final failure) => Err(failure),
    };
  }

  // -----------------------------------------------------------------------
  // Posting case selection
  // -----------------------------------------------------------------------

  /// Selects the appropriate [PostingCase] for [draft].
  PostingCase _selectPostingCase(Transaction draft, {required bool hasFee}) {
    return switch (draft.type) {
      TransactionType.expense => PostingCase.createExpense,
      TransactionType.income => PostingCase.createIncome,
      TransactionType.transfer =>
        hasFee ? PostingCase.createTransferWithFee : PostingCase.createTransfer,
    };
  }

  // -----------------------------------------------------------------------
  // Validation
  // -----------------------------------------------------------------------

  /// Returns a [Failure] if [draft] fails any business rule, or null if valid.
  Failure? _validate(
    Transaction draft, {
    String? feeCategoryId,
    int? feeAmountMinor,
  }) {
    // Rule 1 — amount > 0
    if (draft.amountMinor <= 0) {
      return const ValidationFailure(
        'Transaction amount must be greater than 0.',
      );
    }

    // Rule 5 — dateTime must be set
    if (draft.dateTime == 0) {
      return const ValidationFailure('Transaction date must be set.');
    }

    return switch (draft.type) {
      TransactionType.expense => _validateExpense(draft),
      TransactionType.income => _validateIncome(draft),
      TransactionType.transfer => _validateTransfer(
          draft,
          feeCategoryId: feeCategoryId,
          feeAmountMinor: feeAmountMinor,
        ),
    };
  }

  Failure? _validateExpense(Transaction draft) {
    // Rule 2 — account_source_id required for expense
    if (draft.accountSourceId == null || draft.accountSourceId!.isEmpty) {
      return const ValidationFailure(
        'Expense transactions require a source account.',
      );
    }
    // Rule 4 — category_id required for expense
    if (draft.categoryId == null || draft.categoryId!.isEmpty) {
      return const ValidationFailure(
        'Expense transactions require a category.',
      );
    }
    return null;
  }

  Failure? _validateIncome(Transaction draft) {
    // Rule 3 — account_destination_id required for income
    if (draft.accountDestinationId == null ||
        draft.accountDestinationId!.isEmpty) {
      return const ValidationFailure(
        'Income transactions require a destination account.',
      );
    }
    // Rule 4 — category_id required for income
    if (draft.categoryId == null || draft.categoryId!.isEmpty) {
      return const ValidationFailure(
        'Income transactions require a category.',
      );
    }
    return null;
  }

  Failure? _validateTransfer(
    Transaction draft, {
    String? feeCategoryId,
    int? feeAmountMinor,
  }) {
    // Rule 2 — account_source_id required for transfer
    if (draft.accountSourceId == null || draft.accountSourceId!.isEmpty) {
      return const ValidationFailure(
        'Transfer transactions require a source account.',
      );
    }
    // Rule 3 — account_destination_id required for transfer
    if (draft.accountDestinationId == null ||
        draft.accountDestinationId!.isEmpty) {
      return const ValidationFailure(
        'Transfer transactions require a destination account.',
      );
    }
    // Rule 6 — cross-currency transfer requires exchange_rate_micro
    // (Only when the currencies are different — caller must pass source and
    // destination currency codes if they differ; this check is based on the
    // transaction currency vs home currency implied by exchange_rate_micro
    // presence being required by the data model for cross-currency).
    // Per TC-029: exchange_rate_micro is NULL only when currencies are equal.
    // The use case validates that cross-currency transfers supply the rate.
    // We detect cross-currency by the presence of homeCurrencyAtCapture — if
    // that is set, it means the UI detected a currency mismatch.
    if (draft.homeCurrencyAtCapture != null &&
        draft.exchangeRateMicro == null) {
      return const ValidationFailure(
        'Cross-currency transfers require an exchange rate (exchange_rate_micro).',
      );
    }
    // Transfer-with-fee validation
    if (feeCategoryId != null) {
      if (feeAmountMinor == null || feeAmountMinor <= 0) {
        return const ValidationFailure(
          'Transfer-with-fee requires a positive fee amount.',
        );
      }
    }
    return null;
  }
}
