// lib/presentation/features/settings/appearance/appearance_settings_screen.dart
//
// Appearance settings screen — controls theme, color scheme, seed color,
// animations, and navigation to the color preview sub-screen.
//
// Spec references:
//   - UX Flows §9.2: Appearance Settings screen states and controls
//   - UI Spec §9.2: Components and visual tokens
//   - SDS §2.18: Theming Architecture (Dynamic / Custom / Catppuccin modes)
//
// All control changes write immediately to AppSettingsNotifier.save(patch)
// and are reflected in the app theme via the reactive INFRA-5 wiring in
// AppRouterWidget.
//
// Test cases (see test/widget/features/settings/appearance/
//             appearance_settings_screen_test.dart):
//   1. Theme segmented button shows correct selected segment for each
//      AppTheme value and writes the correct patch on selection.
//   2. Color scheme segmented button shows correct selection and writes patch.
//   3. Seed color picker row is visible only when colorSchemeMode == custom.
//   4. Animations toggle reflects settings value and writes patch on toggle.
//   5. Preview row tap navigates to /settings/appearance/preview.
//   6. Dynamic unavailable banner is shown when DynamicColorBuilder returns
//      null and colorSchemeMode == dynamic (handled by parent DynamicColorBuilder).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Settings screen for all appearance-related preferences.
///
/// Reads current values from [AppSettingsNotifier] and writes patches back on
/// each user interaction. Changes are applied immediately via reactive theme
/// rebuild in [AppRouterWidget].
class AppearanceSettingsScreen extends ConsumerWidget {
  /// Creates the [AppearanceSettingsScreen].
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load appearance settings.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        data: (settings) => _AppearanceBody(settings: settings),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Appearance body — renders all controls
// ---------------------------------------------------------------------------

/// The scrollable body of the appearance settings screen.
///
/// Separated from [AppearanceSettingsScreen] to keep [ConsumerWidget.build]
/// concise and allow const propagation for the loaded branch.
class _AppearanceBody extends ConsumerWidget {
  const _AppearanceBody({required this.settings});

