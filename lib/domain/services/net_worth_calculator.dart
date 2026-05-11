// lib/domain/services/net_worth_calculator.dart
//
// NetWorthCalculator — pure stateless domain service.
//
// Aggregates account balances (in minor units) into a single home-currency
// net worth total, applying exchange rate conversion for foreign-currency
// accounts.
//
// Rules (PRD §5.1.4, feature-dag ACC-03):
//   - Includes only accounts where includeInNetWorth = true AND isDeleted = false.
//   - Converts foreign balances using the supplied exchange rate map.
//   - When a rate is missing for a currency, that account is excluded and
//     hasStaleRates is set to true in the result.
//   - When a rate's fetchedAt is older than kStalenessThresholdDays, the rate is
//     still used but hasStaleRates is set to true (data model §4.2, 14-day threshold).

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/entities/money.dart';

/// Threshold in seconds beyond which an exchange rate is considered stale.
///
/// Per data model §4.2, a rate older than 14 days shows a staleness indicator.
const int kRateStalenessSeconds = 14 * 24 * 60 * 60; // 14 days

/// Result of a net worth computation.
///
/// Carries the total in home-currency minor units plus a staleness flag that
/// the UI uses to render the "Rate may be outdated" indicator.
class NetWorthResult {
  /// Creates a [NetWorthResult].
  ///
  /// Parameters:
  /// - [totalMinor]: Aggregate net worth in home-currency minor units.
  /// - [homeCurrency]: ISO 4217 code of the home currency.
  /// - [hasStaleRates]: True when any included account's rate was stale or
  ///   missing.
  const NetWorthResult({
    required this.totalMinor,
    required this.homeCurrency,
    required this.hasStaleRates,
  });

  /// Aggregate net worth in home-currency minor units.
  final int totalMinor;

  /// ISO 4217 code of the home currency.
  final String homeCurrency;

  /// True when at least one account had a missing or stale exchange rate.
  ///
  /// The UI shows "Exchange rate may be outdated" when this is true.
  final bool hasStaleRates;

  /// Converts this result to a [Money] value object.
  Money toMoney() => Money(amountMinor: totalMinor, currencyCode: homeCurrency);
}

/// Stateless service that aggregates account balances into a net worth total.
///
/// All inputs are plain data — no I/O is performed. The caller is responsible
/// for fetching and providing the necessary balances and exchange rates.
class NetWorthCalculator {
  /// Creates a new [NetWorthCalculator].
  const NetWorthCalculator();

  /// Micro-divisor for exchange rate conversion (rateMicro = rate × 1,000,000).
  static const int _microDivisor = 1000000;

  /// Computes the net worth from [accounts], [balancesByAccountId], and
  /// [ratesByFromCurrency].
  ///
  /// Only accounts with [Account.includeInNetWorth] = true and
  /// [Account.isDeleted] = false are included in the total.
  ///
  /// For foreign-currency accounts the balance is converted using the matching
  /// [ExchangeRate.rateMicro] from [ratesByFromCurrency]. When no rate exists
  /// the account is skipped and [NetWorthResult.hasStaleRates] is set.
  ///
  /// Returns a [NetWorthResult] with the aggregate total.
  ///
  /// Parameters:
  /// - [accounts]: All candidate accounts (filtering applied inside).
  /// - [balancesByAccountId]: Map of account ID → balance in minor units.
  /// - [ratesByFromCurrency]: Map of ISO currency code → [ExchangeRate] for
  ///   the home currency.
  /// - [homeCurrency]: ISO 4217 code of the home currency (used for same-
  ///   currency accounts and to build the result).
  /// - [nowEpoch]: Current Unix epoch seconds; used to evaluate staleness.
  NetWorthResult compute({
    required List<Account> accounts,
    required Map<String, int> balancesByAccountId,
    required Map<String, ExchangeRate> ratesByFromCurrency,
    required String homeCurrency,
    required int nowEpoch,
  }) {
    var totalMinor = 0;
    var hasStaleRates = false;

    for (final account in accounts) {
      // Skip excluded and soft-deleted accounts.
      if (!account.includeInNetWorth || account.isDeleted) continue;

      final balanceMinor = balancesByAccountId[account.id] ?? 0;

      if (account.currencyCode == homeCurrency) {
        // Same-currency account — no conversion needed.
        totalMinor += balanceMinor;
      } else {
        // Foreign-currency account — look up exchange rate.
        final rate = ratesByFromCurrency[account.currencyCode];
        if (rate == null) {
          // No rate available: exclude from sum and flag staleness.
          hasStaleRates = true;
          continue;
        }

        // Check if rate is stale (older than 14 days).
        if (nowEpoch - rate.fetchedAt > kRateStalenessSeconds) {
          hasStaleRates = true;
          // Include the value anyway (best-effort conversion); still flag UI.
        }

        // Integer arithmetic: balance × rateMicro ÷ 1_000_000
        totalMinor += (balanceMinor * rate.rateMicro) ~/ _microDivisor;
      }
    }

    return NetWorthResult(
      totalMinor: totalMinor,
      homeCurrency: homeCurrency,
      hasStaleRates: hasStaleRates,
    );
  }
}
