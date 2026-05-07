// lib/domain/usecases/transaction/edit_transaction_use_case.dart
//
// Use case: edit an existing posted transaction.
//
// Routes to correctFinancial (reversal + correction pair) if any financial
// field changed, or to updateNonFinancial for title/description/date/payee.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';

/// Edits an existing transaction identified by [id] using [updated].
class EditTransactionUseCase {
  const EditTransactionUseCase(this._repository);

  // ignore: unused_field
  final ITransactionRepository _repository;

  /// Executes the use case.
  ///
  /// Determines whether the edit requires a correction chain or an in-place
  /// update by comparing [updated] to the existing record.
  Future<Result<Transaction>> call(String id, Transaction updated) {
    throw UnimplementedError('EditTransactionUseCase.call is not implemented');
  }
}
