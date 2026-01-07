import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Displays all Material 3 color roles from the current theme.
///
/// Each color role is shown with its name, a visual swatch, and its hex code.
/// Tapping a color copies its hex code to the clipboard.
class ThemePreviewScreen extends StatelessWidget {
  /// Creates a new instance of [ThemePreviewScreen].
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorRoles = _getColorRoles(colorScheme);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Preview')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: colorRoles.length,
        itemBuilder: (context, index) {
          final role = colorRoles[index];
          return _ColorRoleCard(
            name: role.name,
            color: role.color,
            onColor: role.onColor,
          );
        },
      ),
    );
  }

  /// Returns a list of all Material 3 color roles from the given scheme.
  List<_ColorRole> _getColorRoles(ColorScheme scheme) {
    return [
      _ColorRole('Primary', scheme.primary, scheme.onPrimary),
      _ColorRole('On Primary', scheme.onPrimary, scheme.primary),
      _ColorRole(
        'Primary Container',
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      _ColorRole(
        'On Primary Container',
        scheme.onPrimaryContainer,
        scheme.primaryContainer,
      ),
      _ColorRole('Secondary', scheme.secondary, scheme.onSecondary),
      _ColorRole('On Secondary', scheme.onSecondary, scheme.secondary),
      _ColorRole(
        'Secondary Container',
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      _ColorRole(
        'On Secondary Container',
        scheme.onSecondaryContainer,
        scheme.secondaryContainer,
      ),
      _ColorRole('Tertiary', scheme.tertiary, scheme.onTertiary),
      _ColorRole('On Tertiary', scheme.onTertiary, scheme.tertiary),
      _ColorRole(
        'Tertiary Container',
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      _ColorRole(
        'On Tertiary Container',
        scheme.onTertiaryContainer,
        scheme.tertiaryContainer,
      ),
      _ColorRole('Error', scheme.error, scheme.onError),
      _ColorRole('On Error', scheme.onError, scheme.error),
      _ColorRole(
        'Error Container',
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      _ColorRole(
        'On Error Container',
        scheme.onErrorContainer,
        scheme.errorContainer,
      ),
      _ColorRole('Surface', scheme.surface, scheme.onSurface),
      _ColorRole('On Surface', scheme.onSurface, scheme.surface),
      _ColorRole(
        'Surface Container',
        scheme.surfaceContainer,
        scheme.onSurface,
      ),
      _ColorRole(
        'Surface Container High',
        scheme.surfaceContainerHigh,
        scheme.onSurface,
      ),
      _ColorRole(
        'Surface Container Highest',
        scheme.surfaceContainerHighest,
        scheme.onSurface,
      ),
      _ColorRole(
        'Surface Container Low',
        scheme.surfaceContainerLow,
        scheme.onSurface,
      ),
      _ColorRole(
        'Surface Container Lowest',
        scheme.surfaceContainerLowest,
        scheme.onSurface,
      ),
      _ColorRole('Outline', scheme.outline, scheme.surface),
      _ColorRole('Outline Variant', scheme.outlineVariant, scheme.surface),
    ];
  }
}

/// A data class representing a single color role.
class _ColorRole {
  const _ColorRole(this.name, this.color, this.onColor);
  final String name;
  final Color color;
  final Color onColor;
}

/// A card displaying a single color role with its name and hex code.
class _ColorRoleCard extends StatelessWidget {
  const _ColorRoleCard({
    required this.name,
    required this.color,
    required this.onColor,
  });

  final String name;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final hexCode = _colorToHex(color);

    return Card(
      elevation: 0,
      color: color,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: hexCode));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied $hexCode'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(color: onColor, fontWeight: FontWeight.w500),
              ),
              Text(
                hexCode,
                style: TextStyle(
                  color: onColor.withAlpha(179),
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Converts a Color to a hex string (e.g., "#FF5733").
  String _colorToHex(Color color) {
    // extract RGB components and format as hex
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }
}
