// test/presentation/features/installments/create_installment_screen_test.dart
//
// Widget tests for CreateInstallmentScreen (T-134, T-135, T-136).
//
// Test cases:
//   T-134.1  Save button disabled in empty state.
//   T-134.2  Type switch to Income hides "From account", shows "To account".
//   T-134.3  Type switch to Transfer shows both account pickers.
//   T-134.4  End date display starts as "Ends: —".
//   T-134.5  Per-installment field shows helper "Auto: total ÷ count".
//   T-135.1  End date non-empty after filling total + count.
//   T-135.2  Mismatch warning card appears after manual per-installment override.
//   T-136.1  Save calls use case and shows snackbar on success.
//   T-136.2  Save shows error snackbar on use case failure.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';
import 'package:variance/domain/repositories/i_installment_plan_repository.dart';
import 'package:variance/domain/services/period_calculator.dart';
import 'package:variance/domain/usecases/installment/create_installment_plan_use_case.dart';
import 'package:variance/presentation/features/installments/create_installment_screen.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Stub repo
// ---------------------------------------------------------------------------

class _StubPlanRepo implements IInstallmentPlanRepository {
  @override
  Stream<List<InstallmentPlan>> watchAll() => const Stream.empty();
  @override
  Stream<InstallmentPlan?> watchById(String id) => const Stream.empty();
  @override
  Future<Result<InstallmentPlan>> createAtomic({
    required RecurringTemplate template,
    required InstallmentPlan plan,
    required List<InstallmentOccurrence> occurrences,
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
// Fake use case
// ---------------------------------------------------------------------------

class _FakeUseCase extends CreateInstallmentPlanUseCase {
  _FakeUseCase({required this.returnResult})
      : super(
          planRepository: _StubPlanRepo(),
          periodCalculator: const PeriodCalculator(),
        );

  final Result<InstallmentPlan> returnResult;

  @override
  Future<Result<InstallmentPlan>> call(CreateInstallmentPlanInput input) async {
    return returnResult;
  }
}

// ---------------------------------------------------------------------------
// Fake repos and notifiers
// ---------------------------------------------------------------------------

class _FakeAccountRepository implements IAccountRepository {
  @override
  Stream<List<Account>> watchAll() => Stream.value([_testAccount]);
  @override
  Stream<Account?> watchById(String id) => Stream.value(null);
  @override
  Future<Result<Account>> create(Account account) async => Ok(account);
  @override
  Future<Result<Account>> update(Account account) async => Ok(account);
  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);
  @override
  Future<bool> isNameTaken(String name) async => false;
  @override
  Stream<Money> watchBalance(String id, String currencyCode) =>
      const Stream.empty();
  @override
  Future<Account?> findSoftDeletedByNameAndCategory(
    String name,
    AccountCategory category,
  ) async =>
      null;
  @override
  Future<Result<void>> saveAccountDetails(
    String accountId,
    List<AccountDetail> details,
  ) async =>
      const Ok(null);
  @override
  Future<List<AccountDetail>> getAccountDetails(String accountId) async => [];
  @override
  Future<List<String>> getDistinctActiveCurrencies() async => [];
}

class _FakeCategoryListNotifier extends CategoryList {
  @override
  Future<List<Category>> build() async => [];
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _testAccount = Account(
  id: 'acc-001',
  name: 'Bank',
  accountCategory: AccountCategory.bankAccount,
  currencyCode: 'INR',
  initialBalanceMinor: 0,
  isDeleted: false,
  createdAt: 1000000,
  updatedAt: 1000000,
);

final _fakePlan = InstallmentPlan(
  templateId: 'tmpl-1',
  totalConfiguredMinor: 12000,
  numberOfInstallments: 12,
  createdAt: 1000000,
);

// ---------------------------------------------------------------------------
// Widget builder
// ---------------------------------------------------------------------------

Widget _buildWidget({Result<InstallmentPlan>? useCaseResult}) {
  final useCase = _FakeUseCase(
    returnResult: useCaseResult ?? Ok(_fakePlan),
  );
  return ProviderScope(
    overrides: [
      activeAccountsProvider.overrideWith(
        (_) => Stream.value([_testAccount]),
      ),
      categoryListProvider.overrideWith(_FakeCategoryListNotifier.new),
      createInstallmentPlanUseCaseProvider.overrideWith(
        (_) async => useCase,
      ),
    ],
    child: const MaterialApp(
      home: CreateInstallmentScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Helpers: find TextFormField by labelText decoration
// ---------------------------------------------------------------------------

/// Finds a [TextField] inside a [TextFormField] whose [InputDecoration.labelText]
/// matches [label].
Finder _fieldByLabel(String label) {
  return find.descendant(
    of: find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.labelText == label),
    ),
    matching: find.byType(EditableText),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CreateInstallmentScreen', () {
    // T-134.1
    testWidgets('T-134.1 Save button disabled in empty state', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(TextButton, 'Save');
      expect(saveButton, findsOneWidget);
      final button = tester.widget<TextButton>(saveButton);
      expect(button.onPressed, isNull);
    });

    // T-134.2
    testWidgets(
        'T-134.2 Income type: "To account" shown, "From account" hidden',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('To account'), findsOneWidget);
      expect(find.text('From account'), findsNothing);
    });

    // T-134.3
    testWidgets('T-134.3 Transfer type: both account pickers shown',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('From account'), findsOneWidget);
      expect(find.text('To account'), findsOneWidget);
    });

