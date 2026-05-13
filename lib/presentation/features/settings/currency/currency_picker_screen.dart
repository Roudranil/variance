// lib/presentation/features/settings/currency/currency_picker_screen.dart
//
// CurrencyPickerScreen — full-screen modal for selecting an ISO 4217 currency
// (T-97, UX Flows §1.5).
//
// Invocation: context.push<String>(AppRoutes.currencyPicker) — returns the
// selected ISO 4217 code, or null when the user presses back.
//
// Layout:
//   - AppBar with back button
//   - Search field (fuzzy match on code, name, symbol)
//   - Popular currencies (INR, USD, EUR, GBP, JPY) pinned at top of list
//   - Scrollable list of remaining currencies sorted alphabetically
//   - Current selection highlighted with a checkmark
//
// States:
//   loading  → CircularProgressIndicator shimmer
//   populated → search field + list
//   no-results → "No currencies match '[query]'" label
//
// Test cases (see test/.../currency_picker_screen_test.dart):
//   1. populated state — list of currencies visible
//   2. search field filters list by code / name / symbol
//   3. popular currencies pinned at top before alphabetical remainder
//   4. current selection shows checkmark

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/currency.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

/// The five popular currencies pinned at the top of the picker list.
const _kPopularCodes = ['INR', 'USD', 'EUR', 'GBP', 'JPY'];

/// Full-screen currency picker modal.
///
/// Returns the selected ISO 4217 code via [Navigator.pop] or null on back.
///
/// Parameters:
/// - [currentCode]: Pre-selected currency code shown with a checkmark.
class CurrencyPickerScreen extends ConsumerStatefulWidget {
  /// Creates a [CurrencyPickerScreen].
  const CurrencyPickerScreen({super.key, this.currentCode});

  /// Optional code of the currently selected currency.
  final String? currentCode;

  @override
  ConsumerState<CurrencyPickerScreen> createState() =>
      _CurrencyPickerScreenState();
}

class _CurrencyPickerScreenState
    extends ConsumerState<CurrencyPickerScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currenciesAsync = ref.watch(currenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search code, name or symbol…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
        ),
      ),
      body: currenciesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) => _CurrencyList(
          currencies: all,
          query: _query,
          currentCode: widget.currentCode,
          onSelected: (code) => Navigator.of(context).pop(code),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private list widget
// ---------------------------------------------------------------------------

/// Renders the filtered + pinned currency list.
class _CurrencyList extends StatelessWidget {
  const _CurrencyList({
    required this.currencies,
    required this.query,
    required this.currentCode,
    required this.onSelected,
  });

  final List<Currency> currencies;
  final String query;
  final String? currentCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final filtered = _filter(currencies, query);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty
              ? 'No currencies available.'
              : "No currencies match '$query'",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    // Split into popular and remainder.
    final popular = filtered
        .where((c) => _kPopularCodes.contains(c.code))
        .toList()
      ..sort(
        (a, b) => _kPopularCodes.indexOf(a.code)
            .compareTo(_kPopularCodes.indexOf(b.code)),
      );
    final remainder = filtered
        .where((c) => !_kPopularCodes.contains(c.code))
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    final items = <Currency>[];
    if (popular.isNotEmpty) {
      items.addAll(popular);
    }
    items.addAll(remainder);

    return ListView.builder(
      itemCount: items.length + (popular.isNotEmpty && remainder.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // Insert divider between popular and remainder sections.
        final dividerIndex = popular.length;
        if (popular.isNotEmpty && remainder.isNotEmpty && index == dividerIndex) {
          return const Divider(height: 1);
        }
        final adjustedIndex =
            (popular.isNotEmpty && remainder.isNotEmpty && index > dividerIndex)
                ? index - 1
                : index;
        final currency = items[adjustedIndex];
        return _CurrencyTile(
          currency: currency,
          isSelected: currency.code == currentCode,
          onTap: () => onSelected(currency.code),
        );
      },
    );
  }

  /// Filters [currencies] by fuzzy matching [query] against code, name,
  /// and symbol. Empty query returns all currencies.
  List<Currency> _filter(List<Currency> currencies, String query) {
    if (query.isEmpty) return currencies;
    final lower = query.toLowerCase();
    return currencies.where((c) {
      return c.code.toLowerCase().contains(lower) ||
          c.name.toLowerCase().contains(lower) ||
          c.symbol.toLowerCase().contains(lower);
    }).toList();
  }
}

/// A single currency row with optional checkmark for current selection.
class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  final Currency currency;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Text(
        currency.symbol,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
      ),
      title: Text(currency.code),
      subtitle: Text(currency.name),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
