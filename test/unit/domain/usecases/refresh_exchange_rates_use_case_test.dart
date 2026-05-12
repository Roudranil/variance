// test/unit/domain/usecases/refresh_exchange_rates_use_case_test.dart
//
// Unit tests for RefreshExchangeRatesUseCase (T-87).
// Uses hand-written fakes; no Drift or HTTP dependencies.
//
// Test cases:
//   T-87.1. single-home-currency path — no fetch issued, returns Ok(null)
//   T-87.2. multi-currency path — fetch called, rates upserted, returns Ok(null)
//   T-87.3. service-failure path — returns Err(NetworkFailure), no upsert

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/usecases/currency/refresh_exchange_rates_use_case.dart';
import 'package:variance/infrastructure/exchange_rates/exchange_rate_service.dart';

// ---------------------------------------------------------------------------
// Fake account repository
// ---------------------------------------------------------------------------

class _FakeAccountRepository implements IAccountRepository {
  _FakeAccountRepository(this._currencies);

  final List<String> _currencies;

  @override
  Future<List<String>> getDistinctActiveCurrencies() async => _currencies;

  // Unsupported stubs
  @override
  Stream<List<Account>> watchAll() => throw UnimplementedError();
  @override
  Stream<Account?> watchById(String id) => throw UnimplementedError();
  @override
  Future<Result<Account>> create(Account account) => throw UnimplementedError();
  @override
  Future<Result<Account>> update(Account account) => throw UnimplementedError();
  @override
  Future<Result<void>> softDelete(String id) => throw UnimplementedError();
  @override
  Stream<Money> watchBalance(String id, String currencyCode) =>
      throw UnimplementedError();
  @override
  Future<bool> isNameTaken(String name) => throw UnimplementedError();
  @override
  Future<Account?> findSoftDeletedByNameAndCategory(
          String name, AccountCategory category,) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> saveAccountDetails(
          String accountId, List<AccountDetail> details,) =>
      throw UnimplementedError();
  @override
  Future<List<AccountDetail>> getAccountDetails(String accountId) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Fake exchange rate upsert sink (tracks upsertRate calls)
// ---------------------------------------------------------------------------

class _FakeUpsertSink implements IRateUpsertSink {
  final _upserts = <Map<String, dynamic>>[];

  /// Returns all recorded upsert calls.
  List<Map<String, dynamic>> get upserts => List.unmodifiable(_upserts);

  @override
  Future<Result<void>> upsertRate({
    required String from,
    required String to,
    required int rateMicro,
    required int fetchedAt,
    required String rateDate,
  }) async {
    _upserts.add({
      'from': from,
      'to': to,
      'rateMicro': rateMicro,
      'rateDate': rateDate,
    });
    return const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// Fake exchange rate service
// ---------------------------------------------------------------------------

class _FakeExchangeRateService extends ExchangeRateService {
  _FakeExchangeRateService({required this.fakeResult});

  final Result<ExchangeRateFetchResult> fakeResult;
  int fetchCallCount = 0;

  @override
  Future<Result<ExchangeRateFetchResult>> fetchRatesForBase(
    String baseCurrency,
  ) async {
    fetchCallCount++;
    return fakeResult;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const kHome = 'INR';

  // T-87.1. Single-home-currency path — no fetch issued
  test('T-87.1 single-home-currency: no fetch issued, returns Ok(null)',
      () async {
    final service = _FakeExchangeRateService(
      fakeResult: const Ok(
        ExchangeRateFetchResult(
          rates: {'usd': 0.012},
          rateDate: '2025-05-07',
        ),
      ),
    );
    final sink = _FakeUpsertSink();
    final accountRepo = _FakeAccountRepository([kHome]);

    final useCase = RefreshExchangeRatesUseCase(
      accountRepository: accountRepo,
      rateUpsertSink: sink,
      exchangeRateService: service,
      homeCurrency: kHome,
    );

    final result = await useCase.call();

    expect(result, isA<Ok<void>>());
    // No network fetch should have been triggered.
    expect(service.fetchCallCount, 0);
    expect(sink.upserts, isEmpty);
  });

  // T-87.2. Multi-currency path — fetch and upsert called
  test('T-87.2 multi-currency: fetch called and rates upserted', () async {
    final service = _FakeExchangeRateService(
      fakeResult: const Ok(
        ExchangeRateFetchResult(
          rates: {'usd': 0.012, 'eur': 0.011},
          rateDate: '2025-05-07',
        ),
      ),
    );
    final sink = _FakeUpsertSink();
    final accountRepo = _FakeAccountRepository([kHome, 'USD']);

    final useCase = RefreshExchangeRatesUseCase(
      accountRepository: accountRepo,
      rateUpsertSink: sink,
      exchangeRateService: service,
      homeCurrency: kHome,
    );

    final result = await useCase.call();

    expect(result, isA<Ok<void>>());
    expect(service.fetchCallCount, 1);
    // Only USD should be upserted (EUR not in account currencies)
    expect(sink.upserts, hasLength(1));
    expect(sink.upserts.first['from'], kHome);
    expect(sink.upserts.first['to'], 'USD');
    expect(sink.upserts.first['rateDate'], '2025-05-07');
  });

  // T-87.3. Service-failure path — returns Err, no upsert
  test('T-87.3 service failure: returns Err, no upsert called', () async {
    final service = _FakeExchangeRateService(
      fakeResult: const Err(NetworkFailure('timeout')),
    );
    final sink = _FakeUpsertSink();
    final accountRepo = _FakeAccountRepository([kHome, 'USD']);

    final useCase = RefreshExchangeRatesUseCase(
      accountRepository: accountRepo,
      rateUpsertSink: sink,
      exchangeRateService: service,
      homeCurrency: kHome,
    );

    final result = await useCase.call();

    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<NetworkFailure>());
    expect(sink.upserts, isEmpty);
  });
}
