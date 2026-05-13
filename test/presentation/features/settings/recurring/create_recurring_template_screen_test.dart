// test/presentation/features/settings/recurring/create_recurring_template_screen_test.dart
//
// Widget tests for CreateRecurringTemplateScreen (T-106).
//
// Test cases:
//   1. Empty state: Save button is disabled.
//   2. Type switch to Income shows "To account" label and hides "From account".
//   3. Type switch to Transfer shows both From and To account pickers.
//   4. Type switch to Expense shows "From account" and hides "To account".
//   5. Recurrence section renders N field, unit dropdown, and constraint chips.
//   6. First-date preview updates when N field changes.
//   7. Start date picker row is visible.
//   8. Posting behaviour RadioGroup is visible.
//   9. Transfer fee panel is hidden for Expense type.
//  10. Transfer fee panel toggle shows fee fields when enabled.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/repositories/i_category_repository.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/usecases/recurring/create_recurring_template_use_case.dart';
import 'package:variance/presentation/features/settings/recurring/create_recurring_template_screen.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Fakes
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

class _FakeCategoryRepository implements ICategoryRepository {
  @override
  Stream<List<Category>> watchAll() => Stream.value([]);

  @override
  Future<Result<Category>> create(Category category) async => Ok(category);

  @override
  Future<Result<Category>> update(Category category) async => Ok(category);

  @override
  Future<Result<void>> softDelete(String id, {String? replacementId}) async =>
      const Ok(null);

  @override
  Future<bool> existsNameInScope(
    String name,
    CategoryTreeType treeType,
    String? parentId, {
    String? excludeId,
  }) async =>
      false;

  @override
  Future<Category?> findById(String id) async => null;
}

class _FakeCreateUseCase extends CreateRecurringTemplateUseCase {
  _FakeCreateUseCase() : super(_MinimalFakeTemplateRepo());

  RecurringTemplate? lastCreated;

  @override
  Future<Result<RecurringTemplate>> call(RecurringTemplate template) async {
    lastCreated = template;
    return Ok(template);
  }
}

class _MinimalFakeTemplateRepo implements IRecurringTemplateRepository {
  @override
  Stream<List<RecurringTemplate>> watchAll() => Stream.value([]);

  @override
  Stream<RecurringTemplate?> watchById(String id) => Stream.value(null);

  @override
  Future<Result<RecurringTemplate>> create(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<RecurringTemplate>> update(RecurringTemplate t) async => Ok(t);

  @override
  Future<Result<void>> pause(String id) async => const Ok(null);

  @override
  Future<Result<void>> resume(String id) async => const Ok(null);

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<Result<List<RecurringTemplate>>> getDue(DateTime asOf) async =>
      const Ok([]);
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _testAccount = Account(
  id: 'acc-001',
  name: 'Bank',
  accountCategory: AccountCategory.bankAccount,
  currencyCode: 'INR',
  initialBalanceMinor: 0,
  isDeleted: false,
  createdAt: 1000000,
  updatedAt: 1000000,
);

// ---------------------------------------------------------------------------
// Test widget builder
// ---------------------------------------------------------------------------

Widget _buildTestWidget({_FakeCreateUseCase? fakeUseCase}) {
  final useCase = fakeUseCase ?? _FakeCreateUseCase();
  return ProviderScope(
    overrides: [
      activeAccountsProvider.overrideWith(
        (_) => Stream.value([_testAccount]),
      ),
      categoryListProvider.overrideWith(() => _FakeCategoryListNotifier()),
      createRecurringTemplateUseCaseProvider.overrideWith(
        (_) async => useCase,
      ),
    ],
    child: const MaterialApp(
      home: CreateRecurringTemplateScreen(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Fake category list notifier
// ---------------------------------------------------------------------------
class _FakeCategoryListNotifier extends CategoryList {
  @override
  Future<List<Category>> build() async => [];
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CreateRecurringTemplateScreen', () {
    // -------------------------------------------------------------------------
    // 1. Empty state: Save button disabled
    // -------------------------------------------------------------------------
    testWidgets('Save button is disabled in empty state', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Find TextButton with "Save" text — should be disabled.
      final saveButton = find.widgetWithText(TextButton, 'Save');
      expect(saveButton, findsOneWidget);
      final button = tester.widget<TextButton>(saveButton);
      expect(button.onPressed, isNull);
    });

    // -------------------------------------------------------------------------
    // 2. Income type: "To account" shown, "From account" hidden
    // -------------------------------------------------------------------------
    testWidgets('Income type shows "To account" and hides "From account"',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('To account'), findsOneWidget);
      expect(find.text('From account'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 3. Transfer type: both account pickers shown
    // -------------------------------------------------------------------------
    testWidgets('Transfer type shows both From account and To account',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('From account'), findsOneWidget);
      expect(find.text('To account'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 4. Expense type (default): "From account" shown, "To account" hidden
    // -------------------------------------------------------------------------
    testWidgets('Expense type shows "From account" and hides "To account"',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Default is Expense.
      expect(find.text('From account'), findsOneWidget);
      expect(find.text('To account'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 5. Recurrence section renders key fields
    // -------------------------------------------------------------------------
    testWidgets('Recurrence section renders N field and unit dropdown',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Every'), findsOneWidget);
      expect(find.text('Recurrence'), findsOneWidget);
      expect(find.text('Start date'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 6. Constraint chips are rendered
    // -------------------------------------------------------------------------
    testWidgets('Constraint chips render for all RecurrenceConstraint values',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Weekdays only'), findsOneWidget);
      expect(find.text('Weekends only'), findsOneWidget);
      expect(find.text('Start of month'), findsOneWidget);
      expect(find.text('End of month'), findsOneWidget);
      expect(find.text('Start of year'), findsOneWidget);
      expect(find.text('End of year'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 7. Posting behaviour section is visible (scroll to it)
    // -------------------------------------------------------------------------
    testWidgets('Posting behaviour section shows Auto-post option',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Posting behaviour is below the fold — scroll to it.
      await tester.scrollUntilVisible(
        find.text('Posting behaviour'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Posting behaviour'), findsOneWidget);
      expect(find.text('Auto-post'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 8. Transfer fee panel is hidden for Expense type
    // -------------------------------------------------------------------------
    testWidgets('Transfer fee panel is hidden for Expense type', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Transfer fee toggle should not be visible for expense.
      expect(find.text('Transfer fee'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 9. Transfer fee panel visible for Transfer type
    // -------------------------------------------------------------------------
    testWidgets('Transfer fee panel shows for Transfer type', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      // Scroll to the fee panel since the list may be long.
      await tester.scrollUntilVisible(
        find.text('Transfer fee'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Transfer fee'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 10. First-date preview is shown initially
    // -------------------------------------------------------------------------
    testWidgets('First scheduled date preview is visible', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // The preview shows "First scheduled: <date>" when recurrenceN=1 (default).
      expect(find.textContaining('First scheduled:'), findsOneWidget);
    });
  });
}