  /// The current [AppSettings] to pre-fill controls.
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // -------------------------------------------------------------------
        // Theme section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Theme'),
        _ThemeSegmentedRow(currentTheme: settings.theme, ref: ref),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Color scheme section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Color Scheme'),
        _ColorSchemeSegmentedRow(
          currentMode: settings.colorSchemeMode,
          ref: ref,
        ),
        // Dynamic unavailable note — shown when dynamic mode is selected but
        // DynamicColorBuilder yields null. This widget reads the flag passed
        // down from the DynamicColorBuilder via DynamicColorAvailability.
        const _DynamicUnavailableNote(),
        // Seed color picker — visible only when color scheme = Custom.
        if (settings.colorSchemeMode == ColorSchemeMode.custom)
          _SeedColorRow(currentSeed: settings.colorSeed, ref: ref),
        // Catppuccin note — shown when color scheme = Catppuccin.
        if (settings.colorSchemeMode == ColorSchemeMode.catppuccin)
          const _CatppuccinFlavorNote(),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Animations section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Animations'),
        _AnimationsToggleRow(
          animationsEnabled: settings.animationsEnabled,
          ref: ref,
        ),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Preview row
        // -------------------------------------------------------------------
        ListTile(
          leading: Icon(
            Icons.color_lens_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: const Text('Preview color scheme'),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: () => context.push(AppRoutes.settingsAppearancePreview),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

/// A section-group header label.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  /// Section label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
// Theme segmented button row
// ---------------------------------------------------------------------------

/// Row with [SegmentedButton] for Light / Dark / System theme selection.
///
/// Writes [AppSettingsPatch] with updated [AppTheme] on segment change.
class _ThemeSegmentedRow extends StatelessWidget {
  const _ThemeSegmentedRow({
    required this.currentTheme,
    required this.ref,
  });

  /// Current theme setting.
  final AppTheme currentTheme;

  /// Riverpod widget ref for calling [AppSettingsNotifier.save].
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<AppTheme>(
              segments: const [
                ButtonSegment(
                  value: AppTheme.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: AppTheme.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: AppTheme.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
              ],
              selected: {currentTheme},
              onSelectionChanged: (selection) => _onThemeChanged(
                selection.first,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onThemeChanged(AppTheme theme) async {
    await ref.read(appSettingsProvider.notifier).save(
          AppSettingsPatch(theme: theme),
        );
  }
}

// ---------------------------------------------------------------------------
// Color scheme segmented button row
// ---------------------------------------------------------------------------

/// Row with [SegmentedButton] for Dynamic / Custom / Catppuccin color scheme.
///
/// Writes [AppSettingsPatch] with updated [ColorSchemeMode] on segment change.
class _ColorSchemeSegmentedRow extends StatelessWidget {
  const _ColorSchemeSegmentedRow({
    required this.currentMode,
    required this.ref,
  });

  /// Current color scheme mode.
  final ColorSchemeMode currentMode;

  /// Riverpod widget ref for calling [AppSettingsNotifier.save].
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<ColorSchemeMode>(
              segments: const [
                ButtonSegment(
                  value: ColorSchemeMode.dynamic,
                  label: Text('Dynamic'),
                  icon: Icon(Icons.auto_awesome_outlined),
                ),
                ButtonSegment(
                  value: ColorSchemeMode.custom,
                  label: Text('Custom'),
                  icon: Icon(Icons.colorize_outlined),
                ),
                ButtonSegment(
                  value: ColorSchemeMode.catppuccin,
                  label: Text('Catppuccin'),
                  icon: Icon(Icons.coffee_outlined),
                ),
              ],
              selected: {currentMode},
              onSelectionChanged: (selection) =>
                  _onModeChanged(selection.first),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onModeChanged(ColorSchemeMode mode) async {
    await ref.read(appSettingsProvider.notifier).save(
          AppSettingsPatch(colorSchemeMode: mode),
        );
  }
}

// ---------------------------------------------------------------------------
// Dynamic unavailable note
// ---------------------------------------------------------------------------

/// Inline info card shown when dynamic color is unavailable on this device.
///
/// The parent [AppearanceSettingsScreen] receives dynamic color availability
/// from [DynamicColorAvailability] inherited widget set by [AppRouterWidget].
/// When dynamic mode is selected but OEM extraction is not available,
/// this note is displayed.
///
/// Visibility is controlled by [DynamicColorAvailability.of(context)].
class _DynamicUnavailableNote extends StatelessWidget {
  /// Creates the [_DynamicUnavailableNote].
  const _DynamicUnavailableNote();

  @override
  Widget build(BuildContext context) {
    final available = DynamicColorAvailability.of(context);
    if (available) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dynamic color not available on this device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
// DynamicColorAvailability inherited widget
// ---------------------------------------------------------------------------

/// Inherited widget that propagates dynamic color availability down the tree.
///
/// [AppRouterWidget] wraps its child with this widget after reading the
/// [DynamicColorBuilder] result. Screens that need to show the
/// "Dynamic color not available" note read this value via
/// [DynamicColorAvailability.of(context)].
class DynamicColorAvailability extends InheritedWidget {
  /// Creates a [DynamicColorAvailability] node.
  ///
  /// Parameters:
  /// - [available]: Whether OEM dynamic color extraction succeeded.
  /// - [child]: The subtree to wrap.
  const DynamicColorAvailability({
    super.key,
    required this.available,
    required super.child,
  });

  /// Whether the device supports wallpaper-based color extraction.
  final bool available;

  /// Returns the nearest [DynamicColorAvailability.available] value.
  ///
  /// Defaults to `true` when no ancestor node is found (assume available
  /// so the banner is hidden unless explicitly propagated).
  static bool of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<DynamicColorAvailability>();
    return result?.available ?? true;
  }

  @override
  bool updateShouldNotify(DynamicColorAvailability oldWidget) =>
      available != oldWidget.available;
}

// ---------------------------------------------------------------------------
// Catppuccin flavor note
// ---------------------------------------------------------------------------

/// Informational note shown when Catppuccin color scheme is selected.
///
/// Explains the automatic flavor binding (Light→Latte, Dark→Mocha) per
/// UI Spec §9.2.1 and UX Flows §9.2.2.
class _CatppuccinFlavorNote extends StatelessWidget {
  const _CatppuccinFlavorNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        'Auto-bound to theme: Light → Latte, Dark → Mocha',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seed color picker row
// ---------------------------------------------------------------------------

/// Settings row that shows the current custom seed color.
///
/// Tapping opens a [showDialog] with a simple color picker (color swatch
/// options). Writes the chosen hex color to [AppSettingsNotifier].
///
/// Visible only when [ColorSchemeMode.custom] is active.
class _SeedColorRow extends StatelessWidget {
  const _SeedColorRow({
    required this.currentSeed,
    required this.ref,
  });

  /// Current hex seed color string (e.g. '#6750A4'), or null.
  final String? currentSeed;

  /// Riverpod widget ref for calling [AppSettingsNotifier.save].
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(currentSeed) ?? const Color(0xFF6750A4);
    return ListTile(
      leading: Icon(
        Icons.colorize_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Seed color'),
      trailing: _ColorSwatch(color: color),
      onTap: () => _showColorPicker(context),
    );
  }

  Future<void> _showColorPicker(BuildContext context) async {
    final chosen = await showDialog<Color>(
      context: context,
      builder: (_) =>
          _SeedColorPickerDialog(currentColor: _parseColor(currentSeed)),
    );
    if (chosen != null) {
      // Convert Color to hex string via toARGB32 (Color.value is deprecated).
      final argb = chosen.toARGB32();
      final hex = '#${argb.toRadixString(16).substring(2).toUpperCase()}';
      await ref.read(appSettingsProvider.notifier).save(
            AppSettingsPatch(colorSeed: hex),
          );
    }
  }

  /// Parses a hex string (e.g. '#6750A4') to a [Color].
  ///
  /// Returns null when [hex] is null or cannot be parsed.
  static Color? _parseColor(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceFirst('#', '');
    final argb = int.tryParse('FF$cleaned', radix: 16);
    return argb != null ? Color(argb) : null;
  }
}

// ---------------------------------------------------------------------------
// Color swatch indicator
// ---------------------------------------------------------------------------

/// A 44×44 dp filled circle displaying [color] with a border.
///
/// Used as the trailing widget of the seed color row per UI Spec §9.2.1.
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});

  /// The color to display.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seed color picker dialog
// ---------------------------------------------------------------------------

/// A simple dialog offering a palette of preset seed colors.
///
/// Tapping a color circle closes the dialog and returns the chosen [Color].
class _SeedColorPickerDialog extends StatelessWidget {
  const _SeedColorPickerDialog({this.currentColor});

  /// The currently active color, highlighted with a check mark.
  final Color? currentColor;

  /// Preset seed color options.
  static const List<Color> _kPresets = [
    Color(0xFF6750A4), // M3 baseline purple
    Color(0xFF006874), // teal
    Color(0xFF8B4000), // brown
    Color(0xFF006E2C), // green
    Color(0xFFC00033), // red
    Color(0xFF004BA1), // blue
    Color(0xFF80009E), // violet
    Color(0xFF005E73), // cyan
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose seed color'),
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _kPresets
            .map(
              (color) => GestureDetector(
                onTap: () => Navigator.of(context).pop(color),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _ColorSwatch(color: color),
                    if (currentColor?.toARGB32() == color.toARGB32())
                      const Icon(Icons.check, color: Colors.white, size: 20),
                  ],
                ),
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Animations toggle row
// ---------------------------------------------------------------------------

/// Settings row with a [Switch] to enable/disable in-app animations.
///
/// Writes [AppSettingsPatch] with updated [animationsEnabled] on toggle.
class _AnimationsToggleRow extends StatelessWidget {
  const _AnimationsToggleRow({
    required this.animationsEnabled,
    required this.ref,
  });

  /// Current animations enabled state.
  final bool animationsEnabled;

  /// Riverpod widget ref for calling [AppSettingsNotifier.save].
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(
        Icons.animation_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: const Text('Animations'),
      subtitle: const Text('Enable in-app transitions and animations'),
      value: animationsEnabled,
      onChanged: (value) async {
        await ref.read(appSettingsProvider.notifier).save(
              AppSettingsPatch(animationsEnabled: value),
            );
      },
    );
  }
}
