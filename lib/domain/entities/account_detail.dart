// lib/domain/entities/account_detail.dart
//
// AccountDetail domain entity.
//
// Represents a single category-specific key-value field belonging to an
// account. Sensitive fields (card_number, account_number) are stored
// in encrypted form; the plain-text value is null for those fields.
//
// Valid detail_key values are defined in the data model §3.2.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_detail.freezed.dart';

/// Immutable domain entity representing a single account detail field.
///
/// Each [AccountDetail] belongs to exactly one account (via [accountId])
/// and stores one named field ([detailKey]) with either a plain-text
/// [detailValue] or an encrypted [detailValueEncrypted] blob.
@freezed
abstract class AccountDetail with _$AccountDetail {
  /// Creates an [AccountDetail].
  const factory AccountDetail({
    /// UUID v4 stable identifier for this detail row.
    required String id,

    /// UUID of the parent [Account].
    required String accountId,

    /// Field name (e.g. `bank_name`, `card_number`).
    ///
    /// Valid values are defined in data model §3.2.
    required String detailKey,

    /// Plain-text value for non-sensitive fields.
    ///
    /// Null when [detailValueEncrypted] is populated (sensitive fields).
    String? detailValue,

    /// AES-encrypted blob for sensitive fields (card_number, account_number).
    ///
    /// Null for non-sensitive fields. Only one of [detailValue] or
    /// [detailValueEncrypted] should be non-null at a time.
    String? detailValueEncrypted,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,
  }) = _AccountDetail;
}

/// Recognised [AccountDetail.detailKey] values and whether they are encrypted.
///
/// This enum is used to validate incoming keys and determine storage strategy.
enum AccountDetailKey {
  /// Bank account name (bank_account). Not encrypted.
  bankName('bank_name', encrypted: false),

  /// Bank account number (bank_account). Encrypted.
  accountNumber('account_number', encrypted: true),

  /// Branch name (bank_account). Not encrypted.
  branch('branch', encrypted: false),

  /// IFSC code (bank_account). Not encrypted.
  ifsc('ifsc', encrypted: false),

  /// Card display name (credit_card, debit_card). Not encrypted.
  cardName('card_name', encrypted: false),

  /// Card number (credit_card, debit_card). Encrypted.
  cardNumber('card_number', encrypted: true),

  /// Card expiry date string (credit_card, debit_card). Not encrypted.
  expiryDate('expiry_date', encrypted: false),

  /// Statement billing date (credit_card). Not encrypted.
  billingDate('billing_date', encrypted: false),

  /// Payment due date (credit_card). Not encrypted.
  paymentDueDate('payment_due_date', encrypted: false),

  /// Credit limit in minor units (credit_card). Not encrypted.
  creditLimitMinor('credit_limit_minor', encrypted: false),

  /// Linked bank account UUID (credit_card, debit_card). Not encrypted.
  linkedBankAccountId('linked_bank_account_id', encrypted: false),

  /// Wallet provider name (top_up_wallet). Not encrypted.
  walletProviderName('wallet_provider_name', encrypted: false),

  /// Linked phone number (top_up_wallet). Not encrypted.
  linkedPhoneNumber('linked_phone_number', encrypted: false),

  /// Lender or borrower name (loan). Not encrypted.
  lenderBorrowerName('lender_borrower_name', encrypted: false),

  /// Loan principal in minor units (loan). Not encrypted.
  principalAmountMinor('principal_amount_minor', encrypted: false),

  /// Annual interest rate × 1,000,000 (loan). Not encrypted.
  interestRateMicro('interest_rate_micro', encrypted: false),

  /// EMI amount in minor units (loan). Not encrypted.
  emiAmountMinor('emi_amount_minor', encrypted: false),

  /// Day-of-month for EMI (loan). Not encrypted.
  emiDate('emi_date', encrypted: false),

  /// Loan due date epoch (loan). Not encrypted.
  dueDate('due_date', encrypted: false),

  /// Investment category description (investment). Not encrypted.
  investmentType('investment_type', encrypted: false),

  /// Financial institution name (investment). Not encrypted.
  institutionName('institution_name', encrypted: false),

  /// Current investment value in minor units (investment). Not encrypted.
  currentValueMinor('current_value_minor', encrypted: false);

  /// Creates an [AccountDetailKey] with its string [value] and [encrypted] flag.
  const AccountDetailKey(this.value, {required this.encrypted});

  /// The string representation stored in the database.
  final String value;

  /// Whether the value for this key is AES-encrypted.
  final bool encrypted;

  /// Returns the [AccountDetailKey] for a given string [value], or null if
  /// the value is not a recognised key.
  ///
  /// Parameters:
  /// - [value]: The raw string key from storage.
  static AccountDetailKey? fromString(String value) {
    for (final key in AccountDetailKey.values) {
      if (key.value == value) return key;
    }
    return null;
  }
}