    // T-134.4
    testWidgets('T-134.4 End date shows "Ends: —" initially', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ends: —'), findsOneWidget);
    });

    // T-134.5
    testWidgets('T-134.5 Per-installment field shows helper text',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Auto: total ÷ count'), findsOneWidget);
    });

    // T-135.1 — End date updates
    testWidgets('T-135.1 End date updates after filling total + count',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      // Enter total amount using label-based finder.
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Total amount',
        ),
        '12000',
      );
      await tester.pump();

      // Enter count.
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Number of installments',
        ),
        '12',
      );
      await tester.pumpAndSettle();

      // End date should no longer be "—".
      expect(find.text('Ends: —'), findsNothing);
    });

    // T-135.2 — Mismatch warning
    testWidgets(
        'T-135.2 Mismatch warning appears after manual per-installment override',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      // Fill total.
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Total amount',
        ),
        '12000',
      );
      await tester.pump();

      // Fill count.
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Number of installments',
        ),
        '12',
      );
      await tester.pump();

      // Override per-installment to 500 (causes mismatch: 12 × 500 = 6000 ≠ 12000).
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Per-installment amount',
        ),
        '500',
      );
      await tester.pumpAndSettle();

      // Warning card visible.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data ?? '').contains('does not match configured total'),
        ),
        findsOneWidget,
      );
    });

    // T-136.1
    testWidgets('T-136.1 Save calls use case and shows snackbar on success',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pumpAndSettle();

      // Fill total.
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Total amount',
        ),
        '12000',
      );
      await tester.pump();

      // Fill count (use 2 to keep dates simple for test).
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Number of installments',
        ),
        '2',
      );
      await tester.pump();

      // Select source account (expense type by default).
      final dropdown = find.byType(DropdownButtonFormField<Account>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank').last);
      await tester.pumpAndSettle();

      // Tap Save.
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Installment plan saved'), findsOneWidget);
    });

    // T-136.2
    testWidgets('T-136.2 Save shows error snackbar on failure', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          useCaseResult: const Err(DatabaseFailure('DB write failed')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Total amount',
        ),
        '12000',
      );
      await tester.pump();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              w.decoration?.labelText == 'Number of installments',
        ),
        '2',
      );
      await tester.pump();

      final dropdown = find.byType(DropdownButtonFormField<Account>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('DB write failed'), findsOneWidget);
    });
  });
}
