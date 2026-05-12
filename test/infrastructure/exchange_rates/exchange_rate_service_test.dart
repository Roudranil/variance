// test/infrastructure/exchange_rates/exchange_rate_service_test.dart
//
// Unit tests for ExchangeRateService (T-86).
// Uses a mock HTTP client to simulate API responses.
//
// Test cases:
//   T-86.1. success path — rates parsed correctly, rate_date captured
//   T-86.2. timeout path — returns Err(NetworkFailure)
//   T-86.3. HTTP 500 path — returns Err(NetworkFailure)
//   T-86.4. malformed JSON — returns Err(NetworkFailure)
//   T-86.5. missing date field — returns Err(NetworkFailure)

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/infrastructure/exchange_rates/exchange_rate_service.dart';

void main() {
  // T-86.1. Success path
  test('T-86.1 parses rates and rate_date from successful response', () async {
    final mockClient = MockClient((request) async {
      final body = jsonEncode({
        'date': '2025-05-07',
        'inr': {
          'usd': 0.01199,
          'eur': 0.01102,
          'gbp': 0.00945,
        },
      });
      return http.Response(body, 200);
    });

    final service = ExchangeRateService(httpClient: mockClient);
    final result = await service.fetchRatesForBase('INR');

    expect(result, isA<Ok<ExchangeRateFetchResult>>());
    final ok = (result as Ok<ExchangeRateFetchResult>).value;
    expect(ok.rateDate, '2025-05-07');
    expect(ok.rates['usd'], closeTo(0.01199, 0.00001));
    expect(ok.rates['eur'], closeTo(0.01102, 0.00001));
    expect(ok.rates['gbp'], closeTo(0.00945, 0.00001));
  });

  // T-86.2. Timeout path
  test('T-86.2 returns Err(NetworkFailure) on timeout', () async {
    final mockClient = MockClient((request) async {
      // Simulate a delay longer than the 10s timeout by throwing TimeoutException
      throw TimeoutException('timeout', const Duration(seconds: 10));
    });

    final service = ExchangeRateService(httpClient: mockClient);
    final result = await service.fetchRatesForBase('INR');

    expect(result, isA<Err<ExchangeRateFetchResult>>());
    expect((result as Err<ExchangeRateFetchResult>).failure,
        isA<NetworkFailure>(),);
  });

  // T-86.3. HTTP 500 path
  test('T-86.3 returns Err(NetworkFailure) on HTTP 500', () async {
    final mockClient = MockClient((request) async {
      return http.Response('Internal Server Error', 500);
    });

    final service = ExchangeRateService(httpClient: mockClient);
    final result = await service.fetchRatesForBase('INR');

    expect(result, isA<Err<ExchangeRateFetchResult>>());
    final err = result as Err<ExchangeRateFetchResult>;
    expect(err.failure, isA<NetworkFailure>());
    expect(err.failure.message, contains('500'));
  });

  // T-86.4. Malformed JSON
  test('T-86.4 returns Err(NetworkFailure) on malformed JSON', () async {
    final mockClient = MockClient((request) async {
      return http.Response('not valid json }{', 200);
    });

    final service = ExchangeRateService(httpClient: mockClient);
    final result = await service.fetchRatesForBase('INR');

    expect(result, isA<Err<ExchangeRateFetchResult>>());
    expect((result as Err<ExchangeRateFetchResult>).failure,
        isA<NetworkFailure>(),);
  });

  // T-86.5. Missing date field
  test('T-86.5 returns Err(NetworkFailure) when date field absent', () async {
    final mockClient = MockClient((request) async {
      final body = jsonEncode({'inr': {'usd': 0.012}});
      return http.Response(body, 200);
    });

    final service = ExchangeRateService(httpClient: mockClient);
    final result = await service.fetchRatesForBase('INR');

    expect(result, isA<Err<ExchangeRateFetchResult>>());
    expect((result as Err<ExchangeRateFetchResult>).failure,
        isA<NetworkFailure>(),);
  });
}
