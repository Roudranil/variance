// lib/domain/entities/home_state.dart
//
// HomeState domain entity — represents the complete state of the Home screen.
//
// Architecture (T-146, SDS §2.2.2):
//   - Immutable value object consumed by HomeNotifier.
//   - Carries all reactive data needed by the Home screen without individual
//     providers per field (single source of truth for the Home tab).
//   - MonthlySummary is a nested value object for the financial summary block.
//
// Test cases (see test/unit/domain/usecases/home/home_notifier_test.dart):
//   1. initial state has selectedMonth = current calendar month
//   2. hasStaleFx mirrors NetWorthResult.hasStaleRates
//   3. isFutureMonth computed from selectedMonth vs. current date

import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';

/// Complete state snapshot for the Home screen dashboard.
///
/// Consumed by [HomeNotifier] and rendered by the Home screen widgets.
/// All monetary amounts are in minor units of [netWorthCurrencyCode].
class HomeState {
  /// Creates a [HomeState].
  ///
  /// Parameters:
  /// - [selectedMonth]: The calendar month currently selected in the month
  ///   selector. Day component is ignored — only year/month are meaningful.
  /// - [netWorthMinor]: Aggregate net worth in home-currency minor units.
  /// - [netWorthCurrencyCode]: ISO 4217 code of the home currency.
  /// - [hasStaleFx]: True when at least one account has a missing or stale
  ///   exchange rate (> 14 days old).
  /// - [hasNoFxRate]: True when a foreign-currency account exists but no
  ///   exchange rate has ever been fetched.
  /// - [isFutureMonth]: True when [selectedMonth] is after the current
  ///   calendar month.
  /// - [monthlySummary]: Income/expense/net aggregates for [selectedMonth].
  const HomeState({
    required this.selectedMonth,
    required this.netWorthMinor,
    required this.netWorthCurrencyCode,
    required this.hasStaleFx,
    required this.monthlySummary,
    this.hasNoFxRate = false,
    this.isFutureMonth = false,
  });

  /// The calendar month displayed on the Home screen.
  ///
  /// Only [DateTime.year] and [DateTime.month] are meaningful.
  final DateTime selectedMonth;

  /// Aggregate net worth in home-currency minor units.
  ///
  /// Includes all accounts where [Account.includeInNetWorth] = true, excluding
  /// equity (EQ) accounts and soft-deleted accounts.
  final int netWorthMinor;

  /// ISO 4217 code of the home currency used for net worth.
  final String netWorthCurrencyCode;

  /// True when at least one account's exchange rate is missing or stale.
  ///
  /// When true, the UI shows the staleness banner above the net worth card.
  final bool hasStaleFx;

  /// True when a foreign-currency account exists but no exchange rate has
  /// ever been fetched.
  ///
  /// When true, the net worth card shows "—" with a disclaimer footnote
  /// instead of a converted amount.
  final bool hasNoFxRate;

  /// True when [selectedMonth] is in the future relative to the current date.
  ///
  /// When true, the financial summary shows a "Projected" label and the
  /// transaction list shows only pending transactions with muted styling.
  final bool isFutureMonth;

  /// Monthly income/expense/net aggregates for [selectedMonth].
  final MonthlySummary monthlySummary;

  /// Returns a copy of this [HomeState] with the given fields replaced.
  HomeState copyWith({
    DateTime? selectedMonth,
    int? netWorthMinor,
    String? netWorthCurrencyCode,
    bool? hasStaleFx,
    bool? hasNoFxRate,
    bool? isFutureMonth,
    MonthlySummary? monthlySummary,
  }) {
    return HomeState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      netWorthMinor: netWorthMinor ?? this.netWorthMinor,
      netWorthCurrencyCode: netWorthCurrencyCode ?? this.netWorthCurrencyCode,
      hasStaleFx: hasStaleFx ?? this.hasStaleFx,
      hasNoFxRate: hasNoFxRate ?? this.hasNoFxRate,
      isFutureMonth: isFutureMonth ?? this.isFutureMonth,
      monthlySummary: monthlySummary ?? this.monthlySummary,
    );
  }
}
