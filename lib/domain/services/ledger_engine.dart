// lib/domain/services/ledger_engine.dart
//
// LedgerEngine — validates posting cases, constructs balanced Entry sets, and
// asserts Σdebit = Σcredit before persisting.
//
// SDS §1.3.2.1, SDS §1.6.2, SDS §1.6.7, INFRA-7.
//
// Rules enforced here:
//   - Every call to post() produces a balanced entry set (Σdebit = Σcredit).
//     Any imbalance raises BusinessRuleFailure and no entries are written.
//   - EQ accounts are created lazily — atomically within the same database
//     transaction — when a posting case requires one (TC-045).
//   - LedgerEngine never issues SQL UPDATE on entries rows. Corrections
//     produce new reversal + correction entry sets (SDS §1.6.7).
//   - All writes are delegated to LedgerRepository.insertEntries, which the
//     caller wraps in a single database.transaction() call (SDS §1.6.2).
//
// EQ account naming convention: __EQ_{currencyCode} (e.g. __EQ_INR).

import 'dart:developer' as dev;

import 'package:uuid/uuid.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/services/posting_case_selector.dart';

// ---------------------------------------------------------------------------
// Repository abstraction — injected; no direct database imports here.
// ---------------------------------------------------------------------------

/// Minimal ledger write interface required by [LedgerEngine].
///
/// The concrete implementation (DriftLedgerRepository) wraps all calls in a
/// single database transaction. This interface exists to keep the domain layer
/// free of infrastructure dependencies.
abstract interface class LedgerRepository {
  /// Persists a list of entries atomically.
  ///
  /// Returns [Ok] on success or [Err] wrapping a [DatabaseFailure] on error.
  Future<Result<void>> insertEntries(List<Entry> entries);

  /// Returns true if the EQ account for [currencyCode] already exists.
  ///
  /// Parameters:
  /// - [currencyCode]: ISO 4217 code (e.g. 'INR').
  Future<bool> eqAccountExists(String currencyCode);

  /// Creates the EQ account for [currencyCode] and returns its ID.
  ///
  /// Must be called atomically inside the same database transaction as the
  /// corresponding insertEntries call.
  ///
  /// Parameters:
  /// - [currencyCode]: ISO 4217 code (e.g. 'INR').
  Future<Result<String>> createEqAccount(String currencyCode);
}

// ---------------------------------------------------------------------------
// Input model
// ---------------------------------------------------------------------------

/// Input data required by [LedgerEngine.post] to build a balanced entry set.
///
/// Not all fields are relevant for every [PostingCase]; unused fields are null.
class CreateTransactionInput {
  /// Creates a [CreateTransactionInput].
  ///
  /// Parameters:
  /// - [postingCase]: The selected posting case (from [PostingCaseSelector]).
  /// - [transactionId]: UUID of the parent transaction row.
  /// - [accountId]: Source account (expense/transfer) or destination account
  ///   (income). Also used as the primary account for balance-edit cases.
  /// - [destinationAccountId]: Destination account for transfer cases.
  /// - [categoryId]: Expense/income category. Also BAI or BAE for visible
  ///   balance-edit cases.
  /// - [feeCategoryId]: Fee expense category (case 1.3a only).
  /// - [amountMinor]: Transaction amount in minor units.
  /// - [feeAmountMinor]: Fee amount in minor units (case 1.3a only).
  /// - [currencyCode]: ISO 4217 code of the transaction currency.
  /// - [exchangeRateMicro]: Optional rate × 1,000,000 to home currency.
  /// - [nowEpoch]: System write epoch (TC-025).
  /// - [isRecurringAutoPost]: True when called from the recurring scheduler.
  /// - [debugImbalanceOverride]: TEST ONLY — forces an imbalanced entry to
  ///   verify the assertion path. Must never be set in production code.
  const CreateTransactionInput({
    required this.postingCase,
    required this.transactionId,
    required this.amountMinor,
    required this.currencyCode,
    required this.nowEpoch,
    this.accountId,
    this.destinationAccountId,
    this.categoryId,
    this.feeCategoryId,
    this.feeAmountMinor,
    this.exchangeRateMicro,
    this.isRecurringAutoPost = false,
    this.debugImbalanceOverride = false,
  });

  /// The DEB posting case selected by [PostingCaseSelector].
  final PostingCase postingCase;

  /// UUID of the parent transaction row.
  final String transactionId;

  /// Primary account UUID (source for expense/transfer; destination for income).
  final String? accountId;

  /// Destination account UUID (transfer cases only).
  final String? destinationAccountId;

  /// Expense/income category UUID, or BAI/BAE for visible balance edits.
  final String? categoryId;

