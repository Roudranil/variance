// lib/domain/usecases/transaction/create_transaction_use_case.dart
//
// Use case: create a new transaction and post it to the ledger.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Creates a new transaction from a validated [Transaction] draft.
///
/// Calls [ITransactionRepository.create]; delegates ledger-entry generation
/// to the LedgerEngine inside the repository implementation.
class CreateTransactionUseCase {
  const CreateTransactionUseCase(this._repository);

  // ignore: unused_field
  final ITransactionRepository _repository;

  /// Executes the use case.
  ///
  /// [draft] must be a fully validated transaction in status = pending.
  /// Returns the persisted [Transaction] on success.
  Future<Result<Transaction>> call(Transaction draft) {
    throw UnimplementedError(
      'CreateTransactionUseCase.call is not implemented',
    );
  }
}
