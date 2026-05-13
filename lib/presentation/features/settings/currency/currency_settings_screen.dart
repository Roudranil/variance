// lib/presentation/features/settings/currency/currency_settings_screen.dart
//
// CurrencySettingsScreen — /settings/currency (T-96, S-40).
//
// Layout (UX Flows §9.10):
//   - Home currency row: current code + name + info warning banner
//   - Secondary currencies list: active-account currencies with last-fetched
//     timestamp and "Outdated" label when isStale
//   - Tapping home currency row opens CurrencyPickerScreen
//
// States:
//   loading  → CircularProgressIndicator
//   error    → error message
//   loaded   → home currency row + secondary list
//
// Test cases (see test/.../currency_settings_screen_test.dart):
//   1. loaded state renders home currency code and name
//   2. stale secondary currency shows "Outdated" label
//   3. home currency row tap navigates to currency picker

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/presentation/features/settings/currency/currency_settings_notifier.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

/// Currency settings screen showing home currency + secondary currencies.
class CurrencySettingsScreen extends ConsumerWidget {
  /// Creates a [CurrencySettingsScreen].
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(currencySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency'),
        centerTitle: false,
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $e'),
          ),
        ),
        data: (state) => _CurrencySettingsBody(state: state),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _CurrencySettingsBody extends StatelessWidget {
  const _CurrencySettingsBody({required this.state});

  final CurrencySettingsState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Home currency section
        _SectionHeader(label: 'Home Currency'),
        _HomeCurrencyRow(homeCurrencyCode: state.homeCurrency),
        _HomeCurrencyWarningBanner(),

        // Secondary currencies section
        if (state.secondaryCurrencies.isNotEmpty) ...[
          _SectionHeader(label: 'Secondary Currencies'),
          ...state.secondaryCurrencies
              .map((e) => _SecondaryCurrencyRow(entry: e)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Secondary currencies are derived from your account settings.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Home currency row
// ---------------------------------------------------------------------------

/// Row displaying the home currency code + name.
///
/// Tapping opens [CurrencyPickerScreen] to allow the user to select a new
/// home currency. The result is applied via [CurrencySettingsNotifier].
class _HomeCurrencyRow extends ConsumerWidget {
  const _HomeCurrencyRow({required this.homeCurrencyCode});

  final String homeCurrencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.public),
      title: Text(homeCurrencyCode),
      subtitle: _HomeCurrencyName(code: homeCurrencyCode),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // Navigate to CurrencyPickerScreen and await the selected code.
        final selected = await context.push<String>(
          AppRoutes.currencyPicker,
        );
        if (selected == null) return;
        if (!context.mounted) return;
        try {
          await ref
              .read(currencySettingsProvider.notifier)
              .changeHomeCurrency(selected);
        } on Exception catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      },
    );
  }
}

/// Resolves and displays the full name for [code] from the currencies list.
class _HomeCurrencyName extends ConsumerWidget {
  const _HomeCurrencyName({required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currenciesAsync = ref.watch(currenciesProvider);
    final name = currenciesAsync.value
        ?.where((c) => c.code == code)
        .firstOrNull
        ?.name;
    return Text(name ?? code);
  }
}

// ---------------------------------------------------------------------------
// Home currency warning banner
// ---------------------------------------------------------------------------

/// Informational banner: changing home currency doesn't affect existing txns.
class _HomeCurrencyWarningBanner extends StatelessWidget {
  const _HomeCurrencyWarningBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Changing home currency does not affect existing transactions. '
                'Net worth display will recalculate using new exchange rates.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Secondary currency row
// ---------------------------------------------------------------------------

/// Row for a single secondary currency entry.
///
/// Shows currency code + name, last-fetched timestamp, and "Outdated" chip
/// when [SecondaryCurrencyEntry.isStale] is true.
class _SecondaryCurrencyRow extends StatelessWidget {
  const _SecondaryCurrencyRow({required this.entry});

  final SecondaryCurrencyEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latestRate = entry.latestRate;

    return ListTile(
      leading: const Icon(Icons.swap_horiz),
      title: Text('${entry.currency.code} — ${entry.currency.name}'),
      subtitle: latestRate != null
          ? Text(_formatFetchDate(latestRate.fetchedAt))
          : const Text('Rate not fetched'),
      trailing: entry.isStale
          ? Chip(
              label: const Text('Outdated'),
              backgroundColor: colorScheme.errorContainer,
              labelStyle: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 11,
              ),
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : null,
    );
  }

  /// Formats the fetchedAt epoch (Unix seconds) as a human-readable date.
  String _formatFetchDate(int epochSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    return 'Last updated: ${dt.year}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

/// Bold section label above a group of list tiles.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
