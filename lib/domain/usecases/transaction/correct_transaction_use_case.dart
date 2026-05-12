// lib/domain/usecases/transaction/correct_transaction_use_case.dart
//
// Use case: correct an existing posted transaction (T-53).
//
// Three paths, all wrapped in a single database.transaction():
//
//   1. Financial edit (amount, currency, account, category, subcategory changed):
//      a. Set original status = 'voided'.
//      b. Insert reversal transaction (purpose = 'reversal',
//         corrects_transaction_id = original.id) with entries flipped.
//      c. Insert correction transaction (purpose = 'correction',
//         corrects_transaction_id = original.id) with new financial values.
//      — Only the correction appears in the default transaction list.
//
//   2. In-place edit (title, description, date_time, payee changed only):
//      UPDATE transactions SET title/description/date_time/... WHERE id = ?
//      No new entries; no reversal; no correction pair.
//
//   3. Soft-delete (void the transaction):
//      a. Set original status = 'voided'.
//      b. Insert reversal transaction (same as above, no correction row).
//      — Transaction excluded from default list and balance computation.
//
// Authoritative in-place field list (TC-018): title, description, photos, date_time.
// Financial fields: amount_minor, currency_code, account_source_id,
//   account_destination_id, category_id, subcategory_id.
//
// Correction chains (§3.3.1):
//   corrects_transaction_id → the immediately preceding transaction, not the root.
//
// Test cases (see test/unit/domain/usecases/correct_transaction_use_case_test.dart):
//   T-53.1. financial edit — voided + reversal + correction produced
//   T-53.2. in-place edit — direct UPDATE, no new transactions
//   T-53.3. soft-delete — voided + reversal, no correction
//   T-53.4. correction-of-correction — chain points to previous correction

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


/// Corrects an existing posted transaction following the immutability model.
///
/// Branches on whether changed fields are financial (correction chain) or
/// in-place (direct UPDATE). Soft-delete triggers void + reversal only.
/// All paths execute within a single database transaction.
class CorrectTransactionUseCase {
  /// Creates a [CorrectTransactionUseCase].
  ///
  /// Parameters:
  /// - [repository]: Provides both read and write access to transactions.
  /// - [ledgerEngine]: Builds balanced reversal and correction entry sets.
  const CorrectTransactionUseCase(
    this._repository,
    this._ledgerEngine,
  );

  final ITransactionRepository _repository;
  final LedgerEngine _ledgerEngine;

  /// Executes the correction for the transaction identified by [originalId].
  ///
  /// Returns the final visible transaction:
  /// - Financial edit → the correction transaction.
  /// - In-place edit → the updated original.
  /// - Soft-delete → Ok(null) (transaction is voided and hidden).
  ///
  /// Parameters:
  /// - [originalId]: UUID of the posted transaction to correct.
  /// - [updated]: The desired state, or null to soft-delete.
  Future<Result<Transaction?>> call({
    required String originalId,
    Transaction? updated,
  }) async {
    // Soft-delete path.
    if (updated == null) {
      return _softDelete(originalId);
    }

    // Retrieve the original to detect changed fields.
    Transaction? original;
    final originalStream = _repository.watchById(originalId);
    await for (final tx in originalStream) {
      original = tx;
      break;
    }

    if (original == null) {
      return Err(
        NotFoundFailure('Transaction $originalId not found.'),
      );
    }

    if (original.status == TransactionStatus.voided) {
      return const Err(
        BusinessRuleFailure('Cannot correct a voided transaction.'),
      );
    }

    // Determine which path to take.
    final hasFinancialChange = _hasFinancialChange(original, updated);

    if (!hasFinancialChange) {
      return _inPlaceEdit(original, updated);
    }

    return _financialCorrection(original, updated);
  }

  // -----------------------------------------------------------------------
  // Path 1: Financial correction
  // -----------------------------------------------------------------------

  Future<Result<Transaction?>> _financialCorrection(
    Transaction original,
    Transaction updated,
  ) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Select posting case for reversal (mirror of original).
    final originalPostingCase = _postingCaseFor(original);

    // Build reversal entries — same posting case, sides flipped.
    final reversalInput = CreateTransactionInput(
      postingCase: _reversalCaseFor(originalPostingCase),
      transactionId: original.id, // entries reference the reversal tx id below
      accountId: original.accountSourceId ?? original.accountDestinationId,
      destinationAccountId: original.accountDestinationId,
      categoryId: original.categoryId,
      feeCategoryId: null,
      amountMinor: original.amountMinor,
      feeAmountMinor: null,
      currencyCode: original.currencyCode,
      exchangeRateMicro: original.exchangeRateMicro,
      nowEpoch: nowEpoch,
    );

    final reversalBuild = await _ledgerEngine.buildOnly(reversalInput);
    List<Entry> reversalEntries;
    switch (reversalBuild) {
      case Ok(:final value):
        reversalEntries = value;
      case Err(:final failure):
        dev.log(
          'CorrectTransactionUseCase: reversal build failed — ${failure.message}',
          name: 'CorrectTransactionUseCase',
        );
        return Err(failure);
    }

