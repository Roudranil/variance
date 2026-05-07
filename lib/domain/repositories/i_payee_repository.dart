// lib/domain/repositories/i_payee_repository.dart
//
// Abstract repository interface for the Payee aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/payee.dart';

/// Contract for all Payee data-access operations.
abstract interface class IPayeeRepository {
  /// Watches all non-deleted payees.
  Stream<List<Payee>> watchAll();

  /// Creates a new payee with [name].
  Future<Result<Payee>> create(String name);

  /// Renames the payee with [id].
  Future<Result<Payee>> rename(String id, String name);

  /// Soft-deletes the payee with [id].
  Future<Result<void>> softDelete(String id);
}
