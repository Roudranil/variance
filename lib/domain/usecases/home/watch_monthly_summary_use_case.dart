// lib/domain/usecases/home/watch_monthly_summary_use_case.dart
//
// Use case: watch the monthly income/expense/net summary for the home screen.

import 'package:variance/domain/entities/money.dart';

/// Monthly summary aggregates for the home screen.
class MonthlySummary {
  const MonthlySummary({
    required this.income,
    required this.expenses,
    required this.net,
  });

  /// Total income for the month (per currency).
  final List<Money> income;

  /// Total expenses for the month (per currency).
  final List<Money> expenses;

  /// Net balance (income − expenses) per currency.
  final List<Money> net;
}

/// Watches the aggregated monthly income, expense, and net values.
///
/// No direct repository dependency — aggregates from accounts + transactions.
class WatchMonthlySummaryUseCase {
  const WatchMonthlySummaryUseCase();

  /// Executes the use case.
  ///
  /// [year] and [month] use calendar values.
  Stream<MonthlySummary> call(int year, int month) {
    throw UnimplementedError(
      'WatchMonthlySummaryUseCase.call is not implemented',
    );
  }
}
