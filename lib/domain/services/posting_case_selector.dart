// lib/domain/services/posting_case_selector.dart
//
// PostingCaseSelector — maps a ledger event type and entity state to the
// correct DEB posting case defined in ledger-entry.md.
//
// This service is stateless. It holds no instance fields and produces
// deterministic output for any given input.
//
// Posting case reference (ledger-entry.md):
//   Group 1 — Transaction Lifecycle
//     1.1  Create Expense:              Dr EC, Cr A
//     1.2  Create Income:               Dr A, Cr IC
//     1.3  Create Transfer:             Dr A₂, Cr A₁
//     1.3a Create Transfer + Fee:       Dr A₂ + Dr FC, Cr A₁ (×2)
//     1.4  Modify Expense:              reversal + correction
//     1.5  Modify Income:               reversal + correction
//     1.6  Modify Transfer:             reversal + correction
//     1.7  Soft-Delete Expense:         Dr A, Cr EC (reversal)
//     1.8  Soft-Delete Income:          Dr IC, Cr A (reversal)
//     1.9  Soft-Delete Transfer:        Dr A₁, Cr A₂ (reversal)
//   Group 2 — Account Lifecycle
//     2.2a Opening Balance (positive):  Dr A, Cr EQ
//     2.2b Opening Balance (negative):  Dr EQ, Cr A
//     2.3a Visible Adj (increase):      Dr A, Cr BAI
//     2.3b Visible Adj (decrease):      Dr BAE, Cr A
//     2.4a Invisible Adj (increase):    Dr A, Cr EQ
//     2.4b Invisible Adj (decrease):    Dr EQ, Cr A
//     2.5a Deletion Transfer (pos):     Dr A₂, Cr A₁
//     2.5a Deletion Transfer (neg):     Dr A₁, Cr A₂
//   Group 3 — Additional Cases
//     3.1  Recurring Auto-Post:         identical to 1.1 / 1.2 / 1.3

/// Every event type that can trigger a ledger write.
///
/// Recurring auto-post variants are distinct event types so the selector
/// can be extended (e.g. for audit logging) while the resulting [PostingCase]
/// remains the same as the corresponding create case.
enum LedgerEventType {
  // Group 1 — Transaction Lifecycle
  /// User creates a new expense transaction.
  createExpense,

  /// User creates a new income transaction.
  createIncome,

  /// User creates a new transfer transaction.
  createTransfer,

  /// User creates a transfer that includes a fee component.
  createTransferWithFee,

  /// User edits financial fields of an expense transaction (reversal + correction).
  editExpense,

  /// User edits financial fields of an income transaction (reversal + correction).
  editIncome,

  /// User edits financial fields of a transfer transaction (reversal + correction).
  editTransfer,

  /// User soft-deletes an expense transaction (posts reversal only).
  deleteExpense,

  /// User soft-deletes an income transaction (posts reversal only).
  deleteIncome,

  /// User soft-deletes a transfer transaction (posts reversal only).
  deleteTransfer,

  // Group 2 — Account Lifecycle
  /// Account created with initial positive balance (Dr A, Cr EQ).
  openingBalancePositive,

  /// Account created with initial negative balance (Dr EQ, Cr A).
  openingBalanceNegative,

  /// Balance edited visibly, balance increases (Dr A, Cr BAI).
  balanceEditVisibleIncrease,

  /// Balance edited visibly, balance decreases (Dr BAE, Cr A).
  balanceEditVisibleDecrease,

  /// Balance edited invisibly, balance increases (Dr A, Cr EQ).
  balanceEditInvisibleIncrease,

  /// Balance edited invisibly, balance decreases (Dr EQ, Cr A).
  balanceEditInvisibleDecrease,

  /// Account being deleted — system transfers positive balance to another account.
  accountDeletionTransferPositive,

  /// Account being deleted — system transfers negative balance to another account.
  accountDeletionTransferNegative,

  // Group 3 — Recurring auto-post
  /// Recurring template auto-posts an expense occurrence.
  recurringAutoPostExpense,

  /// Recurring template auto-posts an income occurrence.
  recurringAutoPostIncome,

  /// Recurring template auto-posts a transfer occurrence.
  recurringAutoPostTransfer,
}

/// The concrete DEB posting case selected for a ledger event.
///
/// Each value maps to one of the cases from ledger-entry.md. The
/// [LedgerEngine] uses this to build the correct entry set.
enum PostingCase {
  // Group 1 — Transaction Lifecycle
  /// Case 1.1 — Dr EC, Cr A.
  createExpense,

  /// Case 1.2 — Dr A, Cr IC.
  createIncome,

  /// Case 1.3 — Dr A₂, Cr A₁.
  createTransfer,

  /// Case 1.3a — Dr A₂ + Dr FC, Cr A₁ (×2).
  createTransferWithFee,

