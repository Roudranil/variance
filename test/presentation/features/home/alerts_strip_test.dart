// test/presentation/features/home/alerts_strip_test.dart
//
// Widget tests for AlertsStrip with pending-confirmation cards (T-117).
//
// Test cases:
//   1. empty state (no pending occurrences) shows nothing
//   2. single pending occurrence renders card with template name, date, amount
//   3. multiple pending occurrences render multiple cards
//   4. Confirm button calls PostDueOccurrencesUseCase
//   5. Dismiss button shows confirmation dialog

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/presentation/features/home/widgets/alerts_strip.dart';
import 'package:variance/presentation/providers/alerts_strip_providers.dart';

// ---------------------------------------------------------------------------
// Fake notifier
// ---------------------------------------------------------------------------

class _FakePendingOccurrencesNotifier extends PendingOccurrences {
  @override
  Future<List<PendingOccurrenceItem>> build() async => [];

  void setItems(List<PendingOccurrenceItem> items) {
    state = AsyncValue.data(items);
  }

  @override
  Future<void> confirmOccurrence(String occurrenceId) async {
    // Remove from state to simulate success.
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.where((i) => i.occurrence.id != occurrenceId).toList(),
    );
  }

  @override
  Future<void> skipOccurrence(String occurrenceId) async {
    final current = state.value ?? [];
    state = AsyncValue.data(
      current.where((i) => i.occurrence.id != occurrenceId).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PendingOccurrenceItem _makeItem({
  String occId = 'occ-1',
  String tmplId = 'tmpl-1',
  String? title = 'Electricity Bill',
  int amountMinor = 5000,
  int scheduledDate = 20000,
}) =>
    PendingOccurrenceItem(
      occurrence: ScheduledOccurrence(
        id: occId,
        templateId: tmplId,
        scheduledDate: scheduledDate,
        createdAt: 0,
        updatedAt: 0,
      ),
      template: RecurringTemplate(
        id: tmplId,
        transactionType: 'expense',
        amountMinor: amountMinor,
        currencyCode: 'INR',
        title: title,
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        startDate: 19000,
        createdAt: 0,
        updatedAt: 0,
      ),
    );

Widget _buildApp(_FakePendingOccurrencesNotifier notifier) {
  return ProviderScope(
    overrides: [
      pendingOccurrencesProvider.overrideWith(() => notifier),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: AlertsStrip(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AlertsStrip', () {
    testWidgets('1. empty state shows nothing', (tester) async {
      final notifier = _FakePendingOccurrencesNotifier();
      await tester.pumpWidget(_buildApp(notifier));
      await tester.pump();

      expect(find.byType(AlertsStrip), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('2. single pending occurrence renders card with title',
        (tester) async {
      final notifier = _FakePendingOccurrencesNotifier();
      await tester.pumpWidget(_buildApp(notifier));

      notifier.setItems([_makeItem(title: 'Electricity Bill')]);
      await tester.pump();

      expect(find.text('Electricity Bill'), findsOneWidget);
    });

    testWidgets('3. multiple pending occurrences render multiple cards',
        (tester) async {
      final notifier = _FakePendingOccurrencesNotifier();
      await tester.pumpWidget(_buildApp(notifier));

      notifier.setItems([
        _makeItem(occId: 'occ-1', title: 'Electricity Bill'),
        _makeItem(occId: 'occ-2', title: 'Rent'),
      ]);
      await tester.pump();

      expect(find.text('Electricity Bill'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
    });

    testWidgets('4. Confirm button removes card from list', (tester) async {
      final notifier = _FakePendingOccurrencesNotifier();
      await tester.pumpWidget(_buildApp(notifier));

      notifier.setItems([_makeItem(occId: 'occ-confirm', title: 'Gym')]);
      await tester.pump();

      // Tap the Confirm button.
      await tester.tap(find.text('Confirm'));
      await tester.pump();

      // Card should be removed.
      expect(find.text('Gym'), findsNothing);
    });

    testWidgets('5. Dismiss button shows confirmation dialog', (tester) async {
      final notifier = _FakePendingOccurrencesNotifier();
      await tester.pumpWidget(_buildApp(notifier));

      notifier.setItems([_makeItem(occId: 'occ-dismiss', title: 'Streaming')]);
      await tester.pump();

      // Tap the Dismiss button.
      await tester.tap(find.text('Dismiss'));
      await tester.pump();

      // Dialog with confirmation question should appear (title + content both match).
      expect(
        find.textContaining('Skip this occurrence'),
        findsAtLeast(1),
      );
    });
  });
}
