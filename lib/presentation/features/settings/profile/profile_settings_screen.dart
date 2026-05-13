// lib/presentation/features/settings/profile/profile_settings_screen.dart
//
// Profile settings screen (T-183).
//
// Spec references:
//   - UX Flows §9.6: Profile Settings screen
//   - UI Spec §9.6: Components and visual tokens
//
// Single TextField for display name; pre-filled from AppSettingsNotifier.
// "Save" TextButton in AppBar; enabled only when dirty (changed from initial).
// On save, calls AppSettingsNotifier.save(patch) and shows a snackbar.
//
// Test cases (see test/presentation/features/settings/profile/
//             profile_settings_screen_test.dart):
//   1. Name field pre-filled with current displayName (non-empty).
//   2. Name field pre-filled as empty when displayName is null.
//   3. Save button disabled when field is unchanged.
//   4. Save button enabled when field is changed.
//   5. Tapping Save calls save(patch) with correct displayName.
//   6. Snackbar "Profile updated" shown after save.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Settings screen for profile preferences (display name).
///
/// Reads the current [displayName] from [AppSettingsNotifier] and allows the
/// user to edit it. Changes are saved via [AppSettingsNotifier.save] when the
/// user taps the AppBar "Save" button.
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  /// Creates the [ProfileSettingsScreen].
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  /// Controller for the display name text field.
  late final TextEditingController _nameController;

  /// The initial name loaded from settings (used for dirty detection).
  String _initialName = '';

  /// Whether the current field value differs from [_initialName].
  bool get _isDirty => _nameController.text != _initialName;

  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  /// Triggers a rebuild so the Save button enables/disables reactively.
  void _onTextChanged() => setState(() {});

  /// Pre-fills the controller once the settings provider resolves.
  void _maybeInitialize(String? displayName) {
    if (_initialized) return;
    _initialized = true;
    _initialName = displayName ?? '';
    _nameController.text = _initialName;
  }

  /// Saves the display name via [AppSettingsNotifier].
  Future<void> _save() async {
    if (!_isDirty || _saving) return;
    setState(() => _saving = true);

    try {
      await ref.read(appSettingsProvider.notifier).save(
            AppSettingsPatch(displayName: _nameController.text),
          );

      if (!mounted) return;
      _initialName = _nameController.text;
      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } on Exception {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);

    // Pre-fill controller on first data event.
    settingsAsync.whenData((s) => _maybeInitialize(s.displayName));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _isDirty && !_saving ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load profile settings.'),
        ),
        data: (_) => _ProfileBody(controller: _nameController),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The scrollable body of the profile settings screen.
class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.controller});

  /// Controller for the display name field.
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // -------------------------------------------------------------------
        // Display name field
        // -------------------------------------------------------------------
        TextField(
          controller: controller,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Display name (optional)',
            border: OutlineInputBorder(),
            helperText: 'Shown in the greeting on the home screen',
          ),
        ),
        const SizedBox(height: 16),

        // -------------------------------------------------------------------
        // Local-only info row
        // -------------------------------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Stored on-device only. Never uploaded.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
