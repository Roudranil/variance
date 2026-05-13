// lib/presentation/features/settings/recurring/pause_duration_dialog.dart
//
// PauseDurationDialog — dialog for selecting pause duration (T-113).
//
// Two modes (UX Flows §9.14.4):
//   1. "N units" mode: integer input + read-only label showing the template's
//      recurrence unit (e.g. "3 months").
//   2. "Custom date" mode: date picker to pick a specific future date.
//
// No indefinite pause option (RECUR-03).
//
// Validation:
//   - N mode: N must be > 0.
//   - Custom date: must be strictly in the future.
//
// Returns a [PauseInput] via [Navigator.pop] when the user confirms.
// Returns null if the user cancels.
//
// Test cases (see test/presentation/features/settings/recurring/
//             pause_duration_dialog_test.dart):
//   1. N=0 submit is disabled.
//   2. N>0 submit enabled.
//   3. Custom date in the past: submit disabled.
//   4. Custom date in the future: submit enabled.
//   5. Cancel returns null.
//   6. Confirm returns PauseInput.byUnits in N mode.
//   7. Confirm returns PauseInput.byDate in custom mode.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/usecases/recurring/pause_recurring_template_use_case.dart';

/// Enumerates the two pause duration input modes.
enum _PauseMode { nUnits, customDate }

/// Dialog that collects a pause duration from the user.
///
/// Pass [templateId] and [recurrenceUnit] so the dialog can show the correct
/// unit label in N-units mode (e.g. "months" for a monthly template).
///
/// Returns a [PauseInput] via [Navigator.pop] on confirm, or null on cancel.
class PauseDurationDialog extends StatefulWidget {
  /// Creates a [PauseDurationDialog].
  ///
  /// Parameters:
  /// - [templateId]: UUID of the template to pause.
  /// - [recurrenceUnit]: The template's time unit for N-units mode label.
  const PauseDurationDialog({
    super.key,
    required this.templateId,
    required this.recurrenceUnit,
  });

  /// UUID of the template to pause.
  final String templateId;

  /// Template's recurrence unit, used for the N-units label.
  final RecurrenceUnit recurrenceUnit;

  @override
  State<PauseDurationDialog> createState() => _PauseDurationDialogState();
}

class _PauseDurationDialogState extends State<PauseDurationDialog> {
  _PauseMode _mode = _PauseMode.nUnits;
  final _nController = TextEditingController(text: '1');
  DateTime? _customDate;

  @override
  void dispose() {
    _nController.dispose();
    super.dispose();
  }

  /// Returns the [PauseInput] from the current state, or null if invalid.
  PauseInput? get _input {
    if (_mode == _PauseMode.nUnits) {
      final n = int.tryParse(_nController.text);
      if (n == null || n <= 0) return null;
      return PauseInput.byUnits(templateId: widget.templateId, durationN: n);
    } else {
      if (_customDate == null) return null;
      if (!_customDate!.isAfter(DateTime.now())) return null;
      return PauseInput.byDate(
        templateId: widget.templateId,
        customDate: _customDate!,
      );
    }
  }

  bool get _canConfirm => _input != null;

  /// Human-readable label for [RecurrenceUnit] in plural.
  String _unitLabel(RecurrenceUnit unit) {
    return switch (unit) {
      RecurrenceUnit.day => 'days',
      RecurrenceUnit.week => 'weeks',
      RecurrenceUnit.month => 'months',
      RecurrenceUnit.year => 'years',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Pause template'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selector.
            SegmentedButton<_PauseMode>(
              segments: const [
                ButtonSegment(
                  value: _PauseMode.nUnits,
                  label: Text('N units'),
                ),
                ButtonSegment(
                  value: _PauseMode.customDate,
                  label: Text('Custom date'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),

            // N-units input.
            if (_mode == _PauseMode.nUnits) ...[
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _nController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'N',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _unitLabel(widget.recurrenceUnit),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Template will resume automatically after N ${_unitLabel(widget.recurrenceUnit)}.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // Custom date input.
            if (_mode == _PauseMode.customDate) ...[
              InkWell(
                onTap: _pickCustomDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Resume date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _customDate != null
                        ? DateFormat.yMMMd().format(_customDate!)
                        : 'Tap to select',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              if (_customDate != null &&
                  !_customDate!.isAfter(DateTime.now())) ...[
                const SizedBox(height: 4),
                Text(
                  'Date must be in the future.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<PauseInput?>(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              _canConfirm ? () => Navigator.of(context).pop(_input) : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _customDate = picked);
    }
  }
}

/// Convenience function to show the [PauseDurationDialog] and return the result.
///
/// Returns [PauseInput] if confirmed, or null if cancelled.
///
/// Parameters:
/// - [context]: Build context for showing the dialog.
/// - [templateId]: UUID of the template to pause.
/// - [recurrenceUnit]: Template's time unit for the N-units label.
Future<PauseInput?> showPauseDurationDialog({
  required BuildContext context,
  required String templateId,
  required RecurrenceUnit recurrenceUnit,
}) {
  return showDialog<PauseInput>(
    context: context,
    builder: (_) => PauseDurationDialog(
      templateId: templateId,
      recurrenceUnit: recurrenceUnit,
    ),
  );
}
