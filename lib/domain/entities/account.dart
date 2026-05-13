// lib/domain/entities/account.dart
//
// Account domain entity.
//
// Represents a user-facing financial account (bank, credit card, cash, etc.)
// or a system equity account (EQ). Balances are never stored; they are
// computed from entries at query time.
//
// Key rules:
//   - currency_code is immutable after creation (TC-044).
//   - EQ accounts have is_system = true and are hidden from all user views.
//   - Soft-delete: is_deleted = true; deleted_at is set.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';

/// Category of a financial account.
enum AccountCategory {
  cash,
  bankAccount,
  creditCard,
  debitCard,
  topUpWallet,
  loan,
  investment,
  other,
  equity,
}

/// Immutable domain entity for a financial account.
@freezed
abstract class Account with _$Account {
  const factory Account({
    /// UUID v4 stable identifier.
    required String id,

    /// User-visible display name.
    required String name,

    /// Account type discriminator.
    required AccountCategory accountCategory,

    /// Opening balance in minor units of [currencyCode].
    ///
    /// Applied once at account creation; never changed.
    @Default(0) int initialBalanceMinor,

    /// ISO 4217 code; immutable after creation.
    required String currencyCode,

    /// Whether to include this account in net worth calculations.
    @Default(true) bool includeInNetWorth,

    /// Optional free-form note.
    String? notes,

    /// Soft-delete flag.
    @Default(false) bool isDeleted,

    /// Unix epoch seconds; set when [isDeleted] becomes true.
    int? deletedAt,

    /// True for EQ and BAI/BAE accounts; blocks user deletion.
    @Default(false) bool isProtected,

    /// True for system-generated accounts (EQ per currency); hidden from views.
    @Default(false) bool isSystem,

    /// User-defined sort position; null = alphabetical.
    int? displayOrder,

    /// Creation epoch (Unix seconds).
    required int createdAt,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,

    /// JSON escape hatch for forward-compatible extensions.
    String? metadata,

    /// Per-account large-transaction warning threshold in the account's native
    /// currency (minor units). Null means no threshold is set.
    ///
    /// When a transaction amount exceeds this value, the app shows a warning
    /// before posting (TC-047, SDS §5.4.4).
    int? largeTxnThresholdMinor,
  }) = _Account;
}
