// lib/domain/usecases/transaction/check_duplicate_use_case.dart
//
// Use case: check whether a draft transaction is a likely duplicate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';

/// Checks whether [draft] is a likely duplicate of a recently posted
/// transaction (same amount, account, type within a short time window).
class CheckDuplicateUseCase {
  const CheckDuplicateUseCase();

  /// Executes the duplicate check.
  ///
  /// Returns [Ok(true)] if a probable duplicate exists.
  Future<Result<bool>> call(Transaction draft) {
    throw UnimplementedError('CheckDuplicateUseCase.call is not implemented');
  }
}
