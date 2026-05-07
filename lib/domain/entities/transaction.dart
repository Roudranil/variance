// lib/domain/entities/transaction.dart
//
// Transaction domain entity.
//
// Represents an atomic financial event. Each transaction has two or more
// corresponding Entry objects (DEB lines). Financial fields are immutable
// after the transaction reaches status = posted; corrections produce a
// reversal + correction pair (TC-001).
//
// Immutable financial fields: amountMinor, currencyCode, accountSourceId,
// accountDestinationId, categoryId, subcategoryId.
//
// In-place editable fields: title, description, dateTime, payeeId.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

/// Ledger participation state of a transaction.
enum TransactionStatus {
  pending,
  posted,
  voided,
}

/// Role in the correction/reversal chain.
enum TransactionPurpose {
  user,
  reversal,
  correction,
  system,
}

/// The financial direction of a transaction.
enum TransactionType {
  income,
  expense,
  transfer,
}

/// Immutable domain entity for an atomic financial event.
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    /// UUID v4 stable identifier.
    required String id,

    /// Financial direction of the event.
    required TransactionType type,

    /// Ledger participation state (TC-001).
    required TransactionStatus status,

    /// Role within the correction/reversal chain (TC-001).
    @Default(TransactionPurpose.user) TransactionPurpose purpose,

    /// Business date as Unix epoch seconds.
    required int dateTime,

    /// Amount in minor units of [currencyCode].
    required int amountMinor,

    /// ISO 4217 code; derived from source account; immutable after posting.
    required String currencyCode,

    /// Exchange rate × 1,000,000 from [currencyCode] to
    /// [homeCurrencyAtCapture]; null if currencies are equal (TC-029).
    int? exchangeRateMicro,

    /// Home currency at the time the rate was captured (TC-029).
    String? homeCurrencyAtCapture,

    /// Source account for expense/transfer; null for income.
    String? accountSourceId,

    /// Destination account for income/transfer; null for expense.
    String? accountDestinationId,

    /// Top-level category; null for transfer.
    String? categoryId,

    /// Optional subcategory; null for transfer.
    String? subcategoryId,

    /// Optional payee/merchant reference.
    String? payeeId,

    /// User-provided label; in-place editable.
    String? title,

    /// Long-form description; in-place editable.
    String? description,

    /// UUID shared by compound group members (e.g. transfer + fee); null for
    /// non-compound transactions.
    String? compoundGroupId,

    /// Role within a compound group; null for non-compound.
    String? compoundRole,

    /// Link to the recurring template that generated this transaction.
    String? parentTemplateId,

    /// For purpose = correction or reversal: the ID of the transaction being
    /// corrected/reversed.
    String? correctsTransactionId,

    /// True when a recurring child was edited/deleted outside normal scheduling.
    @Default(false) bool isManuallyHandled,

    /// System creation epoch.
    required int createdAt,

    /// Last-modified epoch.
    required int updatedAt,

    /// JSON escape hatch.
    String? metadata,
  }) = _Transaction;
}