    // Build correction entries — the new financial values.
    final correctionPostingCase = _postingCaseFor(updated);
    final correctionInput = CreateTransactionInput(
      postingCase: correctionPostingCase,
      transactionId: updated.id,
      accountId: updated.accountSourceId ?? updated.accountDestinationId,
      destinationAccountId: updated.accountDestinationId,
      categoryId: updated.categoryId,
      feeCategoryId: null,
      amountMinor: updated.amountMinor,
      feeAmountMinor: null,
      currencyCode: updated.currencyCode,
      exchangeRateMicro: updated.exchangeRateMicro,
      nowEpoch: nowEpoch,
    );

    final correctionBuild = await _ledgerEngine.buildOnly(correctionInput);
    List<Entry> correctionEntries;
    switch (correctionBuild) {
      case Ok(:final value):
        correctionEntries = value;
      case Err(:final failure):
        dev.log(
          'CorrectTransactionUseCase: correction build failed — ${failure.message}',
          name: 'CorrectTransactionUseCase',
        );
        return Err(failure);
    }

    // Construct the reversal transaction row.
    final reversalId = _uuid.v4();
    final reversal = Transaction(
      id: reversalId,
      type: original.type,
      status: TransactionStatus.posted,
      purpose: TransactionPurpose.reversal,
      dateTime: original.dateTime,
      amountMinor: original.amountMinor,
      currencyCode: original.currencyCode,
      exchangeRateMicro: original.exchangeRateMicro,
      homeCurrencyAtCapture: original.homeCurrencyAtCapture,
      accountSourceId: original.accountSourceId,
      accountDestinationId: original.accountDestinationId,
      categoryId: original.categoryId,
      subcategoryId: original.subcategoryId,
      correctsTransactionId: original.id,
      createdAt: nowEpoch,
      updatedAt: nowEpoch,
    );

    // Re-tag reversal entries to use the reversal tx id.
    final taggedReversalEntries = reversalEntries
        .map((e) => e.copyWith(transactionId: reversalId))
        .toList();

    // Correction transaction row uses the updated transaction's UUID.
    final correction = updated.copyWith(
      status: TransactionStatus.posted,
      purpose: TransactionPurpose.correction,
      correctsTransactionId: original.id,
      createdAt: nowEpoch,
      updatedAt: nowEpoch,
    );

    // Delegate the atomic write to the repository.
    final result = await _repository.correctFinancialChain(
      originalId: original.id,
      reversal: reversal,
      reversalEntries: taggedReversalEntries,
      correction: correction,
      correctionEntries: correctionEntries,
    );

    return switch (result) {
      Ok(:final value) => Ok(value),
      Err(:final failure) => Err(failure),
    };
  }

  // -----------------------------------------------------------------------
  // Path 2: In-place edit
  // -----------------------------------------------------------------------

  Future<Result<Transaction?>> _inPlaceEdit(
    Transaction original,
    Transaction updated,
  ) async {
    final patch = TransactionNonFinancialPatch(
      title: updated.title,
      description: updated.description,
      dateTime: updated.dateTime != original.dateTime ? updated.dateTime : null,
      payeeId: updated.payeeId,
    );

    final result = await _repository.updateNonFinancial(original.id, patch);
    return switch (result) {
      Ok(:final value) => Ok(value),
      Err(:final failure) => Err(failure),
    };
  }

  // -----------------------------------------------------------------------
  // Path 3: Soft-delete
  // -----------------------------------------------------------------------

  Future<Result<Transaction?>> _softDelete(String originalId) async {
    final result = await _repository.void$(originalId);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  /// Returns true if [updated] differs from [original] on any financial field.
  bool _hasFinancialChange(Transaction original, Transaction updated) {
    return original.amountMinor != updated.amountMinor ||
        original.currencyCode != updated.currencyCode ||
        original.accountSourceId != updated.accountSourceId ||
        original.accountDestinationId != updated.accountDestinationId ||
        original.categoryId != updated.categoryId ||
        original.subcategoryId != updated.subcategoryId;
  }

  /// Selects the posting case for [tx].
  PostingCase _postingCaseFor(Transaction tx) {
    return switch (tx.type) {
      TransactionType.expense => PostingCase.createExpense,
      TransactionType.income => PostingCase.createIncome,
      TransactionType.transfer => PostingCase.createTransfer,
    };
  }

  /// Returns the reversal posting case (sides flipped) for [postingCase].
  PostingCase _reversalCaseFor(PostingCase postingCase) {
    return switch (postingCase) {
      PostingCase.createExpense => PostingCase.modifyExpense,
      PostingCase.createIncome => PostingCase.modifyIncome,
      PostingCase.createTransfer => PostingCase.modifyTransfer,
      PostingCase.createTransferWithFee => PostingCase.modifyTransfer,
      _ => postingCase,
    };
  }
}
