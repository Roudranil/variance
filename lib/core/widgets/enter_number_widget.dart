import 'package:flutter/material.dart';

/// Placeholder widget for numeric input.
///
/// This is a placeholder for a highly customizable numeric input widget that
/// will support calculator mode, currency formatting, and validation.
/// Full implementation specs are in `ideas.md`.
///
/// TODO: Implement full EnterNumberWidget with:
/// - Calculator mode
/// - Currency formatting
/// - Validation rules
/// - Numpad interface
class EnterNumberWidget extends StatelessWidget {
  /// Creates a new instance of [EnterNumberWidget].
  ///
  /// Parameters:
  /// - [value]: The initial value to display.
  /// - [onChanged]: Callback when value changes.
  /// - [label]: Optional label text.
  /// - [prefix]: Optional prefix (e.g., currency symbol).
  /// - [suffix]: Optional suffix.
  const EnterNumberWidget({
    this.value,
    this.onChanged,
    this.label,
    this.prefix,
    this.suffix,
    super.key,
  });

  /// The current value.
  final double? value;

  /// Callback when value changes.
  final ValueChanged<double?>? onChanged;

  /// Optional label text.
  final String? label;

  /// Optional prefix (e.g., currency symbol).
  final String? prefix;

  /// Optional suffix.
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: value?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      style: theme.textTheme.titleLarge,
      onChanged: (text) {
        final parsed = double.tryParse(text);
        onChanged?.call(parsed);
      },
    );
  }
}
