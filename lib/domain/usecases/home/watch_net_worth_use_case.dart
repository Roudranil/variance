// lib/domain/usecases/home/watch_net_worth_use_case.dart
//
// Use case: watch the total net worth converted to the home currency.

import 'package:variance/domain/entities/money.dart';

/// Watches the total net worth across all include_in_net_worth accounts,
/// converted to the home currency at the latest exchange rates.
class WatchNetWorthUseCase {
  const WatchNetWorthUseCase();

  /// Executes the use case.
  Stream<Money> call() {
    throw UnimplementedError('WatchNetWorthUseCase.call is not implemented');
  }
}
