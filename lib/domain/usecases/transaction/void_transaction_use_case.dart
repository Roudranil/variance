// lib/domain/usecases/transaction/void_transaction_use_case.dart
//
// Use case: void a single transaction.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Voids the transaction identified by [id].
///
/// A voided transaction no longer participates in balance calculations.
class VoidTransactionUseCase {
  const VoidTransactionUseCase(this._repository);

  // ignore: unused_field
  final ITransactionRepository _repository;

  /// Executes the use case.
  Future<Result<void>> call(String id) {
    throw UnimplementedError('VoidTransactionUseCase.call is not implemented');
  }
}
