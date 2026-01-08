import 'package:flutter/material.dart';

/// Placeholder widget for text input.
///
/// This is a placeholder for a customizable text input widget that
/// will support validation rules, character limits, and suggestions.
/// Full implementation specs are in `ideas.md`.
///
/// TODO: Implement full EnterTextWidget with:
/// - Validation rules
/// - Character limits
/// - Autocomplete suggestions
class EnterTextWidget extends StatelessWidget {
  /// Creates a new instance of [EnterTextWidget].
  ///
  /// Parameters:
  /// - [value]: The initial value to display.
  /// - [onChanged]: Callback when value changes.
  /// - [label]: Optional label text.
  /// - [hint]: Optional hint text.
  /// - [maxLength]: Optional maximum length.
  const EnterTextWidget({
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.maxLength,
    super.key,
  });

  /// The current value.
  final String? value;

  /// Callback when value changes.
  final ValueChanged<String>? onChanged;

  /// Optional label text.
  final String? label;

  /// Optional hint text.
  final String? hint;

  /// Optional maximum length.
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
