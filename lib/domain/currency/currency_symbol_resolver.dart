// lib/domain/currency/currency_symbol_resolver.dart
//
// CurrencySymbolResolver — pure-Dart domain helper (no Flutter dependency).
//
// Resolves display labels for currencies in contexts where multiple active
// accounts use currencies with the same symbol (e.g. '$' for USD, CAD, AUD).
// When a symbol collision is detected, each colliding currency receives the
// ISO suffix label: '$USD', '$CAD'. Non-colliding currencies keep bare symbols.
//
// Specification: CURR-02 — Currency Symbol Disambiguation (feature-dag.md)
// Data model reference: §4.1 currencies
//
// Test cases (see test/unit/domain/currency/currency_symbol_resolver_test.dart):
//   1. single currency — label equals bare symbol
//   2. two currencies sharing a symbol — both receive ISO-suffixed labels
//   3. three currencies where only two share a symbol — only colliding pair suffixed
//   4. empty input — returns empty map
//   5. currencies with unique symbols — all bare symbols
//   6. all three share a symbol — all suffixed

import 'package:variance/domain/entities/currency.dart';

/// Resolves display labels for a list of active-account currencies.
///
/// Groups the provided [currencies] by their [Currency.symbol]. Any symbol
/// shared by more than one currency triggers disambiguation: every currency in
/// that group receives the label `'${symbol}${code}'` (e.g. `'$USD'`).
/// Currencies with a unique symbol retain the bare symbol as their label.
///
/// The returned map keys are ISO 4217 currency codes.
class CurrencySymbolResolver {
  /// Creates a const [CurrencySymbolResolver].
  const CurrencySymbolResolver();

  /// Resolves display labels for [currencies].
  ///
  /// Returns a [Map] from currency code to display label.
  /// The map is unmodifiable.
  ///
  /// Parameters:
  /// - [currencies]: List of active-account currencies to disambiguate.
  Map<String, String> resolve(List<Currency> currencies) {
    if (currencies.isEmpty) return const {};

    // Group currencies by symbol.
    final bySymbol = <String, List<Currency>>{};
    for (final currency in currencies) {
      bySymbol.putIfAbsent(currency.symbol, () => []).add(currency);
    }

    final labels = <String, String>{};
    for (final entry in bySymbol.entries) {
      final symbol = entry.key;
      final group = entry.value;
      if (group.length > 1) {
        // Collision: append ISO code suffix for every currency in the group.
        for (final currency in group) {
          labels[currency.code] = '$symbol${currency.code}';
        }
      } else {
        // No collision: bare symbol.
        labels[group.first.code] = symbol;
      }
    }

    return Map.unmodifiable(labels);
  }
}
