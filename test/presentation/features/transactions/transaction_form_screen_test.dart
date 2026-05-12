// test/presentation/features/transactions/transaction_form_screen_test.dart
//
// Widget tests for TransactionFormScreen (T-51, T-52, T-44).
//
// Test cases:
//   1. income type: account picker labelled "To account (income)"
//   2. expense type: account picker labelled "From account (expense)"
//   3. transfer type: shows source AND destination pickers
//   4. transfer same-currency: exchange rate field hidden
//   5. transfer cross-currency: exchange rate field shown
//   6. fee toggle: fee fields appear when enabled
//   7. submit disabled until required fields filled
//   8. overdraft banner appears on asset account (stubbed balance = 0)
//   9. credit limit banner appears on credit card account (stubbed balance = 0)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/entry.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/domain/repositories/i_transaction_repository.dart';
import 'package:variance/domain/services/ledger_engine.dart';
import 'package:variance/domain/usecases/transaction/create_transaction_use_case.dart';
import 'package:variance/presentation/features/transactions/transaction_form_screen.dart';
import 'package:variance/presentation/providers/account_providers.dart';
import 'package:variance/presentation/providers/category_providers.dart'
    show CategoryList, categoryListProvider;
import 'package:variance/presentation/providers/use_case_providers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

Account _makeAccount({
  String id = 'acc-1',
  String name = 'Bank Account',
  AccountCategory category = AccountCategory.bankAccount,
  String currency = 'INR',
}) {
  return Account(
    id: id,
    name: name,
    accountCategory: category,
    currencyCode: currency,
    createdAt: _now,
    updatedAt: _now,
  );
}

Category _makeCategory({String id = 'cat-1', String name = 'Food'}) {
  return Category(
    id: id,
    name: name,
    treeType: CategoryTreeType.expense,
    iconRef: 'restaurant',
    createdAt: _now,
    updatedAt: _now,
  );
}

class _FakeCategoryList extends CategoryList {
  _FakeCategoryList(this._cats);
  final List<Category> _cats;

  @override
  Future<List<Category>> build() async => _cats;
}

class _FakeTransactionRepository implements ITransactionRepository {
  @override
  Future<Result<Transaction>> create(Transaction draft) async => Ok(draft);
  @override
  Future<Result<Transaction>> createWithEntries(
          Transaction draft, List<Entry> entries,) async =>
      Ok(draft);
  @override
  Stream<List<Transaction>> watchByMonth(int year, int month,
          {TransactionFilters? filters,}) =>
      Stream.value([]);
  @override
  Stream<Transaction?> watchById(String id) => Stream.value(null);
  @override
  Future<Result<Transaction>> correctFinancial(String id, Transaction draft) =>
      throw UnimplementedError();
  @override
  Future<Result<Transaction>> correctFinancialChain({
    required String originalId,
    required Transaction reversal,
    required List<Entry> reversalEntries,
    required Transaction correction,
    required List<Entry> correctionEntries,
  }) =>
      throw UnimplementedError();
  @override
  Future<Result<Transaction>> updateNonFinancial(
          String id, TransactionNonFinancialPatch patch,) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> void$(String id) => throw UnimplementedError();
  @override
  Future<Result<void>> bulkVoid(List<String> ids) =>
      throw UnimplementedError();
  @override
  Future<Result<List<Transaction>>> search(String query,
          {TransactionFilters? filters,}) =>
      throw UnimplementedError();
  @override
  Future<List<Transaction>> getDuePendingTransactions(int nowEpoch) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> postPending(String id, List<Entry> entries) =>
      throw UnimplementedError();
}

class _FakeLedgerRepository implements LedgerRepository {
  @override
  Future<Result<void>> insertEntries(List<Entry> entries) async =>
      const Ok(null);
  @override
  Future<bool> eqAccountExists(String currencyCode) async => true;
  @override
  Future<Result<String>> createEqAccount(String currencyCode) async =>
      Ok('__EQ_$currencyCode');
}

// ---------------------------------------------------------------------------
// Test builder
// ---------------------------------------------------------------------------