  /// Cases 1.4 / 1.6 — reversal + correction entry pair (expense).
  modifyExpense,

  /// Cases 1.5 / 1.6 — reversal + correction entry pair (income).
  modifyIncome,

  /// Case 1.6 — reversal + correction entry pair (transfer).
  modifyTransfer,

  /// Case 1.7 — Dr A, Cr EC (reversal of expense).
  reverseExpense,

  /// Case 1.8 — Dr IC, Cr A (reversal of income).
  reverseIncome,

  /// Case 1.9 — Dr A₁, Cr A₂ (reversal of transfer).
  reverseTransfer,

  // Group 2 — Account Lifecycle
  /// Case 2.2a — Dr A, Cr EQ (positive initial balance).
  openingBalancePositive,

  /// Case 2.2b — Dr EQ, Cr A (negative initial balance).
  openingBalanceNegative,

  /// Case 2.3a — Dr A, Cr BAI (visible balance increase).
  balanceEditVisibleIncrease,

  /// Case 2.3b — Dr BAE, Cr A (visible balance decrease).
  balanceEditVisibleDecrease,

  /// Case 2.4a — Dr A, Cr EQ (invisible balance increase).
  balanceEditInvisibleIncrease,

  /// Case 2.4b — Dr EQ, Cr A (invisible balance decrease).
  balanceEditInvisibleDecrease,

  /// Case 2.5a-i — Dr A₂, Cr A₁ (deletion transfer, positive source balance).
  accountDeletionTransferPositive,

  /// Case 2.5a-ii — Dr A₁, Cr A₂ (deletion transfer, negative source balance).
  accountDeletionTransferNegative,
}

/// Optional entity-state context that may influence case selection in the
/// future (e.g. account type, liability vs asset state).
///
/// Currently unused — all selection is event-driven — but it is part of the
/// API to keep the interface stable for callers that may add state later.
class EntityState {
  /// Creates a default entity state context with no additional data.
  const EntityState();
}

/// Stateless service that maps a [LedgerEventType] + [EntityState] to the
/// correct [PostingCase].
///
/// Every ledger write must pass through this selector before constructing
/// entries. No I/O occurs and no instance state is mutated between calls.
class PostingCaseSelector {
  /// Creates a new [PostingCaseSelector].
  const PostingCaseSelector();

  /// Returns the [PostingCase] for the given [eventType] and [entityState].
  ///
  /// The [entityState] parameter is reserved for future extensions where
  /// account type or balance direction would influence case selection; it is
  /// not currently used.
  ///
  /// Parameters:
  /// - [eventType]: The event that triggered the ledger operation.
  /// - [entityState]: Optional contextual state of the involved entity.
  PostingCase select({
    required LedgerEventType eventType,
    required EntityState entityState,
  }) {
    return switch (eventType) {
      LedgerEventType.createExpense => PostingCase.createExpense,
      LedgerEventType.createIncome => PostingCase.createIncome,
      LedgerEventType.createTransfer => PostingCase.createTransfer,
      LedgerEventType.createTransferWithFee =>
        PostingCase.createTransferWithFee,
      LedgerEventType.editExpense => PostingCase.modifyExpense,
      LedgerEventType.editIncome => PostingCase.modifyIncome,
      LedgerEventType.editTransfer => PostingCase.modifyTransfer,
      LedgerEventType.deleteExpense => PostingCase.reverseExpense,
      LedgerEventType.deleteIncome => PostingCase.reverseIncome,
      LedgerEventType.deleteTransfer => PostingCase.reverseTransfer,
      LedgerEventType.openingBalancePositive =>
        PostingCase.openingBalancePositive,
      LedgerEventType.openingBalanceNegative =>
        PostingCase.openingBalanceNegative,
      LedgerEventType.balanceEditVisibleIncrease =>
        PostingCase.balanceEditVisibleIncrease,
      LedgerEventType.balanceEditVisibleDecrease =>
        PostingCase.balanceEditVisibleDecrease,
      LedgerEventType.balanceEditInvisibleIncrease =>
        PostingCase.balanceEditInvisibleIncrease,
      LedgerEventType.balanceEditInvisibleDecrease =>
        PostingCase.balanceEditInvisibleDecrease,
      LedgerEventType.accountDeletionTransferPositive =>
        PostingCase.accountDeletionTransferPositive,
      LedgerEventType.accountDeletionTransferNegative =>
        PostingCase.accountDeletionTransferNegative,
      // Case 3.1 — recurring auto-post uses the same entries as the equivalent
      // create case (the recurring mechanism is a scheduling layer only).
      LedgerEventType.recurringAutoPostExpense => PostingCase.createExpense,
      LedgerEventType.recurringAutoPostIncome => PostingCase.createIncome,
      LedgerEventType.recurringAutoPostTransfer => PostingCase.createTransfer,
    };
  }
}
