// lib/data/models/transaction_dto.dart
//
// Data Transfer Objects for the Transaction and Entry aggregates.
//
// Maps between Drift-generated row classes and domain entities.
//
// Naming note: Drift generates row class `Transaction` for the transactions
// table, colliding with the domain entity name. Both are disambiguated via
// `show` and `as domain` imports.
//
// Epoch representation: all timestamps are stored as INTEGER Unix epoch
// SECONDS in the database. Domain entities also use epoch seconds (int
// fields), so no conversion is needed.
//
// Test cases (see test/data/models/transaction_dto_test.dart):
//   1. TransactionDto.toEntity round-trips type=income
//   2. TransactionDto.toEntity round-trips type=expense
//   3. TransactionDto.toEntity round-trips type=transfer
//   4. TransactionDto.toEntity defaults status=posted if value matches enum
//   5. EntryDto.toEntity round-trips side=debit
//   6. EntryDto.toEntity round-trips side=credit

import 'package:drift/drift.dart';

import 'package:variance/data/database/app_database.dart'
    show Transaction, Entry, TransactionsCompanion, EntriesCompanion;
import 'package:variance/domain/entities/entry.dart' as domain;
import 'package:variance/domain/entities/transaction.dart' as domain;

// ---------------------------------------------------------------------------
// TransactionDto
// ---------------------------------------------------------------------------

/// Maps a Drift [Transaction] row to the domain [domain.Transaction] entity.
///
/// All enum-string conversions and nullable field mappings are centralised
/// here so the repository remains free of conversion boilerplate.
class TransactionDto {
  /// Creates a [TransactionDto] from a Drift-generated [Transaction] row.
  ///
  /// Parameters:
  /// - [row]: The Drift row from the `transactions` table.
  const TransactionDto.fromRow(this._row);

  final Transaction _row;

  /// Converts this DTO to the domain [domain.Transaction] entity.
  ///
  /// Returns a fully populated immutable instance.
  domain.Transaction toEntity() {
    return domain.Transaction(
      id: _row.id,
      type: _typeFromString(_row.type),
      status: _statusFromString(_row.status),
      purpose: _purposeFromString(_row.purpose),
      dateTime: _row.transactionDate,
      amountMinor: _row.amountMinor,
      currencyCode: _row.currencyCode,
      exchangeRateMicro: _row.exchangeRateMicro,
      homeCurrencyAtCapture: _row.homeCurrencyAtCapture,
      accountSourceId: _row.accountSourceId,
      accountDestinationId: _row.accountDestinationId,
      categoryId: _row.categoryId,
      subcategoryId: _row.subcategoryId,
      payeeId: _row.payeeId,
      title: _row.title,
      description: _row.description,
      compoundGroupId: _row.compoundGroupId,
      compoundRole: _row.compoundRole,
      parentTemplateId: _row.parentTemplateId,
      correctsTransactionId: _row.correctsTransactionId,
      isManuallyHandled: _row.isManuallyHandled,
      createdAt: _row.createdAt,
      updatedAt: _row.updatedAt,
      metadata: _row.metadata,
    );
  }

  // -----------------------------------------------------------------------
  // Static helpers — entity → companion
  // -----------------------------------------------------------------------

  /// Converts a domain [domain.Transaction] to a [TransactionsCompanion].
  ///
  /// Used when inserting a new transaction row.
  ///
  /// Parameters:
  /// - [entity]: The domain entity to persist.
  static TransactionsCompanion toCompanion(domain.Transaction entity) {
    return TransactionsCompanion(
      id: Value(entity.id),
      type: Value(_typeToString(entity.type)),
      status: Value(_statusToString(entity.status)),
      purpose: Value(_purposeToString(entity.purpose)),
      transactionDate: Value(entity.dateTime),
      amountMinor: Value(entity.amountMinor),
      currencyCode: Value(entity.currencyCode),
      exchangeRateMicro: Value(entity.exchangeRateMicro),
      homeCurrencyAtCapture: Value(entity.homeCurrencyAtCapture),
      accountSourceId: Value(entity.accountSourceId),
      accountDestinationId: Value(entity.accountDestinationId),
      categoryId: Value(entity.categoryId),
      subcategoryId: Value(entity.subcategoryId),
      payeeId: Value(entity.payeeId),
      title: Value(entity.title),
      description: Value(entity.description),
      compoundGroupId: Value(entity.compoundGroupId),
      compoundRole: Value(entity.compoundRole),
      parentTemplateId: Value(entity.parentTemplateId),
      correctsTransactionId: Value(entity.correctsTransactionId),
      isManuallyHandled: Value(entity.isManuallyHandled),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      metadata: Value(entity.metadata),
    );
  }

