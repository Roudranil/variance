// lib/presentation/providers/transaction_providers.dart
//
// Riverpod stream providers for transaction-related reactive data.
//
// Provider graph:
//   transactionByIdProvider  ← transactionRepositoryProvider
//
// Test cases (see test/providers/transaction_providers_test.dart):
//   1. transactionByIdProvider emits null for unknown id
//   2. transactionByIdProvider emits transaction after create

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'transaction_providers.g.dart';

// ---------------------------------------------------------------------------
// transactionByIdProvider
// ---------------------------------------------------------------------------

/// Watches a single transaction by [transactionId].
///
/// Emits null if the transaction does not exist or has been voided/deleted
/// from the default view.
///
/// Used by [TransactionDetailScreen].
///
/// Parameters:
/// - [transactionId]: UUID of the transaction to watch.
@riverpod
Stream<Transaction?> transactionById(
  Ref ref,
  String transactionId,
) async* {
  final repo = await ref.watch(transactionRepositoryProvider.future);
  yield* repo.watchById(transactionId);
}
