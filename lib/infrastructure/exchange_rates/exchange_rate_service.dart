// lib/infrastructure/exchange_rates/exchange_rate_service.dart
//
// HTTP service for fetching exchange rates from the fawazahmed0 CDN API.
//
// Architecture (SDS §2.7.5):
//   Lives entirely in lib/infrastructure/exchange_rates/. No imports from the
//   domain layer other than the Result type and Failure hierarchy.
//
// API contract (SDS §2.7.1):
//   GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/{base}.min.json
//   Response: {"date": "2024-01-15", "{base}": {"eur": 0.912, "inr": 83.12, ...}}
//
// Behaviour:
//   - 10-second timeout; on timeout or HTTP error → Err(NetworkFailure)
//   - Parses rate_date from top-level "date" field
//   - Returns Result<Map<String, double>> mapping target currency code → rate
//
// Test cases (see test/infrastructure/exchange_rates/exchange_rate_service_test.dart):
//   T-86.1. success path — rates parsed correctly, rate_date captured
//   T-86.2. timeout path — returns Err(NetworkFailure)
//   T-86.3. HTTP 500 path — returns Err(NetworkFailure)

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';

/// Base URL for the fawazahmed0 exchange rate API served via jsDelivr CDN.
///
/// A single GET to this endpoint with the base currency substituted returns
/// all target currency rates in one payload.
const kExchangeRateApiBase =
    'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies';

/// HTTP fetch timeout per SDS §2.7.2.
const _kTimeout = Duration(seconds: 10);

/// Result of a successful fetch, combining parsed rates and the API date field.
class ExchangeRateFetchResult {
  /// Creates an [ExchangeRateFetchResult].
  const ExchangeRateFetchResult({
    required this.rates,
    required this.rateDate,
  });

  /// Map of target currency code (lower-case) → exchange rate.
  final Map<String, double> rates;

  /// ISO 8601 date string from the API `date` field.
  final String rateDate;
}

/// Fetches exchange rates for the given base currency from the fawazahmed0 CDN.
///
/// Lives in the infrastructure layer; no domain imports beyond [Result] and
/// [Failure]. Swapping the provider (e.g. to Frankfurter) requires changing
/// [kExchangeRateApiBase] and [_parseResponse] only.
class ExchangeRateService {
  /// Creates an [ExchangeRateService].
  ///
  /// Parameters:
  /// - [httpClient]: Injected HTTP client; pass [http.Client()] in production
  ///   and a mock client in tests.
  ExchangeRateService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;

  /// Fetches the latest rates for [baseCurrency] from the remote API.
  ///
  /// Issues one GET request per [baseCurrency]. Returns a
  /// [ExchangeRateFetchResult] on success containing all target rates in the
  /// payload and the server-reported [ExchangeRateFetchResult.rateDate].
  ///
  /// Returns [Err] on timeout, HTTP error, or JSON parse failure — the caller
  /// (WorkManager task) handles all failure paths silently.
  ///
  /// Parameters:
  /// - [baseCurrency]: ISO 4217 base currency code (lower-cased before fetch).
  Future<Result<ExchangeRateFetchResult>> fetchRatesForBase(
    String baseCurrency,
  ) async {
    final base = baseCurrency.toLowerCase();
    final url = Uri.parse('$kExchangeRateApiBase/$base.min.json');

    try {
      final response = await _client.get(url).timeout(_kTimeout);

      if (response.statusCode != 200) {
        dev.log(
          'ExchangeRateService: HTTP ${response.statusCode} for $url',
          name: 'ExchangeRateService',
        );
        return Err(
          NetworkFailure(
            'Exchange rate fetch failed: HTTP ${response.statusCode}',
          ),
        );
      }

      return _parseResponse(response.body, base);
    } on Exception catch (e) {
      dev.log(
        'ExchangeRateService: fetch failed for $base — $e',
        name: 'ExchangeRateService',
      );
      return Err(NetworkFailure('Exchange rate fetch failed: $e'));
    }
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// Parses the JSON response body from the fawazahmed0 API.
  ///
  /// Expected structure:
  /// ```json
  /// {"date": "2024-01-15", "inr": {"usd": 0.012, "eur": 0.011, ...}}
  /// ```
  ///
  /// Returns [Err] on malformed JSON or missing expected keys.
  Result<ExchangeRateFetchResult> _parseResponse(
    String body,
    String base,
  ) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;

      final rateDate = json['date'] as String?;
      if (rateDate == null || rateDate.isEmpty) {
        return const Err(NetworkFailure('Exchange rate response missing date'));
      }

      final ratesRaw = json[base] as Map<String, dynamic>?;
      if (ratesRaw == null) {
        return Err(
          NetworkFailure(
            'Exchange rate response missing rates for base currency: $base',
          ),
        );
      }

      // Convert all values to double; skip any non-numeric entries.
      final rates = <String, double>{};
      for (final entry in ratesRaw.entries) {
        final value = entry.value;
        if (value is num) {
          rates[entry.key] = value.toDouble();
        }
      }

      return Ok(ExchangeRateFetchResult(rates: rates, rateDate: rateDate));
    } on FormatException catch (e) {
      dev.log(
        'ExchangeRateService: JSON parse failed — $e',
        name: 'ExchangeRateService',
      );
      return Err(NetworkFailure('Exchange rate JSON parse failed: $e'));
    }
  }
}
