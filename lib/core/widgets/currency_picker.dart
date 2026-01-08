import 'package:flutter/material.dart';

import 'package:variance/core/utils/logger.dart';

/// Data model for a supported currency.
///
/// Contains the ISO 4217 code, icon, and display name for a currency.
class CurrencyData {
  /// The ISO 4217 currency code (e.g., 'USD', 'INR').
  final String code;

  /// The currency icon (e.g., [Icons.attach_money], [Icons.currency_rupee]).
  final IconData icon;

  /// The display name of the currency (e.g., 'US Dollar').
  final String name;

  /// Creates a new instance of [CurrencyData].
  const CurrencyData({
    required this.code,
    required this.icon,
    required this.name,
  });

  /// The curated list of 9 supported currencies.
  ///
  /// Arranged in a 3x3 grid order:
  /// Row 1: USD, INR, EUR
  /// Row 2: GBP, JPY, AUD
  /// Row 3: CAD, CNY, KRW
  static const List<CurrencyData> supported = [
    CurrencyData(code: 'USD', icon: Icons.attach_money, name: 'US Dollar'),
    CurrencyData(code: 'INR', icon: Icons.currency_rupee, name: 'Indian Rupee'),
    CurrencyData(code: 'EUR', icon: Icons.euro, name: 'Euro'),
    CurrencyData(
      code: 'GBP',
      icon: Icons.currency_pound,
      name: 'British Pound',
    ),
    CurrencyData(code: 'JPY', icon: Icons.currency_yen, name: 'Japanese Yen'),
    CurrencyData(
      code: 'AUD',
      icon: Icons.attach_money,
      name: 'Australian Dollar',
    ),
    CurrencyData(
      code: 'CAD',
      icon: Icons.attach_money,
      name: 'Canadian Dollar',
    ),
    CurrencyData(code: 'CNY', icon: Icons.currency_yuan, name: 'Chinese Yuan'),
    CurrencyData(
      code: 'KRW',
      icon: Icons.attach_money,
      name: 'South Korean Won',
    ),
  ];

  /// Finds a currency by its code.
  ///
  /// Returns null if the code is not in the supported list.
  static CurrencyData? byCode(String code) {
    try {
      return supported.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}

/// A modal bottom sheet for selecting a currency from a 3x3 grid.
///
/// Displays the 9 supported currencies in a grid layout. Each tile shows
/// the currency icon, code, and name. The currently selected currency
/// is highlighted with a primary container background and border.
class CurrencyPickerSheet extends StatelessWidget {
  /// Creates a new instance of [CurrencyPickerSheet].
  ///
  /// Parameters:
  /// - [selectedCode]: The currently selected currency code.
  /// - [colorScheme]: Optional color scheme to use for styling. If null, the
  ///   context's color scheme will be used.
  const CurrencyPickerSheet({
    required this.selectedCode,
    this.colorScheme,
    super.key,
  });

  /// The currently selected currency code.
  final String selectedCode;

  /// Optional color scheme to override the default context theme.
  final ColorScheme? colorScheme;

  /// Shows the currency picker as a modal bottom sheet.
  ///
  /// Returns the selected currency code, or null if dismissed.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [currentCode]: The currently selected currency code.
  /// - [colorScheme]: Optional color scheme to theme the picker.
  static Future<String?> show(
    BuildContext context,
    String currentCode, {
    ColorScheme? colorScheme,
  }) {
    VarianceLogger.debug(
      'CurrencyPickerSheet: showing with current=$currentCode',
    );
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CurrencyPickerSheet(
        selectedCode: currentCode,
        colorScheme: colorScheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use provided colorScheme or fall back to the active theme's scheme.
    final effectiveColorScheme = colorScheme ?? Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Text('Select Currency', style: textTheme.titleLarge),
              const SizedBox(height: 16),

              // 3x3 grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                physics: const NeverScrollableScrollPhysics(),
                children: CurrencyData.supported.map((currency) {
                  final isSelected = currency.code == selectedCode;
                  return _CurrencyTile(
                    currency: currency,
                    isSelected: isSelected,
                    colorScheme: effectiveColorScheme,
                    textTheme: textTheme,
                    onTap: () {
                      VarianceLogger.info(
                        'CurrencyPickerSheet: selected ${currency.code}',
                      );
                      Navigator.pop(context, currency.code);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single currency tile in the picker grid.
class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.currency,
    required this.isSelected,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final CurrencyData currency;
  final bool isSelected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 3)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // symbol and code row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    currency.icon,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currency.code,
                    style: textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // country name
              Text(
                currency.name,
                style: textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer.withAlpha(179)
                      : colorScheme.onSurfaceVariant.withAlpha(179),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