Widget _buildForm({
  List<Account>? accounts,
  List<Category>? categories,
}) {
  final accts = accounts ??
      [
        _makeAccount(id: 'acc-1', name: 'Bank', category: AccountCategory.bankAccount),
        _makeAccount(id: 'acc-2', name: 'Cash', category: AccountCategory.cash),
      ];
  final cats = categories ?? [_makeCategory()];

  final repo = _FakeTransactionRepository();
  final engine = LedgerEngine(_FakeLedgerRepository());
  final useCase = CreateTransactionUseCase(repo, engine);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const TransactionFormScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      accountsProvider.overrideWith(
        (_) => Stream<List<Account>>.value(accts),
      ),
      categoryListProvider.overrideWith(
        () => _FakeCategoryList(cats),
      ),
      createTransactionUseCaseProvider.overrideWith(
        (_) async => useCase,
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  testWidgets('1. income type shows To account picker', (tester) async {
    await tester.pumpWidget(_buildForm());
    await tester.pumpAndSettle();

    // Switch to Income
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('To account (income)'), findsOneWidget);
    expect(find.text('From account (expense)'), findsNothing);
  });

  testWidgets('2. expense type shows From account picker', (tester) async {
    await tester.pumpWidget(_buildForm());
    await tester.pumpAndSettle();

    // Expense is default
    expect(find.text('From account (expense)'), findsOneWidget);
  });

  testWidgets('3. transfer type shows both source and destination pickers',
      (tester) async {
    await tester.pumpWidget(_buildForm());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    expect(find.text('From account'), findsOneWidget);
    expect(find.text('To account'), findsOneWidget);
  });

  testWidgets('4. transfer same-currency hides exchange rate field',
      (tester) async {
    await tester.pumpWidget(_buildForm());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    // Both accounts are INR — no exchange rate field shown
    expect(find.text('Exchange rate'), findsNothing);
  });

  testWidgets('5. transfer cross-currency shows exchange rate field',
      (tester) async {
    final accounts = [
      _makeAccount(id: 'acc-1', name: 'INR Bank', currency: 'INR'),
      _makeAccount(id: 'acc-2', name: 'USD Bank', currency: 'USD'),
    ];
    await tester.pumpWidget(_buildForm(accounts: accounts));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    // Select source account
    await tester.tap(find.text('Select account').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('INR Bank'));
    await tester.pumpAndSettle();

    // Select destination account with different currency
    await tester.tap(find.text('Select account').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('USD Bank'));
    await tester.pumpAndSettle();

    expect(find.text('Exchange rate'), findsOneWidget);
  });

  testWidgets('6. fee toggle shows fee fields when enabled', (tester) async {
    await tester.pumpWidget(_buildForm());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    // Fee fields hidden initially
    expect(find.text('Fee amount'), findsNothing);

    // Enable fee toggle
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Fee amount'), findsOneWidget);
  });

  testWidgets('7. Save button disabled until required fields filled',
      (tester) async {
    await tester.pumpWidget(_buildForm());
    await tester.pumpAndSettle();

    // Scroll to bottom to ensure Save button is visible.
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    final saveBtn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveBtn.onPressed, isNull);
  });

  testWidgets('8. overdraft banner appears on asset account with zero balance',
      (tester) async {
    await tester.pumpWidget(_buildForm());
    await tester.pumpAndSettle();

    // Enter amount (triggers warning update)
    await tester.enterText(find.byType(TextFormField).first, '1000');
    await tester.pumpAndSettle();

    // Select a bank account source
    await tester.tap(find.text('Select account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bank'));
    await tester.pumpAndSettle();

    // Scroll to reveal the banner (it renders below the account picker).
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // Overdraft banner should appear (projected balance = 0 - 1000*100 < 0)
    expect(
      find.textContaining('overdraft'),
      findsOneWidget,
    );
  });

  testWidgets(
      '9. credit limit banner appears on credit card account with zero balance',
      (tester) async {
    final accounts = [
      _makeAccount(
        id: 'cc-1',
        name: 'My Card',
        category: AccountCategory.creditCard,
      ),
    ];
    await tester.pumpWidget(_buildForm(accounts: accounts));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '500');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Card'));
    await tester.pumpAndSettle();

    // Scroll to reveal the banner.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('credit card limit'),
      findsOneWidget,
    );
  });
}
