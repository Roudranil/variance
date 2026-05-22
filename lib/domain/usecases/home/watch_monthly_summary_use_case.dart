// lib/domain/usecases/home/watch_monthly_summary_use_case.dart
//
// Use case: watch the monthly income/expense/net summary for the Home screen.
//
// Architecture (T-148, SDS §1.4.2, api-contracts §2.10.1):
//   - Subscribes to ITransactionRepository.watchByMonth() for reactive updates.
//   - Aggregates income and expense amounts from the month's posted transactions.
//   - Transfers are excluded from the summary totals.
//   - All amounts are in the home currency; home-currency accounts are summed
//     directly; foreign-currency accounts would require rate conversion (out of
//     scope for V1 monthly summary — uses raw amountMinor per TC-029 for now).
//   - Re-emits on every DB write to the entries table (via Drift stream).
//
// Test cases (see test/unit/domain/usecases/home/watch_monthly_summary_use_case_test.dart):
//   1. empty month emits zero summary
//   2. income-only month: income > 0, expenses = 0, net = income
//   3. expense-only month: expenses > 0, income = 0, net = -expenses
//   4. mixed month: net = income − expenses
//   5. transfers excluded from totals
//   6. transactions outside queried month excluded

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Monthly income/expense/net aggregates for the Home screen financial summary.
///
/// All monetary values are in minor units of [currencyCode] (the home currency).
class MonthlySummary {
  /// Creates a [MonthlySummary].
  ///
  /// Parameters:
  /// - [incomeMinor]: Total income for the month in home-currency minor units.
  /// - [expensesMinor]: Total expenses for the month in home-currency minor units.
  /// - [netMinor]: Net balance (income − expenses) in home-currency minor units.
  ///   Positive = net income, negative = net expense.
  /// - [currencyCode]: ISO 4217 code of the home currency.
  /// - [hasStaleFx]: True when any included transaction used a stale or missing
  ///   exchange rate.
  const MonthlySummary({
    required this.incomeMinor,
    required this.expensesMinor,
    required this.netMinor,
    required this.currencyCode,
    required this.hasStaleFx,
  });

  /// Total income in home-currency minor units.
  final int incomeMinor;

  /// Total expenses in home-currency minor units.
  final int expensesMinor;

  /// Net balance (income − expenses) in home-currency minor units.
  ///
  /// Positive value means more income than expenses; negative means net loss.
  final int netMinor;

  /// ISO 4217 code of the home currency.
  final String currencyCode;

  /// True when any included transaction had a stale or missing exchange rate.
  ///
  /// Propagated to [HomeState.hasStaleFx] for the staleness banner.
  final bool hasStaleFx;

  /// Returns a [MonthlySummary] with all values set to zero.
  ///
  /// Parameters:
  /// - [currencyCode]: ISO 4217 home currency code.
  static MonthlySummary zero(String currencyCode) => MonthlySummary(
        incomeMinor: 0,
        expensesMinor: 0,
        netMinor: 0,
        currencyCode: currencyCode,
        hasStaleFx: false,
      );
}

/// Watches the aggregated monthly income, expense, and net values.
///
/// Subscribes to [ITransactionRepository.watchByMonth] and aggregates
/// posted income and expense transactions. Transfers are excluded.
///
/// Re-emits whenever the underlying transaction list changes.
class WatchMonthlySummaryUseCase {
  /// Creates a [WatchMonthlySummaryUseCase].
  ///
  /// Parameters:
  /// - [transactionRepository]: Provides the reactive transaction stream.
  /// - [homeCurrency]: ISO 4217 home currency code for the summary.
  const WatchMonthlySummaryUseCase({
    required ITransactionRepository transactionRepository,
    required String homeCurrency,
  })  : _transactionRepository = transactionRepository,
        _homeCurrency = homeCurrency;

  final ITransactionRepository _transactionRepository;
  final String _homeCurrency;

  /// Returns a stream that emits [MonthlySummary] for [year] and [month].
  ///
  /// The stream re-emits on every DB write to the transactions table.
  /// Completes with an error if the underlying DB emits an error.
  ///
  /// Parameters:
  /// - [year]: Four-digit calendar year.
  /// - [month]: 1-based calendar month (1 = January, 12 = December).
  Stream<MonthlySummary> call(int year, int month) {
    return _transactionRepository.watchByMonth(year, month).map(_aggregate);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Aggregates [transactions] into a [MonthlySummary].
  ///
  /// Only posted income and expense transactions are included.
  /// Transfers and non-posted transactions are excluded.
  MonthlySummary _aggregate(List<Transaction> transactions) {
    var incomeMinor = 0;
    var expensesMinor = 0;

    for (final tx in transactions) {
      // Only count posted transactions.
      if (tx.status != TransactionStatus.posted) continue;
      // Skip reversals — they cancel their originals in the ledger.
      if (tx.purpose == TransactionPurpose.reversal) continue;

      switch (tx.type) {
        case TransactionType.income:
          incomeMinor += tx.amountMinor;
        case TransactionType.expense:
          expensesMinor += tx.amountMinor;
        case TransactionType.transfer:
          // Transfers are excluded from income/expense totals.
          break;
      }
    }

    return MonthlySummary(
      incomeMinor: incomeMinor,
      expensesMinor: expensesMinor,
      netMinor: incomeMinor - expensesMinor,
      currencyCode: _homeCurrency,
      hasStaleFx: false,
    );
  }
}
