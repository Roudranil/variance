import 'package:flutter/material.dart';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:provider/provider.dart';

import 'package:variance/core/preferences/settings_provider.dart';
import 'package:variance/core/utils/logger.dart';
import 'package:variance/features/settings/screens/theme_preview_screen.dart';
import 'package:variance/features/settings/widgets/settings_card.dart';

/// The Settings screen.
///
/// Allows the user to configure app preferences including theme, colors,
/// currency, and locale. Settings are organized into Material 3 filled cards.
class SettingsScreen extends StatelessWidget {
  /// Creates a new instance of [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: "OldStandardTT"),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildAppearanceCard(context, settings),
                _buildRegionalCard(context, settings),
                _buildDataManagementCard(context),
                _buildAboutCard(context),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the Appearance settings card.
  Widget _buildAppearanceCard(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    final divider = Divider(height: 8, color: theme.colorScheme.surface);
    return SettingsCard(
      title: 'Appearance',
      children: [
        // theme mode selector
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: const Text('Theme'),
          subtitle: Text(_themeModeLabel(settings.themeMode)),
          trailing: _buildThemeModeSelector(context, settings),
          visualDensity: VisualDensity.compact,
        ),
        divider,
        // dynamic color toggle
        SwitchListTile(
          secondary: const Icon(Icons.auto_fix_high_outlined),
          title: const Text('Dynamic Color'),
          subtitle: const Text('Use colors from your wallpaper'),
          value: settings.useDynamicColor,
          onChanged: (value) => settings.toggleDynamicColor(value),
          visualDensity: VisualDensity.compact,
        ),
        divider,
        // accent color picker
        ListTile(
          leading: const Icon(Icons.color_lens_outlined),
          title: const Text('Accent Color'),
          subtitle: Text(
            settings.useDynamicColor
                ? 'Dynamic color is enabled'
                : 'Tap to choose a color',
          ),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: settings.accentColor ?? theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.outline, width: 2),
            ),
          ),
          onTap: () => _showAccentColorPicker(context, settings),
          visualDensity: VisualDensity.compact,
        ),
        divider,
        // palette preview
        ListTile(
          leading: const Icon(Icons.auto_awesome_mosaic_outlined),
          title: const Text('Theme Preview'),
          subtitle: const Text('View all color roles'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ThemePreviewScreen(),
              ),
            );
          },
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  /// Builds the Regional settings card.
  Widget _buildRegionalCard(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);
    final divider = Divider(height: 8, color: theme.colorScheme.surface);
    return SettingsCard(
      title: 'Regional',
      children: [
        // currency picker
        ListTile(
          leading: const Icon(Icons.attach_money_outlined),
          title: const Text('Currency'),
          subtitle: Text(settings.currencyCode),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCurrencyPicker(context, settings),
          visualDensity: VisualDensity.compact,
        ),
        divider,
        // locale picker
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: const Text('Locale'),
          subtitle: Text(_localeLabel(settings.locale)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLocalePicker(context, settings),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  /// Builds the Data Management settings card (Phase 3 placeholders).
  Widget _buildDataManagementCard(BuildContext context) {
    final theme = Theme.of(context);
    final divider = Divider(height: 8, color: theme.colorScheme.surface);
    return SettingsCard(
      title: 'Data Management',
      children: [
        ListTile(
          leading: const Icon(Icons.account_balance_outlined),
          title: const Text('Accounts'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoon(context),
          visualDensity: VisualDensity.compact,
        ),
        divider,
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: const Text('Categories'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoon(context),
          visualDensity: VisualDensity.compact,
        ),
        divider,
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Backup & Restore'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoon(context),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  /// Builds the About settings card.
  Widget _buildAboutCard(BuildContext context) {
    final theme = Theme.of(context);
    final divider = Divider(height: 8, color: theme.colorScheme.surface);
    return SettingsCard(
      title: 'About',
      children: [
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: const Text('Acknowledgements'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoon(context),
          visualDensity: VisualDensity.compact,
        ),
        divider,
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Open Source Licenses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: 'Variance',
              applicationVersion: '1.0.0',
            );
          },
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  /// Builds the segmented button for theme mode selection.
  Widget _buildThemeModeSelector(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.brightness_auto, size: 18),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode, size: 18),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode, size: 18),
        ),
      ],
      selected: {settings.themeMode},
      onSelectionChanged: (selection) {
        settings.setThemeMode(selection.first);
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  /// Shows the accent color picker bottom sheet.
  void _showAccentColorPicker(BuildContext context, SettingsProvider settings) {
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header with dynamic color status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: settings.useDynamicColor
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      settings.useDynamicColor
                          ? Icons.auto_awesome
                          : Icons.color_lens,
                      color: settings.useDynamicColor
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        settings.useDynamicColor
                            ? 'Dynamic color is enabled. Your wallpaper colors are being used.'
                            : 'Select an accent color for your app theme.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: settings.useDynamicColor
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // catppuccin color grid
              _buildCatppuccinColorGrid(context, settings),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Shows the currency picker dialog.
  void _showCurrencyPicker(BuildContext context, SettingsProvider settings) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (currency) {
        settings.setCurrencyCode(currency.code);
        VarianceLogger.info('Currency selected: ${currency.code}');
      },
    );
  }

  /// Shows the locale picker dialog.
  void _showLocalePicker(BuildContext context, SettingsProvider settings) {
    // hardcoded list for MVP
    const locales = [
      ('en_IN', 'English (India)'),
      ('en_US', 'English (United States)'),
      ('en_GB', 'English (United Kingdom)'),
    ];

    showDialog<void>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Locale'),
          children: locales.map((locale) {
            final (code, name) = locale;
            return RadioListTile<String>(
              title: Text(name),
              value: code,
              groupValue: settings.locale,
              onChanged: (value) {
                if (value != null) {
                  settings.setLocale(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// Shows a "Coming Soon" snackbar.
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!', textAlign: TextAlign.center),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        width: 160,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  /// Returns a human-readable label for the given theme mode.
  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  /// Returns a human-readable label for the given locale.
  String _localeLabel(String locale) {
    return switch (locale) {
      'en_IN' => 'English (India)',
      'en_US' => 'English (United States)',
      'en_GB' => 'English (United Kingdom)',
      _ => locale,
    };
  }

  /// Builds a grid of Catppuccin palette colors for accent selection.
  Widget _buildCatppuccinColorGrid(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final flavor = brightness == Brightness.light
        ? catppuccin.latte
        : catppuccin.mocha;

    // catppuccin palette colors with their names
    final colors = [
      ('Rosewater', flavor.rosewater),
      ('Flamingo', flavor.flamingo),
      ('Pink', flavor.pink),
      ('Mauve', flavor.mauve),
      ('Red', flavor.red),
      ('Maroon', flavor.maroon),
      ('Peach', flavor.peach),
      ('Yellow', flavor.yellow),
      ('Green', flavor.green),
      ('Teal', flavor.teal),
      ('Sky', flavor.sky),
      ('Sapphire', flavor.sapphire),
      ('Blue', flavor.blue),
      ('Lavender', flavor.lavender),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Catppuccin Palette', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final (name, color) = colors[index];
            final isSelected = settings.accentColor == color;

            return Tooltip(
              message: name,
              child: InkWell(
                onTap: () {
                  settings.setAccentColor(color);
                  VarianceLogger.info('Accent color selected: $name');
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 3,
                          )
                        : Border.all(
                            color: theme.colorScheme.outline.withAlpha(77),
                            width: 1,
                          ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: _contrastColor(color),
                          size: 20,
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Returns black or white depending on the luminance of the given color.
  Color _contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
