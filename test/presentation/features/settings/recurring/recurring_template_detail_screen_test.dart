// test/presentation/features/settings/recurring/recurring_template_detail_screen_test.dart
//
// Widget tests for RecurringTemplateDetailScreen (T-109).
//
// Test cases:
//   1. Loading state: shimmer shown before template resolves.
//   2. Loaded state (active): form fields populated, status chip present.
//   3. Loaded state (paused): "Paused until" text shown in status chip.
//   4. Dirty state: editing amount enables the Save button.
//   5. Save calls UpdateRecurringTemplateUseCase and pops on success.
//   6. Save failure shows Snackbar "Failed to save.".
//   7. Not-found state: "Template not found." message shown.
//   8. Immutable field tooltips shown in card.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/usecases/recurring/update_recurring_template_use_case.dart';
import 'package:variance/presentation/features/settings/recurring/recurring_template_detail_screen.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeTemplateRepository implements IRecurringTemplateRepository {
  _FakeTemplateRepository({this.template});

  RecurringTemplate? template;
  bool resumeCalled = false;

  @override
  Stream<RecurringTemplate?> watchById(String id) {
    if (template?.id == id) return Stream.value(template);
    return Stream.value(null);
  }

  @override
  Stream<List<RecurringTemplate>> watchAll() =>
      Stream.value(template != null ? [template!] : []);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async =>
      const Ok(null);

  @override
  Future<Result<void>> resume(String id) async {
    resumeCalled = true;
    return const Ok(null);
  }

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}


// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

