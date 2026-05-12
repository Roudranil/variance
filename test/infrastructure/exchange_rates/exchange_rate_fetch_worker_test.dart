// test/infrastructure/exchange_rates/exchange_rate_fetch_worker_test.dart
//
// Unit tests for ExchangeRateFetchWorker (T-88).
// Uses fakes for IAppSettingsRepository and RefreshExchangeRatesUseCase.
//
// Test cases:
//   T-88.1. within 23 hours — no fetch triggered, returns true
//   T-88.2. outside 23 hours — fetch triggered, timestamp updated, returns true
//   T-88.3. fetch failure — silent failure, timestamp NOT updated, returns true

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/domain/usecases/currency/refresh_exchange_rates_use_case.dart';
import 'package:variance/infrastructure/exchange_rates/exchange_rate_fetch_worker.dart';
import 'package:variance/infrastructure/exchange_rates/exchange_rate_service.dart';

// ---------------------------------------------------------------------------
// Fake settings repository
// ---------------------------------------------------------------------------

class _FakeAppSettingsRepository implements IAppSettingsRepository {
  _FakeAppSettingsRepository({required int? lastFetch})
      : _lastFetch = lastFetch;

  int? _lastFetch;
  final _patches = <AppSettingsPatch>[];

  /// Returns recorded patches.
  List<AppSettingsPatch> get patches => List.unmodifiable(_patches);

  @override
  Stream<AppSettings> watch() => Stream.value(AppSettings(
        lastExchangeRateFetch: _lastFetch,
        onboardingComplete: true,
      ),);

  @override
  Future<Result<void>> update(AppSettingsPatch patch) async {
    _patches.add(patch);
    if (patch.lastExchangeRateFetch != null) {
      _lastFetch = patch.lastExchangeRateFetch;
    }
    return const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// Fake IAccountRepository for the use case stub constructor
// ---------------------------------------------------------------------------

class _NoOpAccountRepository implements IAccountRepository {
  @override
  Future<List<String>> getDistinctActiveCurrencies() async => ['INR'];
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
// Fake IRateUpsertSink
// ---------------------------------------------------------------------------

class _NoOpUpsertSink implements IRateUpsertSink {
  @override
  Future<Result<void>> upsertRate({
    required String from,
    required String to,
    required int rateMicro,
    required int fetchedAt,
    required String rateDate,
  }) async =>
      const Ok(null);
}

// ---------------------------------------------------------------------------
// Fake RefreshExchangeRatesUseCase — overrides call()
// ---------------------------------------------------------------------------

class _FakeRefreshUseCase extends RefreshExchangeRatesUseCase {
  _FakeRefreshUseCase({required this.fakeResult})
      : super(
          accountRepository: _NoOpAccountRepository(),
          rateUpsertSink: _NoOpUpsertSink(),
          // ExchangeRateService with null client — call() is overridden
          // and never reaches the real implementation.
          exchangeRateService: ExchangeRateService(),
          homeCurrency: 'INR',
        );

  final Result<void> fakeResult;
  int callCount = 0;

  @override
  Future<Result<void>> call() async {
    callCount++;
    return fakeResult;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // T-88.1. Within 23 hours — no fetch triggered
  test('T-88.1 within 23 hours: no fetch, returns true', () async {
    // Last fetch was 1 hour ago.
    final settings = _FakeAppSettingsRepository(lastFetch: nowEpoch - 3600);
    final useCase = _FakeRefreshUseCase(fakeResult: const Ok(null));

    final result = await ExchangeRateFetchWorker.execute(
      settingsRepository: settings,
      useCase: useCase,
    );

    expect(result, isTrue);
    expect(useCase.callCount, 0);
    expect(settings.patches, isEmpty);
  });

  // T-88.2. Outside 23 hours — fetch triggered, timestamp updated
  test('T-88.2 outside 23 hours: fetch triggered, timestamp updated',
      () async {
    // Last fetch was 24 hours ago.
    final settings = _FakeAppSettingsRepository(lastFetch: nowEpoch - 86400);
    final useCase = _FakeRefreshUseCase(fakeResult: const Ok(null));

    final result = await ExchangeRateFetchWorker.execute(
      settingsRepository: settings,
      useCase: useCase,
    );

    expect(result, isTrue);
    expect(useCase.callCount, 1);
    expect(settings.patches, hasLength(1));
    expect(settings.patches.first.lastExchangeRateFetch, isNotNull);
    expect(
      settings.patches.first.lastExchangeRateFetch,
      greaterThanOrEqualTo(nowEpoch),
    );
  });

  // T-88.3. Fetch failure — silent, timestamp NOT updated
  test('T-88.3 fetch failure: silent failure, timestamp not updated', () async {
    // Last fetch was 25 hours ago.
    final settings = _FakeAppSettingsRepository(lastFetch: nowEpoch - 90000);
    final useCase = _FakeRefreshUseCase(
      fakeResult: const Err(NetworkFailure('timeout')),
    );

    final result = await ExchangeRateFetchWorker.execute(
      settingsRepository: settings,
      useCase: useCase,
    );

    expect(result, isTrue);
    expect(useCase.callCount, 1);
    // Timestamp must NOT be updated on failure.
    expect(settings.patches, isEmpty);
  });
}
