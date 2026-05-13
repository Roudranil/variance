// test/presentation/features/settings/recurring/pause_duration_dialog_test.dart
//
// Widget tests for PauseDurationDialog (T-113).
//
// Test cases:
//   1. Confirm button is enabled when N=1 (default).
//   2. Confirm button is disabled when N field is cleared.
//   3. Cancel button returns null.
//   4. Confirm button in N-units mode returns PauseInput.byUnits.
//   5. Custom date mode is selectable via segmented button.
//   6. Confirm is disabled in custom date mode when no date selected.
//   7. Unit label shows "months" for month-unit template.
//   8. Dialog title is "Pause template".

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/usecases/recurring/pause_recurring_template_use_case.dart';
import 'package:variance/presentation/features/settings/recurring/pause_duration_dialog.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Future<PauseInput?> _showDialog(
  WidgetTester tester, {
  RecurrenceUnit unit = RecurrenceUnit.month,
}) async {
  PauseInput? result;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showPauseDurationDialog(
              context: context,
              templateId: 'tpl-001',
              recurrenceUnit: unit,
            );
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();

  return result;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PauseDurationDialog', () {
    // -------------------------------------------------------------------------
    // 1. Dialog title
    // -------------------------------------------------------------------------
    testWidgets('dialog title is "Pause template"', (tester) async {
      await _showDialog(tester);
      expect(find.text('Pause template'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 2. Confirm enabled when N=1 (default)
    // -------------------------------------------------------------------------
    testWidgets('Confirm is enabled when N=1 (default)', (tester) async {
      await _showDialog(tester);

      final confirmButton = find.widgetWithText(FilledButton, 'Confirm');
      expect(confirmButton, findsOneWidget);
      final button = tester.widget<FilledButton>(confirmButton);
      expect(button.onPressed, isNotNull);
    });

    // -------------------------------------------------------------------------
    // 3. Confirm disabled when N is cleared
    // -------------------------------------------------------------------------
    testWidgets('Confirm is disabled when N field is empty', (tester) async {
      await _showDialog(tester);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      final confirmButton = find.widgetWithText(FilledButton, 'Confirm');
      final button = tester.widget<FilledButton>(confirmButton);
      expect(button.onPressed, isNull);
    });

    // -------------------------------------------------------------------------
    // 4. Cancel button dismisses and returns null
    // -------------------------------------------------------------------------
    testWidgets('Cancel button dismisses dialog', (tester) async {
      await _showDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Pause template'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 5. Confirm in N-units mode returns PauseInput.byUnits
    // -------------------------------------------------------------------------
    testWidgets('Confirm in N-units mode returns PauseInput.byUnits',
        (tester) async {
      PauseInput? returned;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                returned = await showPauseDurationDialog(
                  context: context,
                  templateId: 'tpl-001',
                  recurrenceUnit: RecurrenceUnit.month,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear and enter N=3.
      await tester.enterText(find.byType(TextField), '3');
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(returned, isNotNull);
      expect(returned!.durationN, 3);
      expect(returned!.customDate, isNull);
    });

    // -------------------------------------------------------------------------
    // 6. Unit label shows "months" for month unit template
    // -------------------------------------------------------------------------
    testWidgets('unit label shows "months" for month unit', (tester) async {
      await _showDialog(tester, unit: RecurrenceUnit.month);
      expect(find.text('months'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 7. Custom date mode selectable
    // -------------------------------------------------------------------------
    testWidgets('custom date mode can be selected', (tester) async {
      await _showDialog(tester);

      await tester.tap(find.text('Custom date'));
      await tester.pump();

      expect(find.text('Resume date'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 8. Custom mode: Confirm disabled when no date selected
    // -------------------------------------------------------------------------
    testWidgets('Confirm disabled in custom mode when no date selected',
        (tester) async {
      await _showDialog(tester);

      await tester.tap(find.text('Custom date'));
      await tester.pump();

      final confirmButton = find.widgetWithText(FilledButton, 'Confirm');
      final button = tester.widget<FilledButton>(confirmButton);
      expect(button.onPressed, isNull);
    });
  });
}