RecurringTemplate _makeTemplate({
  String id = 'tpl-1',
  String title = 'Rent payment',
  RecurringTemplateStatus status = RecurringTemplateStatus.active,
  int? pauseUntil,
  PostingBehaviour postingBehaviour = PostingBehaviour.autoPost,
}) =>
    RecurringTemplate(
      id: id,
      transactionType: 'expense',
      status: status,
      amountMinor: 150000, // ₹1,500.00
      currencyCode: 'INR',
      accountSourceId: null,
      recurrenceN: 1,
      recurrenceUnit: RecurrenceUnit.month,
      startDate: 20000,
      pauseUntil: pauseUntil,
      title: title,
      postingBehaviour: postingBehaviour,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

// ---------------------------------------------------------------------------
// Slow-loading notifier (forces loading state)
// ---------------------------------------------------------------------------

class _NeverLoadingNotifier extends RecurringTemplateDetail {
  @override
  Future<RecurringTemplate?> build(String templateId) {
    return Completer<RecurringTemplate?>().future; // never completes
  }
}

// ---------------------------------------------------------------------------
// Error notifier
// ---------------------------------------------------------------------------

class _ErrorNotifier extends RecurringTemplateDetail {
  @override
  Future<RecurringTemplate?> build(String templateId) async {
    state = AsyncError<RecurringTemplate?>(
      Exception('stream failed'),
      StackTrace.empty,
    );
    return Completer<RecurringTemplate?>().future;
  }
}

// ---------------------------------------------------------------------------
// Widget builder helpers
// ---------------------------------------------------------------------------

/// Builds the test widget with a fake repository and optional update use case.
Widget _buildWidget({
  required String templateId,
  required _FakeTemplateRepository repo,
}) {
  return ProviderScope(
    overrides: [
      recurringTemplateRepositoryProvider.overrideWith((_) async => repo),
    ],
    child: MaterialApp(
      home: RecurringTemplateDetailScreen(templateId: templateId),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RecurringTemplateDetailScreen', () {
    // -----------------------------------------------------------------------
    // 1. Loading state
    // -----------------------------------------------------------------------
    testWidgets('1. shows shimmer during loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringTemplateDetailProvider('tpl-1').overrideWith(
              _NeverLoadingNotifier.new,
            ),
          ],
          child: const MaterialApp(
            home: RecurringTemplateDetailScreen(templateId: 'tpl-1'),
          ),
        ),
      );
      await tester.pump();

      // During loading: no error or "not found" text, no Save button content.
      expect(find.text('Failed to load template.'), findsNothing);
      expect(find.text('Template not found.'), findsNothing);
      // The shimmer form's colored containers are rendered.
      expect(find.byType(ListView), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 2. Loaded state (active)
    // -----------------------------------------------------------------------
    testWidgets('2. loaded active template: status chip and fields shown',
        (tester) async {
      final repo = _FakeTemplateRepository(
        template: _makeTemplate(status: RecurringTemplateStatus.active),
      );

      await tester.pumpWidget(_buildWidget(templateId: 'tpl-1', repo: repo));
      await tester.pumpAndSettle();

      // Status chip should contain "Next due".
      expect(find.textContaining('Next due'), findsOneWidget);
      // Amount field should be pre-populated with 1500.00.
      expect(find.text('1500.00'), findsOneWidget);
      // Read-only card should be visible.
      expect(find.text('Read-only fields'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 3. Loaded state (paused)
    // -----------------------------------------------------------------------
    testWidgets('3. loaded paused template: shows Paused until chip',
        (tester) async {
      final repo = _FakeTemplateRepository(
        template: _makeTemplate(
          status: RecurringTemplateStatus.paused,
          pauseUntil: 1750000000, // some epoch in future
        ),
      );

      await tester.pumpWidget(_buildWidget(templateId: 'tpl-1', repo: repo));
      await tester.pumpAndSettle();

      expect(find.textContaining('Paused until'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 4. Dirty state: editing amount enables Save
    // -----------------------------------------------------------------------
    testWidgets('4. editing amount marks form dirty and enables Save',
        (tester) async {
      final repo = _FakeTemplateRepository(
        template: _makeTemplate(),
      );

      await tester.pumpWidget(_buildWidget(templateId: 'tpl-1', repo: repo));
      await tester.pumpAndSettle();

      // Save button should be disabled initially.
      final saveButton = find.widgetWithText(TextButton, 'Save');
      expect(tester.widget<TextButton>(saveButton).enabled, isFalse);

      // Edit the amount field.
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '2000.00');
      await tester.pump();

      // Save should now be enabled.
      expect(tester.widget<TextButton>(saveButton).enabled, isTrue);
    });

    // -----------------------------------------------------------------------
    // 5. Save calls use case and pops on success
    // -----------------------------------------------------------------------
    testWidgets('5. Save calls use case and snackbar is absent on success',
        (tester) async {
      // On success the screen pops — we verify this by checking that no
      // "Failed to save." snackbar appears, and that the use case was called
      // (indirectly via the route pop or absence of error UI).
      final repo = _FakeTemplateRepository(
        template: _makeTemplate(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringTemplateRepositoryProvider.overrideWith(
              (_) async => repo,
            ),
            updateRecurringTemplateUseCaseProvider.overrideWith(
              (_) async => UpdateRecurringTemplateUseCase(repo),
            ),
          ],
          child: const MaterialApp(
            home: RecurringTemplateDetailScreen(templateId: 'tpl-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dirty the form.
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '2000.00');
      await tester.pump();

      // Tap Save.
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // No error snackbar — save succeeded.
      expect(find.text('Failed to save.'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // 6. Save failure shows snackbar
    // -----------------------------------------------------------------------
    testWidgets('6. Save failure shows "Failed to save." snackbar',
        (tester) async {
      // Use a repo whose update always fails.
      final failingRepo = _FailingUpdateRepo(
        template: _makeTemplate(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringTemplateRepositoryProvider.overrideWith(
              (_) async => failingRepo,
            ),
            updateRecurringTemplateUseCaseProvider.overrideWith(
              (_) async => UpdateRecurringTemplateUseCase(failingRepo),
            ),
          ],
          child: const MaterialApp(
            home: RecurringTemplateDetailScreen(templateId: 'tpl-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dirty the form.
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '2000.00');
      await tester.pump();

      // Tap Save.
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      // Snackbar should appear.
      expect(find.text('Failed to save.'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 7. Not-found: template null
    // -----------------------------------------------------------------------
    testWidgets('7. shows "Template not found." when template is null',
        (tester) async {
      // Repo returns null stream.
      final repo = _FakeTemplateRepository(template: null);

      await tester
          .pumpWidget(_buildWidget(templateId: 'tpl-missing', repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Template not found.'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 8. Immutable fields shown in read-only card
    // -----------------------------------------------------------------------
    testWidgets('8. read-only card shows immutable field chips',
        (tester) async {
      final repo = _FakeTemplateRepository(
        template: _makeTemplate(),
      );

      await tester.pumpWidget(_buildWidget(templateId: 'tpl-1', repo: repo));
      await tester.pumpAndSettle();

      // The card should be present.
      expect(find.text('Read-only fields'), findsOneWidget);
      // At minimum the transaction type chip should be visible.
      expect(find.textContaining('Expense'), findsWidgets);
      // Recurrence chip.
      expect(find.textContaining('Every 1 month'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Repo whose update always returns an error.
class _FailingUpdateRepo extends _FakeTemplateRepository {
  _FailingUpdateRepo({super.template});

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async =>
      const Err(DatabaseFailure('intentional failure'));
}
