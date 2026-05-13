// lib/presentation/features/transactions/exchange_rate_detail_screen.dart
//
// ExchangeRateDetailScreen — modal route at /exchange-rate-detail (T-98).
//
// States (UX Flows §7.9.1):
//   fresh rate    → rate value, "Cached (live estimate)" label, last-updated date
//   stale rate    → rate value + staleness warning text, last-updated date
//   no rate       → "Exchange rate unavailable." disclaimer
//   transaction   → historical rate with "Rate at time of transaction" label;
//                   no staleness indicator (historical rate is always definitive)
//
// Parameters accepted via query string or constructor:
//   fromCurrency (required) — ISO 4217 base currency code
//   toCurrency   (required) — ISO 4217 target currency code
//   transactionRate (optional) — if provided, display historical rate state
//
// Test cases (see test/.../exchange_rate_detail_screen_test.dart):
//   1. fresh rate state — rate value shown; no staleness warning
//   2. stale rate state — rate value + staleness warning shown
//   3. no rate state — "Exchange rate unavailable." shown
//   4. transaction-level rate — "Rate at time of transaction" label, no warning

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/exchange_rate.dart';
import 'package:variance/domain/usecases/currency/get_exchange_rate_use_case.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

/// Modal screen showing exchange rate details for a currency pair.
///
/// When [transactionRate] is provided, it displays the historical rate stored
/// at transaction time (definitive — no staleness indicator). Otherwise it
/// fetches the cached rate from the repository.
class ExchangeRateDetailScreen extends ConsumerWidget {
  /// Creates an [ExchangeRateDetailScreen].
  ///
  /// Parameters:
  /// - [fromCurrency]: ISO 4217 base currency code.
  /// - [toCurrency]: ISO 4217 target currency code.
  /// - [transactionRate]: Optional historical rate from a posted transaction.
  const ExchangeRateDetailScreen({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    this.transactionRate,
  });

  /// ISO 4217 base currency code.
  final String fromCurrency;

  /// ISO 4217 target currency code.
  final String toCurrency;

  /// When non-null, the historical rate stored at transaction time.
  ///
  /// In this state the screen shows "Rate at time of transaction" and suppresses
  /// the staleness indicator.
  final ExchangeRate? transactionRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If a transaction-level rate is provided, show it immediately.
    if (transactionRate != null) {
      return _DetailScaffold(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        rate: transactionRate,
        isTransactionRate: true,
      );
    }

    // Otherwise fetch the cached rate.
    final useCaseAsync = ref.watch(getExchangeRateUseCaseProvider);

    return useCaseAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text('$fromCurrency → $toCurrency')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (useCase) => _AsyncRateLoader(
        useCase: useCase,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Async loader (fetches the rate once)
// ---------------------------------------------------------------------------

class _AsyncRateLoader extends StatefulWidget {
  const _AsyncRateLoader({
    required this.useCase,
    required this.fromCurrency,
    required this.toCurrency,
  });

  final GetExchangeRateUseCase useCase;
  final String fromCurrency;
  final String toCurrency;

  @override
  State<_AsyncRateLoader> createState() => _AsyncRateLoaderState();
}

class _AsyncRateLoaderState extends State<_AsyncRateLoader> {
  ExchangeRate? _rate;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.useCase(
      GetExchangeRateInput(
        from: widget.fromCurrency,
        to: widget.toCurrency,
      ),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _rate = switch (result) {
        Ok(:final value) => value,
        Err() => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _DetailScaffold(
      fromCurrency: widget.fromCurrency,
      toCurrency: widget.toCurrency,
      rate: _rate,
      isTransactionRate: false,
    );
  }
}

// ---------------------------------------------------------------------------
// Detail scaffold — shared by all states
// ---------------------------------------------------------------------------

/// Renders the scaffold with rate information for all four screen states.
class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.isTransactionRate,
  });

  final String fromCurrency;
  final String toCurrency;
  final ExchangeRate? rate;

  /// True when [rate] is a historical transaction-level rate.
  final bool isTransactionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('$fromCurrency → $toCurrency'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency pair title
            Text(
              '$fromCurrency → $toCurrency',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            if (rate == null) ...[
              // No rate state
              Text(
                'Exchange rate unavailable.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              // Rate value
              _DetailRow(
                label: 'Rate',
                value: rate!.rate.toStringAsFixed(6),
              ),

              // Rate type label
              _DetailRow(
                label: 'Rate type',
                value: isTransactionRate
                    ? 'Rate at time of transaction'
                    : 'Cached (live estimate)',
              ),

              // Last updated
              _DetailRow(
                label: 'Last updated',
                value: _formatEpoch(rate!.fetchedAt),
              ),

              // Date from API
              _DetailRow(
                label: 'Rate date',
                value: rate!.rateDate,
              ),

              // Staleness warning — only for cached rates
              if (!isTransactionRate && rate!.isStale) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This value may be inaccurate as the exchange rate '
                          'has not been updated recently.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatEpoch(int epochSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    return '${dt.year}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Generic key-value row for rate detail information.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
