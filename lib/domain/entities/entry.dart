// lib/domain/entities/entry.dart
//
// Entry domain entity — a single DEB ledger line.
//
// Each Transaction has ≥ 2 entries satisfying Σ debit = Σ credit.
// Exactly one of accountId or categoryId must be non-null per row;
// this exclusivity is enforced at the domain layer (Transaction.validate()).
//
// Balance formula for accounts:
//   balance = Σ(amountMinor WHERE side='debit') − Σ(amountMinor WHERE side='credit')

import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry.freezed.dart';

/// DEB side of a ledger entry.
enum EntrySide {
  debit,
  credit,
}

/// Immutable domain entity for a single DEB ledger line.
@freezed
abstract class Entry with _$Entry {
  const factory Entry({
    /// UUID v4 stable identifier.
    required String id,

    /// Parent transaction UUID.
    required String transactionId,

    /// Account leg — mutually exclusive with [categoryId].
    String? accountId,

    /// Category leg — mutually exclusive with [accountId].
    String? categoryId,

    /// DEB side of this entry.
    required EntrySide side,

    /// Amount in minor units of [currencyCode].
    required int amountMinor,

    /// ISO 4217 currency code of this entry.
    required String currencyCode,

    /// Rate to home currency × 1,000,000; null if same as home currency.
    int? exchangeRateMicro,

    /// System write epoch (TC-025).
    required int createdAt,
  }) = _Entry;
}
