// lib/presentation/features/settings/locale/locale_format_settings_screen.dart
//
// Locale & Format settings screen (T-177).
//
// Spec references:
//   - UX Flows §9.3: Locale & Format Settings screen states and controls
//   - UI Spec §9.3: Components and visual tokens
//
// All control changes write immediately via AppSettingsNotifier.save(patch).
// A live format preview card at the bottom reflects changes immediately.
//
// Test cases (see test/presentation/features/settings/locale/
//             locale_format_settings_screen_test.dart):
//   1. Home currency row shows current currency code and navigates to /settings/currency.
//   2. Decimal separator segmented button writes correct patch on selection.
//   3. Thousands grouping segmented button writes correct patch on selection.
//   4. Symbol placement segmented button writes correct patch on selection.
//   5. Symbol spacing segmented button writes correct patch on selection.
//   6. Week start segmented button writes correct patch on selection.
//   7. Time format segmented button writes correct patch on selection.
//   8. Percentage precision dropdown writes correct patch on selection.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/presentation/navigation/app_router.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';

/// Settings screen for all locale and number-format preferences.
///
/// Reads current values from [AppSettingsNotifier] and writes patches back on
/// each user interaction. A format preview card at the bottom shows a
/// live-formatted sample amount and date using the current settings.
class LocaleFormatSettingsScreen extends ConsumerWidget {
  /// Creates the [LocaleFormatSettingsScreen].
  const LocaleFormatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locale & Format'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Failed to load locale settings.'),
        ),
        data: (settings) => _LocaleBody(settings: settings),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The scrollable body of the locale settings screen.
class _LocaleBody extends ConsumerWidget {
  const _LocaleBody({required this.settings});

  /// The current [AppSettings] to pre-fill all controls.
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // -------------------------------------------------------------------
        // Currency section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Currency'),
        _HomeCurrencyRow(homeCurrency: settings.homeCurrency),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Number format section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Number Format'),
        _SegmentedRow<DecimalSeparator>(
          title: 'Decimal separator',
          value: settings.numberDecimalSeparator,
          segments: const [
            ButtonSegment(
              value: DecimalSeparator.comma,
              label: Text('Comma ( , )'),
            ),
            ButtonSegment(
              value: DecimalSeparator.period,
              label: Text('Period ( . )'),
            ),
          ],
          onChanged: (v) => _save(ref, patch: AppSettingsPatch(numberDecimalSeparator: v)),
        ),
        _SegmentedRow<ThousandsGrouping>(
          title: 'Thousands grouping',
          value: settings.numberThousandsGrouping,
          segments: const [
            ButtonSegment(
              value: ThousandsGrouping.standard,
              label: Text('Standard'),
            ),
            ButtonSegment(
              value: ThousandsGrouping.indian,
              label: Text('Indian'),
            ),
          ],
          onChanged: (v) => _save(ref, patch: AppSettingsPatch(numberThousandsGrouping: v)),
        ),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Currency symbol section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Currency Symbol'),
        _SegmentedRow<CurrencySymbolPlacement>(
          title: 'Placement',
          value: settings.currencySymbolPlacement,
          segments: const [
            ButtonSegment(
              value: CurrencySymbolPlacement.prefix,
              label: Text('Prefix'),
            ),
            ButtonSegment(
              value: CurrencySymbolPlacement.suffix,
              label: Text('Suffix'),
            ),
          ],
          onChanged: (v) =>
              _save(ref, patch: AppSettingsPatch(currencySymbolPlacement: v)),
        ),
        _SegmentedRow<CurrencySymbolSpacing>(
          title: 'Spacing',
          value: settings.currencySymbolSpacing,
          segments: const [
            ButtonSegment(
              value: CurrencySymbolSpacing.none,
              label: Text('None'),
            ),
            ButtonSegment(
              value: CurrencySymbolSpacing.space,
              label: Text('Space'),
            ),
          ],
          onChanged: (v) =>
              _save(ref, patch: AppSettingsPatch(currencySymbolSpacing: v)),
        ),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Date & time section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Date & Time'),
        _SegmentedRow<WeekStart>(
          title: 'Week starts on',
          value: settings.weekStart,
          segments: const [
            ButtonSegment(
              value: WeekStart.monday,
              label: Text('Mon'),
            ),
            ButtonSegment(
              value: WeekStart.sunday,
              label: Text('Sun'),
            ),
          ],
          onChanged: (v) => _save(ref, patch: AppSettingsPatch(weekStart: v)),
        ),
        _SegmentedRow<TimeFormat>(
          title: 'Time format',
          value: settings.timeFormat,
          segments: const [
            ButtonSegment(
              value: TimeFormat.h12,
              label: Text('12h'),
            ),
            ButtonSegment(
              value: TimeFormat.h24,
              label: Text('24h'),
            ),
          ],
          onChanged: (v) => _save(ref, patch: AppSettingsPatch(timeFormat: v)),
        ),
        const Divider(indent: 16, endIndent: 16),

