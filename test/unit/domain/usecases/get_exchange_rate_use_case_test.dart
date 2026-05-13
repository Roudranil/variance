// test/unit/domain/usecases/get_exchange_rate_use_case_test.dart
//
// Unit tests for GetExchangeRateUseCase (T-93).
//
// Test cases:
//   1. rate present (fresh)   → Ok(ExchangeRate) with isStale = false
//   2. rate present (stale)   → Ok(ExchangeRate) with isStale = true
//   3. rate absent            → Err(RateUnavailableFailure)

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';
import 'package:variance/domain/usecases/currency/get_exchange_rate_use_case.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeExchangeRateRepository implements IExchangeRateRepository {
  _FakeExchangeRateRepository({this.entity});

  /// Pre-loaded entity; null simulates a cache miss.
  ExchangeRate? entity;

  @override
  Future<ExchangeRate?> getRateEntity(String from, String to) async => entity;

  // Unused stubs — satisfy interface.
  @override
  Future<Result<Decimal>> getRate(String from, String to, String date) =>
      throw UnimplementedError();

  @override
  Result<Decimal> getCachedRate(String from, String to, String date) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> fetchAndCache() => throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Unix epoch seconds representing "now" for test isolation.
final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

/// Builds a fresh exchange rate: fetchedAt = now (not stale).
ExchangeRate _freshRate() => ExchangeRate(
      id: 1,
      fromCurrency: 'USD',
      toCurrency: 'INR',
      rateMicro: 83000000,
      fetchedAt: _now,
      rateDate: '2025-01-01',
    );

/// Builds a stale exchange rate: fetchedAt = 20 days ago (> 14-day threshold).
ExchangeRate _staleRate() => ExchangeRate(
      id: 2,
      fromCurrency: 'USD',
      toCurrency: 'INR',
      rateMicro: 83000000,
      // 20 days ago in epoch seconds
      fetchedAt: _now - (20 * 86400),
      rateDate: '2024-12-12',
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GetExchangeRateUseCase', () {
    test('1. rate present (fresh) → Ok with isStale=false', () async {
      final repo = _FakeExchangeRateRepository(entity: _freshRate());
      final useCase = GetExchangeRateUseCase(repo);

      final result =
          await useCase(const GetExchangeRateInput(from: 'USD', to: 'INR'));

      expect(result, isA<Ok<ExchangeRate>>());
      final rate = (result as Ok<ExchangeRate>).value;
      expect(rate.fromCurrency, 'USD');
      expect(rate.toCurrency, 'INR');
      expect(rate.isStale, isFalse);
    });

    test('2. rate present (stale) → Ok with isStale=true', () async {
      final repo = _FakeExchangeRateRepository(entity: _staleRate());
      final useCase = GetExchangeRateUseCase(repo);

      final result =
          await useCase(const GetExchangeRateInput(from: 'USD', to: 'INR'));

      expect(result, isA<Ok<ExchangeRate>>());
      final rate = (result as Ok<ExchangeRate>).value;
      expect(rate.isStale, isTrue);
    });

    test('3. rate absent → Err(RateUnavailableFailure)', () async {
      final repo = _FakeExchangeRateRepository(entity: null);
      final useCase = GetExchangeRateUseCase(repo);

      final result =
          await useCase(const GetExchangeRateInput(from: 'USD', to: 'INR'));

      expect(result, isA<Err<ExchangeRate>>());
      final failure = (result as Err<ExchangeRate>).failure;
      expect(failure, isA<RateUnavailableFailure>());
    });
  });
}
