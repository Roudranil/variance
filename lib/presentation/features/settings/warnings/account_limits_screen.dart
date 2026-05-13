// lib/presentation/features/settings/warnings/account_limits_screen.dart
//
// Per-Account Limits sub-screen (T-181).
//
// Spec references:
//   - UX Flows §9.5.2: Per-Account Limits Sub-screen
//   - UI Spec §9.5.2: Components and visual tokens
//   - TC-047: Per-account large-transaction thresholds use account native currency
//
// Renders a list of all active accounts with an inline threshold field per row.
// The field label shows the account's native currency symbol. On change, calls
// IAccountRepository.update(account) writing largeTxnThresholdMinor.
//
// Test cases (see test/presentation/features/settings/warnings/
//             account_limits_screen_test.dart):
//   1. Empty state shows "No active accounts" message.
//   2. Populated state lists all active accounts.
//   3. Account row shows currency code as field label.
//   4. Entering a valid threshold and tapping confirm calls update.
//   5. Tapping clear removes the threshold (null).
//   6. Multi-currency: each account shows its own currency symbol.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

/// Per-Account Limits sub-screen.
///
/// Lists all active, non-system accounts with an inline threshold amount
/// field per row.  Threshold amounts are in the account's native currency.
class AccountLimitsScreen extends ConsumerWidget {
  /// Creates the [AccountLimitsScreen].
  const AccountLimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Spending Limits'),
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load accounts.'),
        ),
        data: (accounts) {
          final visible = accounts
              .where((a) => !a.isSystem && !a.isDeleted)
              .toList();
          if (visible.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              return _AccountThresholdRow(account: visible[index]);
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

/// Shown when there are no active accounts.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No active accounts',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account threshold row
// ---------------------------------------------------------------------------

/// A [ListTile] that shows an account's current threshold and expands to an
/// inline text field for editing when tapped.
class _AccountThresholdRow extends ConsumerStatefulWidget {
  const _AccountThresholdRow({required this.account});

  /// The account to display and edit.
  final Account account;

  @override
  ConsumerState<_AccountThresholdRow> createState() =>
      _AccountThresholdRowState();
}

class _AccountThresholdRowState extends ConsumerState<_AccountThresholdRow> {
  /// Whether the inline edit field is currently expanded.
  bool _isEditing = false;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = widget.account.largeTxnThresholdMinor;
    // Convert from minor units to display units (divide by 100 for 2 dp).
    _controller = TextEditingController(
      text: current != null ? (current / 100).toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMinor = widget.account.largeTxnThresholdMinor;
    final currencyCode = widget.account.currencyCode;

    if (_isEditing) {
      return _InlineEditRow(
        controller: _controller,
        currencyCode: currencyCode,
        onConfirm: _save,
        onClear: _clear,
        onCancel: _cancelEdit,
      );
    }

    final trailingText = currentMinor != null
        ? '${(currentMinor / 100).toStringAsFixed(2)} $currencyCode'
        : 'Not set';

    return ListTile(
      title: Text(widget.account.name),
      subtitle: Text(widget.account.accountCategory.name),
      trailing: Text(
        trailingText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: currentMinor != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
      ),
      onTap: () => setState(() => _isEditing = true),
    );
  }

  /// Saves the entered threshold to the repository.
  Future<void> _save() async {
    final text = _controller.text.trim();
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) {
      _cancelEdit();
      return;
    }

    // Convert display amount (2 decimal places) to minor units.
    final minorUnits = (parsed * 100).round();
    final updated = widget.account.copyWith(largeTxnThresholdMinor: minorUnits);

    final repo = await ref.read(accountRepositoryProvider.future);
    await repo.update(updated);

    if (mounted) setState(() => _isEditing = false);
  }

  /// Clears the threshold (sets to null).
  Future<void> _clear() async {
    // copyWith(largeTxnThresholdMinor: null) removes the threshold.
    final updated = widget.account.copyWith(largeTxnThresholdMinor: null);
    final repo = await ref.read(accountRepositoryProvider.future);
    await repo.update(updated);

    _controller.clear();
    if (mounted) setState(() => _isEditing = false);
  }

  void _cancelEdit() => setState(() => _isEditing = false);
}

// ---------------------------------------------------------------------------
// Inline edit row
// ---------------------------------------------------------------------------

/// Inline amount edit row with confirm and clear action buttons.
class _InlineEditRow extends StatelessWidget {
  const _InlineEditRow({
    required this.controller,
    required this.currencyCode,
    required this.onConfirm,
    required this.onClear,
    required this.onCancel,
  });

  /// Controller for the threshold amount field.
  final TextEditingController controller;

  /// ISO 4217 currency code used as field label.
  final String currencyCode;

  /// Called when the user confirms the new value.
  final VoidCallback onConfirm;

  /// Called when the user clears the threshold.
  final VoidCallback onClear;

  /// Called when the user cancels editing.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: currencyCode,
                border: const OutlineInputBorder(),
                suffixText: currencyCode,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Confirm button
          IconButton(
            tooltip: 'Confirm',
            icon: const Icon(Icons.check),
            onPressed: onConfirm,
          ),
          // Clear button
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
