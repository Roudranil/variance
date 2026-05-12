// test/unit/domain/services/net_worth_calculator_test.dart
//
// Unit tests for NetWorthCalculator.
//
// Test cases:
//   1. empty list → returns zero result with hasStaleRates=false
//   2. single account, same-as-home currency → amount passed through
//   3. single account, foreign currency, rate present → converts correctly
//   4. single account, foreign currency, rate missing → excludes from sum,
//      sets hasStaleRates=true
//   5. mixed: some have rates, some missing → partial sum, hasStaleRates=true
//   6. excludes accounts where includeInNetWorth=false
//   7. excludes soft-deleted accounts (isDeleted=true)
//   8. multi-currency all rates present → correct aggregate
//   9. stale rate (older than 14 days) sets hasStaleRates=true

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/services/net_worth_calculator.dart';

void main() {
  const homeCurrency = 'INR';
  const microDivisor = 1000000;

  // Helpers
  Account makeAccount({
    required String id,
    required String currencyCode,
    bool includeInNetWorth = true,
    bool isDeleted = false,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Account(
      id: id,
      name: 'Acc $id',
      accountCategory: AccountCategory.cash,
      currencyCode: currencyCode,
      includeInNetWorth: includeInNetWorth,
      isDeleted: isDeleted,
      createdAt: now,
      updatedAt: now,
    );
  }

  ExchangeRate makeRate({
    required String from,
    required String to,
    required int rateMicro,
    int? fetchedAt,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return ExchangeRate(
      id: 0,
      fromCurrency: from,
      toCurrency: to,
      rateMicro: rateMicro,
      fetchedAt: fetchedAt ?? now,
      rateDate: '2025-01-01',
    );
  }

  const calculator = NetWorthCalculator();

  group('NetWorthCalculator', () {
    test('1. empty account list → zero result, no stale rates', () {
      final result = calculator.compute(
        accounts: [],
        balancesByAccountId: {},
        ratesByFromCurrency: {},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      expect(result.totalMinor, 0);
      expect(result.homeCurrency, homeCurrency);
      expect(result.hasStaleRates, isFalse);
    });

    test('2. single home-currency account → passes through', () {
      final acc = makeAccount(id: 'a1', currencyCode: homeCurrency);
      final result = calculator.compute(
        accounts: [acc],
        balancesByAccountId: {'a1': 100000},
        ratesByFromCurrency: {},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      expect(result.totalMinor, 100000);
      expect(result.hasStaleRates, isFalse);
    });

    test('3. foreign currency account with rate → converts correctly', () {
      // USD account, balance 100 USD (10000 minor = $100.00)
      // USD→INR rate = 83.0 → rateMicro = 83_000_000
      final acc = makeAccount(id: 'a1', currencyCode: 'USD');
      final rate = makeRate(from: 'USD', to: homeCurrency, rateMicro: 83 * microDivisor);

      final result = calculator.compute(
        accounts: [acc],
        balancesByAccountId: {'a1': 10000}, // $100.00
        ratesByFromCurrency: {'USD': rate},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      // 10000 * 83_000_000 / 1_000_000 = 830_000
      expect(result.totalMinor, 830000);
      expect(result.hasStaleRates, isFalse);
    });

    test('4. foreign currency account with missing rate → excluded, hasStaleRates=true', () {
      final acc = makeAccount(id: 'a1', currencyCode: 'USD');
      final result = calculator.compute(
        accounts: [acc],
        balancesByAccountId: {'a1': 10000},
        ratesByFromCurrency: {}, // no rate provided
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      expect(result.totalMinor, 0);
      expect(result.hasStaleRates, isTrue);
    });

    test('5. mixed: some rates present, some missing → partial sum', () {
      final accInr = makeAccount(id: 'inr', currencyCode: 'INR');
      final accUsd = makeAccount(id: 'usd', currencyCode: 'USD');
      final accGbp = makeAccount(id: 'gbp', currencyCode: 'GBP'); // no rate

      final usdRate = makeRate(from: 'USD', to: homeCurrency, rateMicro: 83 * microDivisor);

      final result = calculator.compute(
        accounts: [accInr, accUsd, accGbp],
        balancesByAccountId: {'inr': 50000, 'usd': 10000, 'gbp': 5000},
        ratesByFromCurrency: {'USD': usdRate},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      // INR: 50000, USD: 10000*83 = 830000, GBP: excluded
      expect(result.totalMinor, 50000 + 830000);
      expect(result.hasStaleRates, isTrue);
    });

    test('6. account with includeInNetWorth=false is excluded', () {
      final acc = makeAccount(id: 'a1', currencyCode: 'INR', includeInNetWorth: false);
      final result = calculator.compute(
        accounts: [acc],
        balancesByAccountId: {'a1': 100000},
        ratesByFromCurrency: {},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      expect(result.totalMinor, 0);
      expect(result.hasStaleRates, isFalse);
    });

    test('7. soft-deleted account is excluded', () {
      final acc = makeAccount(id: 'a1', currencyCode: 'INR', isDeleted: true);
      final result = calculator.compute(
        accounts: [acc],
        balancesByAccountId: {'a1': 100000},
        ratesByFromCurrency: {},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      expect(result.totalMinor, 0);
    });

    test('8. multi-currency all rates present → correct aggregate', () {
      final accInr = makeAccount(id: 'inr', currencyCode: 'INR');
      final accUsd = makeAccount(id: 'usd', currencyCode: 'USD');
      final accEur = makeAccount(id: 'eur', currencyCode: 'EUR');

      final usdRate = makeRate(from: 'USD', to: homeCurrency, rateMicro: 83 * microDivisor);
      final eurRate = makeRate(from: 'EUR', to: homeCurrency, rateMicro: 90 * microDivisor);

      final result = calculator.compute(
        accounts: [accInr, accUsd, accEur],
        balancesByAccountId: {'inr': 10000, 'usd': 1000, 'eur': 500},
        ratesByFromCurrency: {'USD': usdRate, 'EUR': eurRate},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      // INR: 10000
      // USD: 1000 * 83_000_000 / 1_000_000 = 83000
      // EUR: 500  * 90_000_000 / 1_000_000 = 45000
      expect(result.totalMinor, 10000 + 83000 + 45000);
      expect(result.hasStaleRates, isFalse);
    });

    test('9. stale rate (older than 14 days) sets hasStaleRates=true', () {
      const staleDays = 15;
      final staleEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000 - staleDays * 86400;
      final acc = makeAccount(id: 'a1', currencyCode: 'USD');
      final staleRate = makeRate(from: 'USD', to: homeCurrency, rateMicro: 83 * microDivisor, fetchedAt: staleEpoch);

      final result = calculator.compute(
        accounts: [acc],
        balancesByAccountId: {'a1': 1000},
        ratesByFromCurrency: {'USD': staleRate},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      expect(result.hasStaleRates, isTrue);
      // Amount is still included (just flagged as stale)
      expect(result.totalMinor, 83000);
    });

    test('money value object from result', () {
      final acc = makeAccount(id: 'a1', currencyCode: 'INR');
      final result = calculator.compute(
        accounts: [acc],
        balancesByAccountId: {'a1': 5000},
        ratesByFromCurrency: {},
        homeCurrency: homeCurrency,
        nowEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      final money = result.toMoney();
      expect(money, isA<Money>());
      expect(money.amountMinor, 5000);
      expect(money.currencyCode, homeCurrency);
    });
  });
}
