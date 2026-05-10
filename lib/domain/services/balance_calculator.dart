// lib/domain/services/balance_calculator.dart
//
// BalanceCalculator — pure stateless service that computes account balances
// from a list of ledger entries using the universal DEB formula.
//
// Formula (PRD §4.6, SDS §1.3.2.1):
//   balance = Σ(amountMinor × rate WHERE side = debit)
//           − Σ(amountMinor × rate WHERE side = credit)
//
// Multi-currency conversion (TC-046):
//   Each entry is converted to the home currency via exchangeRateMicro.
//   exchangeRateMicro = rate × 1,000,000.
//   If exchangeRateMicro is null, the entry is assumed to be in the home
//   currency and no conversion is applied (rate = 1).
//
// This service stores no result. It is safe to call concurrently.

import 'package:variance/domain/entities/entry.dart';

/// Stateless service that computes the home-currency balance for a set of
/// ledger entries.
///
/// All entries must belong to the same account. The service does not validate
/// this invariant — callers are responsible for filtering by account before
/// calling [compute].
class BalanceCalculator {
  /// Creates a new [BalanceCalculator].
  const BalanceCalculator();

  /// The micro-unit divisor used to convert rateMicro back to a decimal rate.
  ///
  /// exchangeRateMicro = rate × 1,000,000, so dividing by this constant gives
  /// the original rate (e.g. 83,000,000 → 83.0).
  static const int _microDivisor = 1000000;

  /// Computes the net balance from [entries] converted to [homeCurrency].
  ///
  /// Returns `Σdebit_home − Σcredit_home` where each amount is converted to
  /// the home currency using [Entry.exchangeRateMicro]. A null
  /// [Entry.exchangeRateMicro] is treated as a rate of 1 (same currency as
  /// home).
  ///
  /// The result is in the minor unit of the home currency. A positive value
  /// means the account has a net asset position; a negative value means net
  /// liability.
  ///
  /// This method is pure — it does not persist the result and produces no
  /// side effects.
  ///
  /// Parameters:
  /// - [entries]: The ledger entries to aggregate. May be empty (returns 0).
  /// - [homeCurrency]: The ISO 4217 code of the home currency (used for
  ///   documentation; conversion relies on [Entry.exchangeRateMicro]).
  // ignore: avoid_unused_parameters
  int compute({
    required List<Entry> entries,
    required String homeCurrency,
  }) {
    if (entries.isEmpty) return 0;

    var debitSum = 0;
    var creditSum = 0;

    for (final entry in entries) {
      final homeAmount = _toHomeMinor(entry);
      if (entry.side == EntrySide.debit) {
        debitSum += homeAmount;
      } else {
        creditSum += homeAmount;
      }
    }

    return debitSum - creditSum;
  }

  /// Converts a single entry's [Entry.amountMinor] to the home-currency minor
  /// unit equivalent using [Entry.exchangeRateMicro].
  ///
  /// If [Entry.exchangeRateMicro] is null the amount is returned unchanged
  /// (same-currency entry — rate = 1).
  int _toHomeMinor(Entry entry) {
    final rateMicro = entry.exchangeRateMicro;
    if (rateMicro == null) return entry.amountMinor;
    // Integer arithmetic: amount × rateMicro ÷ 1_000_000
    // Using integer division truncates toward zero, which is acceptable for
    // minor-unit calculations where sub-minor fractions are discarded.
    return (entry.amountMinor * rateMicro) ~/ _microDivisor;
  }
}
