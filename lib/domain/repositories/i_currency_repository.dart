// lib/domain/repositories/i_currency_repository.dart
//
// Abstract repository interface for the Currency aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/currency.dart';

/// Contract for all Currency data-access operations.
abstract interface class ICurrencyRepository {
  /// Watches the full ISO 4217 currency list (~180 currencies).
  Stream<List<Currency>> watchAll();

  /// Watches only currencies that the user has enabled.
  Stream<List<Currency>> watchEnabled();

  /// Sets the home (base) currency for the app.
  Future<Result<void>> setHomeCurrency(String code);

  /// Marks [code] as enabled for use in transactions.
  Future<Result<void>> enableCurrency(String code);

  /// Marks [code] as disabled.
  Future<Result<void>> disableCurrency(String code);
}
