// lib/presentation/features/settings/hub/settings_hub_screen.dart
//
// Settings Hub screen — the root of the settings tab.
//
// Renders 15 settings rows in four section groups as specified in:
//   - UX Flows §9.1: Settings Hub screen states and section order
//   - UI Spec §9.1: Components, section groups, and visual tokens
//
// All 15 rows navigate to their corresponding routes via GoRouter.push.
// The hub renders gracefully during AppSettingsNotifier loading / error
// states — the section list is purely static (no settings data needed to
// render the hub itself).
//
// Test cases (see test/widget/features/settings/hub/settings_hub_screen_test.dart):
//   1. All 15 rows are present in the loaded state.
//   2. Tapping each row navigates to the correct route (verified via
//      MockGoRouter).
//   3. Each row has a leading icon and trailing chevron.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/presentation/navigation/app_router.dart';

// ---------------------------------------------------------------------------
// Data model for a single settings row
// ---------------------------------------------------------------------------

/// A single settings row definition: icon, title, optional subtitle, route.
@immutable
class _SettingsRow {
  /// Creates a [_SettingsRow].
  ///
  /// Parameters:
  /// - [icon]: Leading icon data.
  /// - [title]: Primary row label.
  /// - [subtitle]: Optional secondary label.
  /// - [route]: GoRouter route path to push on tap.
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.route,
  });

  /// Leading icon data.
  final IconData icon;

  /// Primary row label.
  final String title;

  /// Optional secondary label shown below [title].
  final String? subtitle;

  /// GoRouter route path pushed on tap.
  final String route;
}

// ---------------------------------------------------------------------------
// Section group
// ---------------------------------------------------------------------------

/// A named group of settings rows shown under a shared label.
@immutable
class _SettingsSection {
  /// Creates a [_SettingsSection].
  ///
  /// Parameters:
  /// - [label]: Section header text.
  /// - [rows]: Ordered list of settings rows in this section.
  const _SettingsSection({required this.label, required this.rows});

  /// Section header text.
  final String label;

  /// Ordered list of settings rows in this section.
  final List<_SettingsRow> rows;
}

// ---------------------------------------------------------------------------
// Section data (UI Spec §9.1.2 display order)
// ---------------------------------------------------------------------------

/// Ordered list of section groups matching UI Spec §9.1.2.
const List<_SettingsSection> _kSections = [
  _SettingsSection(
    label: 'Personalisation',
    rows: [
      _SettingsRow(
        icon: Icons.palette_outlined,
        title: 'Appearance',
        subtitle: 'Theme, color scheme, animations',
        route: AppRoutes.settingsAppearance,
      ),
      _SettingsRow(
        icon: Icons.language_outlined,
        title: 'Locale & Format',
        subtitle: 'Currency format, date, numbers',
        route: AppRoutes.settingsLocale,
      ),
      _SettingsRow(
        icon: Icons.receipt_long_outlined,
        title: 'Transaction Entry',
        subtitle: 'Back button, defaults',
        route: AppRoutes.settingsTransactionEntry,
      ),
      _SettingsRow(
        icon: Icons.warning_amber_outlined,
        title: 'Warnings & Limits',
        subtitle: 'Description length, thresholds',
        route: AppRoutes.settingsWarnings,
      ),
    ],
  ),
  _SettingsSection(
    label: 'Account',
    rows: [
      _SettingsRow(
        icon: Icons.person_outlined,
        title: 'Profile',
        subtitle: 'Display name, greeting',
        route: AppRoutes.settingsProfile,
      ),
      _SettingsRow(
        icon: Icons.lock_outlined,
        title: 'Security',
        subtitle: 'App lock, biometrics',
        route: AppRoutes.settingsSecurity,
      ),
    ],
  ),
  _SettingsSection(
    label: 'Data',
    rows: [
      _SettingsRow(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Accounts',
        subtitle: 'Manage financial accounts',
        route: AppRoutes.accounts,
      ),
      _SettingsRow(
        icon: Icons.category_outlined,
        title: 'Categories',
        subtitle: 'Manage expense & income categories',
        route: AppRoutes.settingsCategories,
      ),
      _SettingsRow(
        icon: Icons.currency_exchange_outlined,
        title: 'Currency',
        subtitle: 'Enabled currencies, exchange rates',
        route: AppRoutes.settingsCurrency,
      ),
      _SettingsRow(
        icon: Icons.label_outlined,
        title: 'Tags',
        subtitle: 'Manage transaction tags',
        route: AppRoutes.settingsTags,
      ),
      _SettingsRow(
        icon: Icons.store_outlined,
        title: 'Payees',
        subtitle: 'Manage payees and merchants',
        route: AppRoutes.settingsPayees,
      ),
      _SettingsRow(
        icon: Icons.repeat_outlined,
        title: 'Recurring & Installments',
        subtitle: 'Templates and schedules',
        route: AppRoutes.settingsRecurring,
      ),
      _SettingsRow(
        icon: Icons.drafts_outlined,
        title: 'Drafts',
        subtitle: 'Unsaved transaction drafts',
        route: AppRoutes.settingsDrafts,
      ),
    ],
  ),
  _SettingsSection(
    label: 'App',
    rows: [
      _SettingsRow(
        icon: Icons.backup_outlined,
        title: 'Backup & Data',
        subtitle: 'Export, import, restore',
        route: AppRoutes.settingsBackup,
      ),
      _SettingsRow(
        icon: Icons.info_outlined,
        title: 'About',
        subtitle: 'Version, licenses',
        route: AppRoutes.settingsAbout,
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// SettingsHubScreen
// ---------------------------------------------------------------------------

/// The root settings screen displayed on the Settings tab.
///
/// Renders all 15 settings rows grouped into four sections as defined in
/// UI Spec §9.1.2. Each row navigates to its sub-screen on tap.
///
/// The screen has no dependency on [AppSettingsNotifier] — the hub list is
/// static and does not require live settings data.
class SettingsHubScreen extends StatelessWidget {
  /// Creates the [SettingsHubScreen].
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // No back arrow — this is a tab root screen.
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        // +sections for dividers between groups
        itemCount: _kSections.fold<int>(
          0,
          (count, section) => count + 1 + section.rows.length,
        ),
        itemBuilder: _buildItem,
      ),
    );
  }

  /// Builds either a section header [Text] or a [_SettingsRowTile] at [index].
  ///
  /// Walks the section list, advancing [index] by 1 (header) then by
  /// `rows.length` (rows) for each section.
  Widget _buildItem(BuildContext context, int index) {
    var cursor = 0;
    for (final section in _kSections) {
      if (index == cursor) {
        return _SectionHeader(label: section.label);
      }
      cursor++;
      final rowIndex = index - cursor;
      if (rowIndex < section.rows.length) {
        return _SettingsRowTile(row: section.rows[rowIndex]);
      }
      cursor += section.rows.length;
    }
    // Should be unreachable given correct itemCount.
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

/// A section-group header label displayed above a group of settings rows.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  /// Section label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings row tile
// ---------------------------------------------------------------------------

/// A single settings row rendered as a [ListTile] with leading icon and
/// trailing chevron. Taps navigate to [_SettingsRow.route].
class _SettingsRowTile extends StatelessWidget {
  const _SettingsRowTile({required this.row});

  /// The settings row data.
  final _SettingsRow row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        row.icon,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(row.title),
      subtitle: row.subtitle != null ? Text(row.subtitle!) : null,
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => context.push(row.route),
    );
  }
}