        // -------------------------------------------------------------------
        // Precision section
        // -------------------------------------------------------------------
        const _SectionHeader(label: 'Precision'),
        _PercentagePrecisionRow(precision: settings.percentagePrecision),

        const SizedBox(height: 16),

        // -------------------------------------------------------------------
        // Format preview card
        // -------------------------------------------------------------------
        _FormatPreviewCard(settings: settings),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Saves [patch] via [AppSettingsNotifier].
  void _save(WidgetRef ref, {required AppSettingsPatch patch}) {
    ref.read(appSettingsProvider.notifier).save(patch);
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

/// A section-group header displayed above a group of locale settings rows.
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
// Home currency row
// ---------------------------------------------------------------------------

/// A [ListTile] row that displays the current home currency and navigates to
/// /settings/currency for selection.
class _HomeCurrencyRow extends StatelessWidget {
  const _HomeCurrencyRow({required this.homeCurrency});

  /// ISO 4217 code of the current home currency.
  final String homeCurrency;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      title: const Text('Home currency'),
      subtitle: const Text('Used for category thresholds and net worth'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            homeCurrency,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
      onTap: () => context.push(AppRoutes.settingsCurrency),
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented control row
// ---------------------------------------------------------------------------

/// A [ListTile] with a [SegmentedButton] trailing for enum preferences.
///
/// The label shows [title]; the segmented button reflects [value] and calls
/// [onChanged] with the newly selected enum value.
class _SegmentedRow<T> extends StatelessWidget {
  const _SegmentedRow({
    required this.title,
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  /// Row label.
  final String title;

  /// Currently selected enum value; null means no selection.
  final T? value;

  /// Available segments.
  final List<ButtonSegment<T>> segments;

  /// Called when the user changes the selection.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: SegmentedButton<T>(
        segments: segments,
        selected: value != null ? {value as T} : {},
        emptySelectionAllowed: true,
        onSelectionChanged: (selected) {
          if (selected.isNotEmpty) onChanged(selected.first);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Percentage precision dropdown row
// ---------------------------------------------------------------------------

/// A [ListTile] with a [DropdownButton] trailing for percentage precision (0/1/2).
class _PercentagePrecisionRow extends ConsumerWidget {
  const _PercentagePrecisionRow({required this.precision});

  /// Current percentage precision value (0, 1, or 2).
  final int precision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text('Percentage decimal places'),
      trailing: DropdownButton<int>(
        value: precision,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 0, child: Text('0')),
          DropdownMenuItem(value: 1, child: Text('1')),
          DropdownMenuItem(value: 2, child: Text('2')),
        ],
        onChanged: (v) {
          if (v == null) return;
          ref.read(appSettingsProvider.notifier).save(
                AppSettingsPatch(percentagePrecision: v),
              );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Format preview card
// ---------------------------------------------------------------------------

/// A [Card] that shows a live-formatted sample amount and date using the
/// current locale settings.
///
/// Updates reactively whenever the user changes any locale preference.
class _FormatPreviewCard extends StatelessWidget {
  const _FormatPreviewCard({required this.settings});

  /// Current settings used for the preview.
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sampleAmount = _formatSampleAmount(settings);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Format preview',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                sampleAmount,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats a sample amount of 1234567.89 using current settings.
  String _formatSampleAmount(AppSettings s) {
    final decSep = switch (s.numberDecimalSeparator) {
      DecimalSeparator.comma => ',',
      DecimalSeparator.period || null => '.',
    };

    // Use locale-agnostic manual formatting.
    final intPart = _formatIntegerPart(12345, s.numberThousandsGrouping);
    final symbol = s.homeCurrency;
    final amount = '$intPart${decSep}67';

    final placement = s.currencySymbolPlacement;
    final spacing = s.currencySymbolSpacing;
    final space = spacing == CurrencySymbolSpacing.space ? ' ' : '';

    return switch (placement) {
      CurrencySymbolPlacement.prefix || null => '$symbol$space$amount',
      CurrencySymbolPlacement.suffix => '$amount$space$symbol',
    };
  }

  /// Formats [value] integer with thousands separators.
  String _formatIntegerPart(int value, ThousandsGrouping? grouping) {
    final str = value.toString();
    if (grouping == null) return str;
    return switch (grouping) {
      ThousandsGrouping.standard => _applyStandardGrouping(str),
      ThousandsGrouping.indian => _applyIndianGrouping(str),
    };
  }

  /// Applies standard 3-digit thousands grouping (e.g. 12,345).
  String _applyStandardGrouping(String digits) {
    final buf = StringBuffer();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(',');
      buf.write(digits[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  /// Applies Indian grouping (e.g. 12,345 → first comma at 3, then 2).
  String _applyIndianGrouping(String digits) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final buf = StringBuffer();
    var count = 0;
    for (var i = rest.length - 1; i >= 0; i--) {
      if (count > 0 && count % 2 == 0) buf.write(',');
      buf.write(rest[i]);
      count++;
    }
    final formattedRest = buf.toString().split('').reversed.join();
    return '$formattedRest,$last3';
  }
}
