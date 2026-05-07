// lib/domain/usecases/transaction/check_overdraft_use_case.dart
//
// Use case: check whether a draft transaction would cause an overdraft.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';

/// Checks whether posting [draft] would cause the source account balance to
/// go negative (future business rule — v1 may return false by default).
class CheckOverdraftUseCase {
  const CheckOverdraftUseCase();

  /// Executes the overdraft check.
  ///
  /// Returns [Ok(true)] if posting [draft] would result in a negative balance.
  Future<Result<bool>> call(Transaction draft) {
    throw UnimplementedError('CheckOverdraftUseCase.call is not implemented');
  }
}
