// lib/presentation/features/settings/warnings/warnings_settings_screen.dart
//
// Warnings & Limits settings hub screen (T-181, T-182).
//
// Spec references:
//   - UX Flows §9.5: Warnings & Limits screen
//   - UI Spec §9.5: Components and visual tokens
//
// Entry screen renders two navigation rows:
//   - Per-Account Limits → /settings/warnings/accounts (T-181)
//   - Per-Category Limits → /settings/warnings/categories (T-182)
//
// Test cases (see test/presentation/features/settings/warnings/
//             warnings_settings_screen_test.dart):
//   1. Both navigation rows are present.
//   2. Tapping Per-Account row navigates to /settings/warnings/accounts.
//   3. Tapping Per-Category row navigates to /settings/warnings/categories.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/presentation/navigation/app_router.dart';

/// The Warnings & Limits settings hub screen.
///
/// Shows two navigation rows: Per-Account Limits and Per-Category Limits.
class WarningsSettingsScreen extends StatelessWidget {
  /// Creates the [WarningsSettingsScreen].
  const WarningsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warnings & Limits'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: Icon(
              Icons.account_balance_wallet_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            title: const Text('Per-Account Limits'),
            subtitle: const Text(
              'Set large-transaction thresholds per account',
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push(AppRoutes.settingsWarningsAccounts),
          ),
          ListTile(
            leading: Icon(
              Icons.category_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            title: const Text('Per-Category Limits'),
            subtitle: const Text(
              'Set large-transaction thresholds per category',
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push(AppRoutes.settingsWarningsCategories),
          ),
        ],
      ),
    );
  }
}
