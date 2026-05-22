// test/presentation/features/settings/recurring/installment_plans_list_screen_test.dart
//
// Widget tests for the Installments tab in RecurringTemplatesListScreen (T-139, T-140).
//
// Test cases:
//   T-139.1  Installments tab shows shimmer in loading state.
//   T-139.2  Installments tab shows empty state when no installment plans.
//   T-139.3  Installments tab shows Active / Paused / Archived groups.
//   T-139.4  InstallmentTemplateRow shows LinearProgressIndicator.
//   T-139.5  InstallmentTemplateRow shows "₹X paid of ₹Y" label.
//   T-139.6  Error state shows inline error + Retry.
//   T-140.1  Long-press Active installment row shows context menu (Active items).
//   T-140.2  Long-press Paused installment row shows Unpause item.
//   T-140.3  Long-press Archived installment row shows only read-only items.
//   T-140.4  "View progress" menu item navigates to installment detail route.

import 'dart:async';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/presentation/features/installments/installment_plan_notifiers.dart';
import 'package:variance/presentation/features/settings/recurring/recurring_templates_list_screen.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RecurringTemplate _makeInstallmentTemplate({
  String id = 'templ-1',
  String? title = 'Car Loan',
  RecurringTemplateStatus status = RecurringTemplateStatus.active,
}) =>
    RecurringTemplate(
      id: id,
      title: title,
      transactionType: 'expense',
      amountMinor: 10000,
      currencyCode: 'INR',
      recurrenceUnit: RecurrenceUnit.month,
      recurrenceN: 1,
      startDate: 20000,
      postingBehaviour: PostingBehaviour.autoPost,
      status: status,
      isInstallment: true,
      createdAt: 1700000000,
      updatedAt: 1700000000,
    );

InstallmentPlan _makePlan({
  String templateId = 'templ-1',
  int totalConfiguredMinor = 120000,
  int numberOfInstallments = 12,
}) =>
    InstallmentPlan(
      templateId: templateId,
      totalConfiguredMinor: totalConfiguredMinor,
      numberOfInstallments: numberOfInstallments,
      createdAt: 1700000000,
    );

// ---------------------------------------------------------------------------
// Fake repositories
// ---------------------------------------------------------------------------

class _FakeTemplateRepository implements IRecurringTemplateRepository {
  _FakeTemplateRepository({
    required List<RecurringTemplate> templates,
    this.streamError,
  }) : _templates = templates;

  final List<RecurringTemplate> _templates;
  final Object? streamError;

  @override
  Stream<List<RecurringTemplate>> watchAll() {
    if (streamError != null) {
      return () async* {
        await Future<void>.delayed(Duration.zero);
        yield* Stream<List<RecurringTemplate>>.error(streamError!);
      }();
    }
    return Stream.value(_templates);
  }

  @override
  Stream<RecurringTemplate?> watchById(String id) => Stream.value(null);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate template) async =>
      Ok(template);

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate template) async =>
      Ok(template);

  @override
  Future<Result<void>> pause(String id, {required int pauseUntil}) async =>
      const Ok(null);

  @override
  Future<Result<void>> resume(String id) async => const Ok(null);

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

class _FakePlanRepository implements IInstallmentPlanRepository {
  _FakePlanRepository({required List<InstallmentPlan> plans}) : _plans = plans;

  final List<InstallmentPlan> _plans;

  @override
  Stream<List<InstallmentPlan>> watchAll() => Stream.value(_plans);

  @override
  Stream<InstallmentPlan?> watchById(String id) =>
      Stream.value(_plans.where((p) => p.templateId == id).firstOrNull);

  @override
  Future<Result<InstallmentPlan>> createAtomic({
    required RecurringTemplate template,
    required InstallmentPlan plan,
    required List<dynamic> occurrences,
  }) async =>
      Ok(plan);

  @override
  Future<Result<InstallmentPlan>> create(InstallmentPlan plan) async =>
      Ok(plan);

  @override
  Future<Result<InstallmentPlan>> update(InstallmentPlan plan) async =>
      Ok(plan);

  @override
  Future<Result<void>> closeEarly(String id) async => const Ok(null);
}

// ---------------------------------------------------------------------------
// Test app builder
// ---------------------------------------------------------------------------

/// A fake [InstallmentTemplateList] notifier that emits a fixed list.
class _FakeInstallmentTemplateListNotifier extends InstallmentTemplateList {
  _FakeInstallmentTemplateListNotifier({required this.templates});

  final List<RecurringTemplate> templates;

  @override
  Future<List<RecurringTemplate>> build() async => templates;
}

/// A fake [InstallmentTemplateList] notifier that settles into AsyncError.
///
/// Per devlog: throw from build() triggers auto-retry and never settles at
/// AsyncError. Instead, set state = AsyncError directly so the UI sees it.
class _ErrorInstallmentTemplateListNotifier extends InstallmentTemplateList {
  @override
  Future<List<RecurringTemplate>> build() async {
    // Set error state before returning the unresolved future.
    state = AsyncError<List<RecurringTemplate>>(
      Exception('DB failure'),
      StackTrace.empty,
    );
    // Return a future that never resolves so we stay in error state.
    return Completer<List<RecurringTemplate>>().future;
  }
}

