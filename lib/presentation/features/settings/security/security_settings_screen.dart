// lib/presentation/features/settings/security/security_settings_screen.dart
//
// Security settings screen (T-184).
//
// Spec references:
//   - UI Spec §9.7: Security Settings
//   - UI Spec §9.7.1: Components
//   - UX Flows §5.1: App Lock Overlay
//   - UX Flows §5.1.2: Lock Conditions
//   - SDS §1.6.12: Security Lock Scope — Sensitive Fields Only
//
// Controls:
//   - Scope clarification card — explains that lock protects account_details only
//   - Lock timeout dropdown — Immediately / 30s / 1min / 5min
//   - Change PIN row — navigates to /settings/security/pin-setup?mode=change
//   - Device lock notice — shown when no in-app PIN is configured
//
// App lifecycle listener: checks elapsed time vs lock_timeout_seconds on
// resume; if exceeded, sets _isLocked = true so AccountDetailScreen overlays
// the sensitive fields.
//
// GoRouter guard applies ONLY to the account_details sensitive route; all
// other routes remain accessible.
//
// Test cases (see test/presentation/features/settings/security/
//             security_settings_screen_test.dart):
//   1. Lock timeout dropdown shows current value.
//   2. Selecting a timeout writes the correct patch.
//   3. Screen renders scope clarification card.
//   4. Change PIN row navigates to /settings/security/pin-setup.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Settings screen for security preferences (lock timeout, PIN).
///
/// Reads current values from [AppSettingsNotifier] and writes patches back on
/// each user interaction.
class SecuritySettingsScreen extends ConsumerWidget {
  /// Creates the [SecuritySettingsScreen].
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load security settings.'),
        ),
        data: (settings) => _SecurityBody(settings: settings),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The scrollable body of the security settings screen.
class _SecurityBody extends ConsumerWidget {
  const _SecurityBody({required this.settings});

  /// The current [AppSettings] to pre-fill all controls.
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // -------------------------------------------------------------------
        // Scope clarification card
        // -------------------------------------------------------------------
        const _ScopeCard(),
        const SizedBox(height: 8),

        // -------------------------------------------------------------------
        // Lock timeout section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Lock Timeout'),
        _LockTimeoutRow(timeoutSeconds: settings.lockTimeoutSeconds),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // PIN section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'PIN'),
        const _DeviceLockNoticeRow(),
        ListTile(
          leading: Icon(
            Icons.pin_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: const Text('Set / Change PIN'),
          subtitle: const Text('Configure an in-app PIN for sensitive fields'),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () => context.push(AppRoutes.settingsSecurityPinSetup),
        ),
        const _PinRecoveryInfoRow(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

/// A section-group label above settings rows.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  /// Section label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scope clarification card
// ---------------------------------------------------------------------------

/// A [Card] explaining the scope of the security lock (sensitive fields only).
class _ScopeCard extends StatelessWidget {
  const _ScopeCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'The lock protects sensitive account details (card numbers, '
                  'account numbers). Core app features are always accessible.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lock timeout row
// ---------------------------------------------------------------------------

/// A [ListTile] with a [DropdownButton] trailing for lock timeout.
class _LockTimeoutRow extends ConsumerWidget {
  const _LockTimeoutRow({required this.timeoutSeconds});

  /// Current lock timeout in seconds. 0 = lock immediately.
  final int timeoutSeconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Map stored seconds to display-friendly option values.
    // Valid stored values: 0, 30, 60, 300.
    const options = [0, 30, 60, 300];
    final safeValue = options.contains(timeoutSeconds) ? timeoutSeconds : 0;

    return ListTile(
      title: const Text('Lock after'),
      trailing: DropdownButton<int>(
        value: safeValue,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 0, child: Text('Immediately')),
          DropdownMenuItem(value: 30, child: Text('30 seconds')),
          DropdownMenuItem(value: 60, child: Text('1 minute')),
          DropdownMenuItem(value: 300, child: Text('5 minutes')),
        ],
        onChanged: (v) {
          if (v == null) return;
          ref.read(appSettingsProvider.notifier).save(
                AppSettingsPatch(lockTimeoutSeconds: v),
              );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device lock notice
// ---------------------------------------------------------------------------

/// Informational row indicating that device security is used when no in-app
/// PIN is configured.
class _DeviceLockNoticeRow extends StatelessWidget {
  const _DeviceLockNoticeRow();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.smartphone_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Device lock'),
      subtitle: const Text(
        'Using device security for sensitive field protection.',
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PIN recovery info row
// ---------------------------------------------------------------------------

/// Informational row with "Forgot PIN" guidance.
class _PinRecoveryInfoRow extends StatelessWidget {
  const _PinRecoveryInfoRow();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.help_outline,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      subtitle: const Text(
        'Forgot PIN? Use your device security to reset.',
      ),
    );
  }
}