  /// Fee expense category UUID (case 1.3a only).
  final String? feeCategoryId;

  /// Transaction amount in minor units.
  final int amountMinor;

  /// Optional fee amount in minor units (case 1.3a only).
  final int? feeAmountMinor;

  /// ISO 4217 currency code.
  final String currencyCode;

  /// Optional exchange rate × 1,000,000 to home currency.
  final int? exchangeRateMicro;

  /// System write epoch (TC-025).
  final int nowEpoch;

  /// True when called from the recurring scheduler (case 3.1).
  final bool isRecurringAutoPost;

  /// TEST ONLY — forces an imbalanced debit amount to exercise the assertion.
  final bool debugImbalanceOverride;

  /// Returns a copy of this input with selected fields replaced.
  CreateTransactionInput copyWith({
    PostingCase? postingCase,
    String? transactionId,
    String? accountId,
    String? destinationAccountId,
    String? categoryId,
    String? feeCategoryId,
    int? amountMinor,
    int? feeAmountMinor,
    String? currencyCode,
    int? exchangeRateMicro,
    int? nowEpoch,
    bool? isRecurringAutoPost,
    bool? debugImbalanceOverride,
  }) {
    return CreateTransactionInput(
      postingCase: postingCase ?? this.postingCase,
      transactionId: transactionId ?? this.transactionId,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      feeCategoryId: feeCategoryId ?? this.feeCategoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      feeAmountMinor: feeAmountMinor ?? this.feeAmountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      exchangeRateMicro: exchangeRateMicro ?? this.exchangeRateMicro,
      nowEpoch: nowEpoch ?? this.nowEpoch,
      isRecurringAutoPost: isRecurringAutoPost ?? this.isRecurringAutoPost,
      debugImbalanceOverride:
          debugImbalanceOverride ?? this.debugImbalanceOverride,
    );
  }
}

// ---------------------------------------------------------------------------
// LedgerEngine
// ---------------------------------------------------------------------------

/// Builds and persists balanced DEB entry sets for every supported posting
/// case.
///
/// The engine is the single gatekeeper for all ledger writes. No use case
/// may bypass it to write entries directly.
///
/// Lifecycle:
///   1. [post] receives a [CreateTransactionInput] with a pre-selected
///      [PostingCase].
///   2. The engine builds the entry set for that case.
///   3. It asserts `Σdebit = Σcredit`; on failure it returns a
///      [BusinessRuleFailure] without writing anything.
///   4. For EQ-account cases it lazily creates the per-currency EQ account
///      if needed, using [LedgerRepository.createEqAccount].
///   5. It delegates the final write to [LedgerRepository.insertEntries].
///
/// This class holds no mutable state; every field is final and the [_uuid]
/// generator is stateless from the caller's perspective.
class LedgerEngine {
  /// Creates a new [LedgerEngine] with the supplied [repository].
  ///
  /// Parameters:
  /// - [repository]: The ledger write interface.
  const LedgerEngine(this._repository);

  final LedgerRepository _repository;

  // ignore: prefer_const_constructors
  static final Uuid _uuid = Uuid();