  // -----------------------------------------------------------------------
  // Enum conversion helpers
  // -----------------------------------------------------------------------

  static domain.TransactionType _typeFromString(String value) {
    return switch (value) {
      'income' => domain.TransactionType.income,
      'expense' => domain.TransactionType.expense,
      'transfer' => domain.TransactionType.transfer,
      // Forward-compat guard: unknown → expense.
      _ => domain.TransactionType.expense,
    };
  }

  static String _typeToString(domain.TransactionType type) {
    return switch (type) {
      domain.TransactionType.income => 'income',
      domain.TransactionType.expense => 'expense',
      domain.TransactionType.transfer => 'transfer',
    };
  }

  static domain.TransactionStatus _statusFromString(String value) {
    return switch (value) {
      'pending' => domain.TransactionStatus.pending,
      'posted' => domain.TransactionStatus.posted,
      'voided' => domain.TransactionStatus.voided,
      _ => domain.TransactionStatus.pending,
    };
  }

  static String _statusToString(domain.TransactionStatus status) {
    return switch (status) {
      domain.TransactionStatus.pending => 'pending',
      domain.TransactionStatus.posted => 'posted',
      domain.TransactionStatus.voided => 'voided',
    };
  }

  static domain.TransactionPurpose _purposeFromString(String value) {
    return switch (value) {
      'user' => domain.TransactionPurpose.user,
      'reversal' => domain.TransactionPurpose.reversal,
      'correction' => domain.TransactionPurpose.correction,
      'system' => domain.TransactionPurpose.system,
      _ => domain.TransactionPurpose.user,
    };
  }

  static String _purposeToString(domain.TransactionPurpose purpose) {
    return switch (purpose) {
      domain.TransactionPurpose.user => 'user',
      domain.TransactionPurpose.reversal => 'reversal',
      domain.TransactionPurpose.correction => 'correction',
      domain.TransactionPurpose.system => 'system',
    };
  }
}

// ---------------------------------------------------------------------------
// EntryDto
// ---------------------------------------------------------------------------

/// Maps a Drift [Entry] row to the domain [domain.Entry] entity.
class EntryDto {
  /// Creates an [EntryDto] from a Drift-generated [Entry] row.
  ///
  /// Parameters:
  /// - [row]: The Drift row from the `entries` table.
  const EntryDto.fromRow(this._row);

  final Entry _row;

  /// Converts this DTO to the domain [domain.Entry] entity.
  domain.Entry toEntity() {
    return domain.Entry(
      id: _row.id,
      transactionId: _row.transactionId,
      accountId: _row.accountId,
      categoryId: _row.categoryId,
      side: _sideFromString(_row.side),
      amountMinor: _row.amountMinor,
      currencyCode: _row.currencyCode,
      exchangeRateMicro: _row.exchangeRateMicro,
      createdAt: _row.createdAt,
    );
  }

  // -----------------------------------------------------------------------
  // Static helpers — entry entity → companion
  // -----------------------------------------------------------------------

  /// Converts a domain [domain.Entry] to an [EntriesCompanion].
  ///
  /// Parameters:
  /// - [entity]: The domain entry to persist.
  static EntriesCompanion toCompanion(domain.Entry entity) {
    return EntriesCompanion(
      id: Value(entity.id),
      transactionId: Value(entity.transactionId),
      accountId: Value(entity.accountId),
      categoryId: Value(entity.categoryId),
      side: Value(_sideToString(entity.side)),
      amountMinor: Value(entity.amountMinor),
      currencyCode: Value(entity.currencyCode),
      exchangeRateMicro: Value(entity.exchangeRateMicro),
      createdAt: Value(entity.createdAt),
    );
  }

  static domain.EntrySide _sideFromString(String value) {
    return switch (value) {
      'debit' => domain.EntrySide.debit,
      'credit' => domain.EntrySide.credit,
      _ => domain.EntrySide.debit,
    };
  }

  static String _sideToString(domain.EntrySide side) {
    return switch (side) {
      domain.EntrySide.debit => 'debit',
      domain.EntrySide.credit => 'credit',
    };
  }
}
