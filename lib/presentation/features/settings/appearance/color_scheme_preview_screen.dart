// lib/presentation/features/settings/appearance/color_scheme_preview_screen.dart
//
// Color Scheme Preview sub-screen — renders Material 3 color token swatches.
//
// Spec references:
//   - UX Flows §9.2.4: Color Scheme Preview Screen
//   - UI Spec §9.2.3: Color Scheme Preview Sub-screen
//
// Displays a 2-column grid of M3 color role swatches derived from the active
// color scheme. Each swatch is labelled with the M3 role name (e.g. "primary",
// "secondary", etc.).
//
// The active color scheme is read directly from the Flutter Theme — no
// additional provider access required; the root DynamicColorBuilder + settings
// already wire the correct scheme into Theme.of(context).
//
// Test cases (see test/widget/features/settings/appearance/
//             color_scheme_preview_screen_test.dart):
//   1. Preview screen renders a swatch for each M3 role label.
//   2. Each swatch tile shows the role name.
//   3. Golden test for the swatch grid layout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

/// A named Material 3 color role shown in the preview grid.
@immutable
class _ColorRole {
  /// Creates a [_ColorRole].
  ///
  /// Parameters:
  /// - [label]: The M3 role name displayed below the swatch.
  /// - [resolve]: Function to extract the [Color] from a [ColorScheme].
  const _ColorRole({required this.label, required this.resolve});

  /// M3 role name label.
  final String label;

  /// Extracts this role's [Color] from [scheme].
  final Color Function(ColorScheme scheme) resolve;
}

/// Ordered list of M3 color roles to display in the preview grid.
const List<_ColorRole> _kRoles = [
  _ColorRole(
    label: 'primary',
    resolve: _primaryOf,
  ),
  _ColorRole(
    label: 'onPrimary',
    resolve: _onPrimaryOf,
  ),
  _ColorRole(
    label: 'primaryContainer',
    resolve: _primaryContainerOf,
  ),
  _ColorRole(
    label: 'onPrimaryContainer',
    resolve: _onPrimaryContainerOf,
  ),
  _ColorRole(
    label: 'secondary',
    resolve: _secondaryOf,
  ),
  _ColorRole(
    label: 'onSecondary',
    resolve: _onSecondaryOf,
  ),
  _ColorRole(
    label: 'secondaryContainer',
    resolve: _secondaryContainerOf,
  ),
  _ColorRole(
    label: 'onSecondaryContainer',
    resolve: _onSecondaryContainerOf,
  ),
  _ColorRole(
    label: 'tertiary',
    resolve: _tertiaryOf,
  ),
  _ColorRole(
    label: 'onTertiary',
    resolve: _onTertiaryOf,
  ),
  _ColorRole(
    label: 'surface',
    resolve: _surfaceOf,
  ),
  _ColorRole(
    label: 'onSurface',
    resolve: _onSurfaceOf,
  ),
  _ColorRole(
    label: 'surfaceVariant',
    resolve: _surfaceContainerOf,
  ),
  _ColorRole(
    label: 'onSurfaceVariant',
    resolve: _onSurfaceVariantOf,
  ),
  _ColorRole(
    label: 'error',
    resolve: _errorOf,
  ),
  _ColorRole(
    label: 'onError',
    resolve: _onErrorOf,
  ),
  _ColorRole(
    label: 'outline',
    resolve: _outlineOf,
  ),
  _ColorRole(
    label: 'outlineVariant',
    resolve: _outlineVariantOf,
  ),
];

// Static top-level resolver functions — used as const function references.
Color _primaryOf(ColorScheme s) => s.primary;
Color _onPrimaryOf(ColorScheme s) => s.onPrimary;
Color _primaryContainerOf(ColorScheme s) => s.primaryContainer;
Color _onPrimaryContainerOf(ColorScheme s) => s.onPrimaryContainer;
Color _secondaryOf(ColorScheme s) => s.secondary;
Color _onSecondaryOf(ColorScheme s) => s.onSecondary;
Color _secondaryContainerOf(ColorScheme s) => s.secondaryContainer;
Color _onSecondaryContainerOf(ColorScheme s) => s.onSecondaryContainer;
Color _tertiaryOf(ColorScheme s) => s.tertiary;
Color _onTertiaryOf(ColorScheme s) => s.onTertiary;
Color _surfaceOf(ColorScheme s) => s.surface;
Color _onSurfaceOf(ColorScheme s) => s.onSurface;
Color _surfaceContainerOf(ColorScheme s) => s.surfaceContainerHighest;
Color _onSurfaceVariantOf(ColorScheme s) => s.onSurfaceVariant;
Color _errorOf(ColorScheme s) => s.error;
Color _onErrorOf(ColorScheme s) => s.onError;
Color _outlineOf(ColorScheme s) => s.outline;
Color _outlineVariantOf(ColorScheme s) => s.outlineVariant;

/// Resolves a human-readable label for the active color scheme mode.
String _modeLabel(ColorSchemeMode mode) => switch (mode) {
      ColorSchemeMode.dynamic => 'Dynamic (wallpaper)',
      ColorSchemeMode.custom => 'Custom seed',
      ColorSchemeMode.catppuccin => 'Catppuccin',
    };

// ---------------------------------------------------------------------------
// ColorSchemePreviewScreen
// ---------------------------------------------------------------------------

/// Sub-screen displaying M3 color token swatches for the active scheme.
///
/// Swatch colors are read from [Theme.of(context).colorScheme] which already
/// reflects the user's chosen mode via the root [DynamicColorBuilder] in
/// [AppRouterWidget]. The active mode label is read from [AppSettingsNotifier].
class ColorSchemePreviewScreen extends ConsumerWidget {
  /// Creates the [ColorSchemePreviewScreen].
  const ColorSchemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appSettingsProvider).value?.colorSchemeMode ??
        ColorSchemeMode.dynamic;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Preview'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active mode label at the top of the grid.
          Text(
            'Active scheme: ${_modeLabel(mode)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            // Disable inner scrolling; the outer ListView handles scroll.
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: _kRoles.length,
            itemBuilder: (context, index) {
              final role = _kRoles[index];
              return _SwatchTile(role: role, colorScheme: colorScheme);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SwatchTile
// ---------------------------------------------------------------------------

/// A single color swatch tile with a filled background and role-name label.
///
/// The label is 11sp per UI Spec §9.2.3 token `label`.
class _SwatchTile extends StatelessWidget {
  const _SwatchTile({required this.role, required this.colorScheme});

  /// The color role to display.
  final _ColorRole role;

  /// The active [ColorScheme] to extract the role color from.
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final color = role.resolve(colorScheme);

    // Use white or black label based on luminance for legibility.
    final labelColor =
        color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        role.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: labelColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