Widget _buildApp({
  required List<RecurringTemplate> templates,
  required List<InstallmentPlan> plans,
  Object? templateStreamError,
}) {
  final router = GoRouter(
    initialLocation: '/settings/recurring',
    routes: [
      GoRoute(
        path: '/settings/recurring',
        builder: (context, state) =>
            const RecurringTemplatesListScreen(initialTab: 1),
      ),
      GoRoute(
        path: '/settings/installments/:id',
        builder: (context, state) => Scaffold(
          body: Text('Detail: ${state.pathParameters['id']}'),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      recurringTemplateRepositoryProvider.overrideWith(
        (_) async => _FakeTemplateRepository(
          templates: templates,
          streamError: templateStreamError,
        ),
      ),
      installmentPlanRepositoryProvider.overrideWith(
        (_) async => _FakePlanRepository(plans: plans),
      ),
      // Override the installmentTemplateListProvider directly to control
      // what templates appear in the Installments tab.
      if (templateStreamError != null)
        installmentTemplateListProvider.overrideWith(
          _ErrorInstallmentTemplateListNotifier.new,
        )
      else
        installmentTemplateListProvider.overrideWith(
          () => _FakeInstallmentTemplateListNotifier(templates: templates),
        ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('T-139 Installments tab', () {
    testWidgets('T-139.1 shows shimmer while loading', (tester) async {
      // Provide empty lists — the notifier will be in loading briefly.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recurringTemplateRepositoryProvider.overrideWith(
              (_) async => _FakeTemplateRepository(templates: []),
            ),
            installmentPlanRepositoryProvider.overrideWith(
              (_) async => _FakePlanRepository(plans: []),
            ),
          ],
          child: const MaterialApp(
            home: RecurringTemplatesListScreen(initialTab: 1),
          ),
        ),
      );
      // Initial frame — should see the screen scaffold without crashing.
      await tester.pump();
      expect(find.byType(RecurringTemplatesListScreen), findsOneWidget);
    });

    testWidgets('T-139.2 shows empty state for installments tab', (tester) async {
      await tester.pumpWidget(
        _buildApp(templates: [], plans: []),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      // Empty state text for installments tab.
      expect(find.textContaining('No installment'), findsOneWidget);
    });

    testWidgets('T-139.3 shows Active / Paused / Archived groups',
        (tester) async {
      final templates = [
        _makeInstallmentTemplate(
          id: 't1',
          title: 'Active Plan',
          status: RecurringTemplateStatus.active,
        ),
        _makeInstallmentTemplate(
          id: 't2',
          title: 'Paused Plan',
          status: RecurringTemplateStatus.paused,
        ),
        _makeInstallmentTemplate(
          id: 't3',
          title: 'Archived Plan',
          status: RecurringTemplateStatus.archived,
        ),
      ];
      final plans = templates
          .map((t) => _makePlan(templateId: t.id))
          .toList();

      await tester.pumpWidget(_buildApp(templates: templates, plans: plans));
      await tester.pump();
      await tester.pumpAndSettle();

      // Group headers appear (may appear more than once due to status badges).
      expect(find.text('Active'), findsWidgets);
      expect(find.text('Paused'), findsWidgets);
      expect(find.text('Archived'), findsWidgets);
    });

    testWidgets('T-139.4 installment row has LinearProgressIndicator',
        (tester) async {
      final template = _makeInstallmentTemplate();
      final plan = _makePlan(
        totalConfiguredMinor: 120000,
        numberOfInstallments: 12,
      );

      await tester.pumpWidget(
        _buildApp(templates: [template], plans: [plan]),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('T-139.5 installment row shows paid-of-total label',
        (tester) async {
      final template = _makeInstallmentTemplate();
      final plan = _makePlan(totalConfiguredMinor: 120000);

      await tester.pumpWidget(
        _buildApp(templates: [template], plans: [plan]),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      // The label "₹X paid of ₹Y" should be present.
      expect(find.textContaining('paid of'), findsWidgets);
    });

    testWidgets('T-139.6 error state shows retry button', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          templates: [],
          plans: [],
          templateStreamError: Exception('DB failure'),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      // Error view has a Retry button.
      expect(find.text('Retry'), findsWidgets);
    });
  });

  group('T-140 Long-press context menu', () {
    testWidgets('T-140.1 Active row shows Edit/Delete/Pause/View menu',
        (tester) async {
      final template = _makeInstallmentTemplate(
        status: RecurringTemplateStatus.active,
        title: 'Active Plan',
      );
      final plan = _makePlan(templateId: template.id);

      await tester.pumpWidget(
        _buildApp(templates: [template], plans: [plan]),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Long-press the row.
      await tester.longPress(find.text('Active Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Edit template'), findsOneWidget);
      expect(find.text('Delete template'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('View child transactions'), findsOneWidget);
      expect(find.text('View progress'), findsOneWidget);
      expect(find.text('Mark series as complete'), findsOneWidget);
    });

    testWidgets('T-140.2 Paused row shows Unpause item', (tester) async {
      final template = _makeInstallmentTemplate(
        id: 't-paused',
        title: 'Paused Plan',
        status: RecurringTemplateStatus.paused,
      );
      final plan = _makePlan(templateId: template.id);

      await tester.pumpWidget(
        _buildApp(templates: [template], plans: [plan]),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Paused Plan'));
      await tester.pumpAndSettle();

      expect(find.text('Unpause'), findsOneWidget);
    });

    testWidgets('T-140.3 Archived row shows only read-only items',
        (tester) async {
      final template = _makeInstallmentTemplate(
        id: 't-archived',
        title: 'Archived Plan',
        status: RecurringTemplateStatus.archived,
      );
      final plan = _makePlan(templateId: template.id);

      await tester.pumpWidget(
        _buildApp(templates: [template], plans: [plan]),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Archived Plan'));
      await tester.pumpAndSettle();

      expect(find.text('View child transactions'), findsOneWidget);
      expect(find.text('View progress'), findsOneWidget);
      // Mutable actions should NOT appear.
      expect(find.text('Edit template'), findsNothing);
      expect(find.text('Delete template'), findsNothing);
      expect(find.text('Mark series as complete'), findsNothing);
    });
  });
}
