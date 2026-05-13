// lib/presentation/features/settings/transaction_entry/transaction_entry_settings_screen.dart
//
// Transaction Entry settings screen (T-179).
//
// Spec references:
//   - UX Flows §9.4: Transaction Entry Settings screen states and controls
//   - UI Spec §9.4: Components and visual tokens
//
// Controls:
//   - Description max length — DropdownButton (500 / 1000 / 2000)
//   - Back-button behaviour — three RadioListTile rows (Ask / Auto-save / Discard)
//   - Draft lifecycle info card — shown only when Auto-save is selected
//
// All saves via AppSettingsNotifier.save(patch).
//
// Test cases (see test/presentation/features/settings/transaction_entry/
//             transaction_entry_settings_screen_test.dart):
//   1. Description max length dropdown shows current value.
//   2. Selecting a description max length writes the correct patch.
//   3. Back button behaviour radio reflects current setting.
//   4. Selecting "Ask" writes BackButtonBehaviour.ask patch.
//   5. Selecting "Auto-save" writes BackButtonBehaviour.autoSaveDraft patch.
//   6. Selecting "Discard" writes BackButtonBehaviour.discard patch.
//   7. Draft lifecycle info card visible only when Auto-save is selected.
//   8. Draft lifecycle info card hidden when Ask is selected.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Settings screen for transaction entry preferences.
///
/// Reads current values from [AppSettingsNotifier] and writes patches back on
/// each user interaction.
class TransactionEntrySettingsScreen extends ConsumerWidget {
  /// Creates the [TransactionEntrySettingsScreen].
  const TransactionEntrySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Entry'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load transaction entry settings.'),
        ),
        data: (settings) => _TransactionEntryBody(settings: settings),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The scrollable body of the transaction entry settings screen.
class _TransactionEntryBody extends ConsumerWidget {
  const _TransactionEntryBody({required this.settings});

  /// The current [AppSettings] to pre-fill all controls.
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // -------------------------------------------------------------------
        // Description section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Description'),
        _DescriptionMaxLengthRow(maxLength: settings.descriptionMaxLength),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Back button behaviour section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Back Button Behaviour'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'What happens when you press back with unsaved changes?',
          ),
        ),
        _BackButtonBehaviourRadioGroup(
          current: settings.backButtonBehaviour,
          onChanged: (v) => ref
              .read(appSettingsProvider.notifier)
              .save(AppSettingsPatch(backButtonBehaviour: v)),
        ),

        // Draft lifecycle info card — visible only when Auto-save is selected.
        if (settings.backButtonBehaviour == BackButtonBehaviour.autoSaveDraft)
          const _DraftLifecycleInfoCard(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

/// A section-group label above a settings group.
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
// Description max length row
// ---------------------------------------------------------------------------

/// A [ListTile] with a [DropdownButton] trailing for description max length.
class _DescriptionMaxLengthRow extends ConsumerWidget {
  const _DescriptionMaxLengthRow({required this.maxLength});

  /// Current description max length (500 / 1000 / 2000).
  final int maxLength;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Clamp to valid options in case of an unexpected stored value.
    final safeValue = const [500, 1000, 2000].contains(maxLength) ? maxLength : 1000;
    return ListTile(
      title: const Text('Description max length'),
      trailing: DropdownButton<int>(
        value: safeValue,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 500, child: Text('500 chars')),
          DropdownMenuItem(value: 1000, child: Text('1000 chars')),
          DropdownMenuItem(value: 2000, child: Text('2000 chars')),
        ],
        onChanged: (v) {
          if (v == null) return;
          ref.read(appSettingsProvider.notifier).save(
                AppSettingsPatch(descriptionMaxLength: v),
              );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Back button behaviour radio group
// ---------------------------------------------------------------------------

/// Three radio rows for the back-button behaviour preference.
///
/// Uses [RadioGroup] (Flutter 3.32+) to avoid the deprecated [RadioListTile]
/// [groupValue] and [onChanged] parameters.
class _BackButtonBehaviourRadioGroup extends StatelessWidget {
  const _BackButtonBehaviourRadioGroup({
    required this.current,
    required this.onChanged,
  });

  /// Currently selected behaviour.
  final BackButtonBehaviour current;

  /// Called when the user selects a new option.
  final ValueChanged<BackButtonBehaviour> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<BackButtonBehaviour>(
      groupValue: current,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      child: const Column(
        children: [
          RadioListTile<BackButtonBehaviour>(
            title: Text('Ask every time'),
            subtitle: Text('Show a dialog with Save / Discard options'),
            value: BackButtonBehaviour.ask,
          ),
          RadioListTile<BackButtonBehaviour>(
            title: Text('Auto-save draft'),
            subtitle: Text('Silently save as a draft (max 5 slots)'),
            value: BackButtonBehaviour.autoSaveDraft,
          ),
          RadioListTile<BackButtonBehaviour>(
            title: Text('Discard immediately'),
            subtitle: Text('Discard changes without prompting'),
            value: BackButtonBehaviour.discard,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Draft lifecycle info card
// ---------------------------------------------------------------------------

/// An informational [Card] explaining draft slot limits.
///
/// Shown only when back-button behaviour is set to [BackButtonBehaviour.autoSaveDraft].
class _DraftLifecycleInfoCard extends StatelessWidget {
  /// Creates the [_DraftLifecycleInfoCard].
  const _DraftLifecycleInfoCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Max 5 drafts. Oldest draft is evicted silently when the '
                  'limit is reached. Drafts have no expiry.',
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
