// test/presentation/features/transactions/exchange_rate_detail_screen_test.dart
//
// Widget tests for ExchangeRateDetailScreen (T-98).
//
// Test cases:
//   1. transaction-level rate — "Rate at time of transaction" shown; no warning
//   2. fresh cached rate — rate value shown; no staleness warning
//   3. stale cached rate — rate value + staleness warning shown
//   4. no rate — "Exchange rate unavailable." shown

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/repositories/i_exchange_rate_repository.dart';
import 'package:variance/domain/usecases/currency/get_exchange_rate_use_case.dart';
import 'package:variance/presentation/features/transactions/exchange_rate_detail_screen.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeExchangeRateRepository implements IExchangeRateRepository {
  _FakeExchangeRateRepository({this.entity});
  final ExchangeRate? entity;

  @override
  Future<ExchangeRate?> getRateEntity(String from, String to) async => entity;

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

final _nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

ExchangeRate _freshRate() => ExchangeRate(
      id: 1,
      fromCurrency: 'USD',
      toCurrency: 'INR',
      rateMicro: 83000000,
      fetchedAt: _nowEpoch,
      rateDate: '2025-01-01',
    );

ExchangeRate _staleRate() => ExchangeRate(
      id: 2,
      fromCurrency: 'USD',
      toCurrency: 'INR',
      rateMicro: 83000000,
      fetchedAt: _nowEpoch - (20 * 86400),
      rateDate: '2024-12-12',
    );

Widget _buildScreen({
  ExchangeRate? cachedRate,
  ExchangeRate? transactionRate,
}) {
  final repo = _FakeExchangeRateRepository(entity: cachedRate);
  final useCase = GetExchangeRateUseCase(repo);

  return ProviderScope(
    overrides: [
      getExchangeRateUseCaseProvider.overrideWith((_) async => useCase),
    ],
    child: MaterialApp(
      home: ExchangeRateDetailScreen(
        fromCurrency: 'USD',
        toCurrency: 'INR',
        transactionRate: transactionRate,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ExchangeRateDetailScreen', () {
    testWidgets(
        '1. transaction-level rate — shows "Rate at time of transaction"',
        (tester) async {
      await tester.pumpWidget(
        _buildScreen(transactionRate: _freshRate()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rate at time of transaction'), findsOneWidget);
      // No staleness warning for transaction-level rate.
      expect(
        find.textContaining('may be inaccurate'),
        findsNothing,
      );
    });

    testWidgets('2. fresh cached rate — rate value shown; no staleness warning',
        (tester) async {
      await tester.pumpWidget(_buildScreen(cachedRate: _freshRate()));
      await tester.pumpAndSettle();

      expect(find.text('Cached (live estimate)'), findsOneWidget);
      expect(find.textContaining('may be inaccurate'), findsNothing);
    });

    testWidgets('3. stale cached rate — shows staleness warning', (tester) async {
      await tester.pumpWidget(_buildScreen(cachedRate: _staleRate()));
      await tester.pumpAndSettle();

      expect(find.textContaining('may be inaccurate'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('4. no rate — shows unavailable message', (tester) async {
      await tester.pumpWidget(_buildScreen(cachedRate: null));
      await tester.pumpAndSettle();

      expect(find.text('Exchange rate unavailable.'), findsOneWidget);
    });
  });
}