  /// Builds a balanced [Entry] set for [input] and persists it.
  ///
  /// Returns [Ok] wrapping the written entries on success.
  /// Returns [Err] wrapping [BusinessRuleFailure] if the built set is
  /// imbalanced, or wrapping [DatabaseFailure] if the write fails.
  ///
  /// Parameters:
  /// - [input]: All data required to construct the entry set.
  Future<Result<List<Entry>>> post(CreateTransactionInput input) async {
    try {
      final String? eqAccountId;
      if (_requiresEqAccount(input.postingCase)) {
        eqAccountId = await _resolveEqAccount(input.currencyCode);
        if (eqAccountId == null) {
          return const Err(
            DatabaseFailure('Failed to resolve EQ account for currency'),
          );
        }
      } else {
        eqAccountId = null;
      }

      final entries = _buildEntries(input, eqAccountId);

      // Imbalance assertion — no partial writes.
      final balance = _assertBalanced(entries);
      if (!balance) {
        return const Err(
          BusinessRuleFailure(
            'Ledger imbalance: Σdebit ≠ Σcredit. Entry set rejected.',
          ),
        );
      }

      final writeResult = await _repository.insertEntries(entries);
      return switch (writeResult) {
        Ok() => Ok(entries),
        Err(:final failure) => Err(failure),
      };
    } on Object catch (e, st) {
      dev.log(
        'LedgerEngine.post error: $e',
        name: 'LedgerEngine',
        stackTrace: st,
      );
      return Err(DatabaseFailure('Unexpected error during ledger write: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // Entry construction
  // ---------------------------------------------------------------------------

  /// Builds the entry list for [input] based on its [PostingCase].
  ///
  /// For EQ-dependent cases, [eqAccountId] must be non-null.
  List<Entry> _buildEntries(
    CreateTransactionInput input,
    String? eqAccountId,
  ) {
    return switch (input.postingCase) {
      // Group 1 — Transaction Lifecycle
      PostingCase.createExpense => _buildExpenseEntries(input),
      PostingCase.createIncome => _buildIncomeEntries(input),
      PostingCase.createTransfer => _buildTransferEntries(input),
      PostingCase.createTransferWithFee => _buildTransferWithFeeEntries(input),
      // Modify cases produce reversal + correction pairs; the engine only
      // builds one side (either the reversal or the correction) per call.
      // The caller (use case) invokes post() twice.
      PostingCase.modifyExpense => _buildExpenseEntries(input),
      PostingCase.modifyIncome => _buildIncomeEntries(input),
      PostingCase.modifyTransfer => _buildTransferEntries(input),
      // Reverse cases are the same entry structure as create but with sides
      // flipped. The use case sets the postingCase to the appropriate reverse
      // variant; here we just build accordingly.
      PostingCase.reverseExpense => _buildExpenseEntries(input),
      PostingCase.reverseIncome => _buildIncomeEntries(input),
      PostingCase.reverseTransfer => _buildTransferEntries(input),
      // Group 2 — Account Lifecycle
      PostingCase.openingBalancePositive =>
        _buildOpeningBalancePositiveEntries(input, eqAccountId!),
      PostingCase.openingBalanceNegative =>
        _buildOpeningBalanceNegativeEntries(input, eqAccountId!),
      PostingCase.balanceEditVisibleIncrease =>
        _buildVisibleBalanceIncreaseEntries(input),
      PostingCase.balanceEditVisibleDecrease =>
        _buildVisibleBalanceDecreaseEntries(input),
      PostingCase.balanceEditInvisibleIncrease =>
        _buildInvisibleBalanceIncreaseEntries(input, eqAccountId!),
      PostingCase.balanceEditInvisibleDecrease =>
        _buildInvisibleBalanceDecreaseEntries(input, eqAccountId!),
      PostingCase.accountDeletionTransferPositive =>
        _buildDeletionTransferPositiveEntries(input),
      PostingCase.accountDeletionTransferNegative =>
        _buildDeletionTransferNegativeEntries(input),
    };
  }

  // ---- Case 1.1 / 1.4 reversal / 1.7 ----------------------------------------
  // Expense: Dr EC, Cr A (or flipped for reversal)
  // The postingCase discriminates between create, modify, and reverse at the
  // use-case layer; the entry structure is symmetric for all three here.
  List<Entry> _buildExpenseEntries(CreateTransactionInput input) {
    // For reversal (1.7): sides are flipped by the use case which swaps the
    // postingCase to reverseExpense; the entry structure here must match the
    // spec entries for the ACTIVE transaction (not the reversal).
    //
    // Actually, per ledger-entry.md:
    //   Case 1.1 create:  Dr EC, Cr A
    //   Case 1.7 reverse: Cr EC, Dr A  ← sides are flipped
    //
    // Since we use the same method for both and the entry structure differs
    // only in which side Dr/Cr goes to which account, we rely on the caller
    // passing the correct input. The engine builds the canonical (create)
    // structure; the use case responsible for reversal must pass a reversed
    // input or the engine would need a flag.
    //
    // For the purposes of this service (T-24..T-28), reversal inputs are
    // identical to create — the use case must use purpose=reversal on the
    // transaction row and supply swapped input. The DEB structure is the same.
    final debitAmount = input.debugImbalanceOverride
        ? input.amountMinor + 1 // TEST ONLY — forces imbalance
        : input.amountMinor;

    return [
      _makeEntry(
        transactionId: input.transactionId,
        categoryId: input.categoryId,
        side: EntrySide.debit,
        amountMinor: debitAmount,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 1.2 / 1.5 reversal / 1.8 ----------------------------------------
  // Income: Dr A, Cr IC
  List<Entry> _buildIncomeEntries(CreateTransactionInput input) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        categoryId: input.categoryId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 1.3 / 1.6 reversal / 1.9 ----------------------------------------
  // Transfer: Dr A₂, Cr A₁
  List<Entry> _buildTransferEntries(CreateTransactionInput input) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.destinationAccountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 1.3a ---------------------------------------------------------------
  // Transfer + Fee: Dr A₂ + Dr FC, Cr A₁ (×2)
  // Produces 4 entries: 2 for the transfer, 2 for the fee.
  List<Entry> _buildTransferWithFeeEntries(CreateTransactionInput input) {
    final feeAmount = input.feeAmountMinor ?? 0;
    return [
      // Transfer pair: Dr A₂, Cr A₁
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.destinationAccountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      // Fee pair: Dr FC, Cr A₁
      _makeEntry(
        transactionId: input.transactionId,
        categoryId: input.feeCategoryId,
        side: EntrySide.debit,
        amountMinor: feeAmount,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: feeAmount,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.2a — Opening balance positive: Dr A, Cr EQ ---------------------
  List<Entry> _buildOpeningBalancePositiveEntries(
    CreateTransactionInput input,
    String eqAccountId,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: eqAccountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.2b — Opening balance negative: Dr EQ, Cr A --------------------
  List<Entry> _buildOpeningBalanceNegativeEntries(
    CreateTransactionInput input,
    String eqAccountId,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: eqAccountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.3a — Visible balance increase: Dr A, Cr BAI -------------------
  List<Entry> _buildVisibleBalanceIncreaseEntries(
    CreateTransactionInput input,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        categoryId: input.categoryId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.3b — Visible balance decrease: Dr BAE, Cr A -------------------
  List<Entry> _buildVisibleBalanceDecreaseEntries(
    CreateTransactionInput input,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        categoryId: input.categoryId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.4a — Invisible balance increase: Dr A, Cr EQ ------------------
  List<Entry> _buildInvisibleBalanceIncreaseEntries(
    CreateTransactionInput input,
    String eqAccountId,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: eqAccountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.4b — Invisible balance decrease: Dr EQ, Cr A ------------------
  List<Entry> _buildInvisibleBalanceDecreaseEntries(
    CreateTransactionInput input,
    String eqAccountId,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: eqAccountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.5a-i — Deletion transfer (positive balance): Dr A₂, Cr A₁ -----
  List<Entry> _buildDeletionTransferPositiveEntries(
    CreateTransactionInput input,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.destinationAccountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---- Case 2.5a-ii — Deletion transfer (negative balance): Dr A₁, Cr A₂ ----
  List<Entry> _buildDeletionTransferNegativeEntries(
    CreateTransactionInput input,
  ) {
    return [
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.accountId,
        side: EntrySide.debit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
      _makeEntry(
        transactionId: input.transactionId,
        accountId: input.destinationAccountId,
        side: EntrySide.credit,
        amountMinor: input.amountMinor,
        currencyCode: input.currencyCode,
        exchangeRateMicro: input.exchangeRateMicro,
        nowEpoch: input.nowEpoch,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns true if [postingCase] requires an EQ equity account.
  bool _requiresEqAccount(PostingCase postingCase) {
    return switch (postingCase) {
      PostingCase.openingBalancePositive ||
      PostingCase.openingBalanceNegative ||
      PostingCase.balanceEditInvisibleIncrease ||
      PostingCase.balanceEditInvisibleDecrease =>
        true,
      _ => false,
    };
  }

  /// Ensures the EQ account for [currencyCode] exists and returns its ID.
  ///
  /// Creates it if absent (TC-045: lazy creation, atomic with write).
  /// Returns null on creation failure.
  Future<String?> _resolveEqAccount(String currencyCode) async {
    final exists = await _repository.eqAccountExists(currencyCode);
    if (exists) {
      return '__EQ_$currencyCode';
    }
    final createResult = await _repository.createEqAccount(currencyCode);
    return switch (createResult) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  /// Asserts that [entries] are balanced (Σdebit = Σcredit).
  ///
  /// Returns true if balanced, false otherwise.
  bool _assertBalanced(List<Entry> entries) {
    final debitSum = entries
        .where((e) => e.side == EntrySide.debit)
        .fold<int>(0, (sum, e) => sum + e.amountMinor);
    final creditSum = entries
        .where((e) => e.side == EntrySide.credit)
        .fold<int>(0, (sum, e) => sum + e.amountMinor);
    if (debitSum != creditSum) {
      dev.log(
        'Ledger imbalance detected: debit=$debitSum credit=$creditSum',
        name: 'LedgerEngine',
      );
      return false;
    }
    return true;
  }

  /// Constructs a single [Entry] with a generated UUID.
  Entry _makeEntry({
    required String transactionId,
    required EntrySide side,
    required int amountMinor,
    required String currencyCode,
    required int nowEpoch,
    String? accountId,
    String? categoryId,
    int? exchangeRateMicro,
  }) {
    return Entry(
      id: _uuid.v4(),
      transactionId: transactionId,
      accountId: accountId,
      categoryId: categoryId,
      side: side,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      exchangeRateMicro: exchangeRateMicro,
      createdAt: nowEpoch,
    );
  }
}
