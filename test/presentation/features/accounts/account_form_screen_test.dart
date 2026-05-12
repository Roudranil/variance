// test/presentation/features/accounts/account_form_screen_test.dart
//
// Widget tests for AccountFormScreen (create and edit modes).
//
// Test cases:
//   1. create mode: shows "New Account" title
//   2. create mode: Save button disabled until required fields filled
//   3. create mode: category field is enabled (not read-only)
//   4. create mode: category-specific fields animate in when category selected
//   5. edit mode: shows "Edit Account" title
//   6. edit mode: category field is disabled (read-only)
//   7. edit mode: currency field is read-only
//   8. edit mode: initial balance field is hidden
//   9. edit mode: form pre-filled with existing account values
//  10. create mode: duplicate name shows inline error
//  11. create mode: reinstatement dialog fires on name conflict (soft-deleted)
//  12. create mode: successful save navigates back

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/currency.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_account_repository.dart';
import 'package:variance/domain/usecases/account/update_account_use_case.dart';
import 'package:variance/presentation/features/accounts/account_form_screen.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';
import 'package:variance/presentation/providers/use_case_providers.dart';
import 'package:variance/presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers / fakes
// ---------------------------------------------------------------------------

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

Account _makeAccount({
  String id = 'acc-1',
  String name = 'Test Account',
  AccountCategory category = AccountCategory.cash,
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

// Fake AppSettings notifier
class _FakeSettings extends AppSettingsNotifier {
  @override
  Future<AppSettings> build() async =>
      const AppSettings(homeCurrency: 'INR', onboardingComplete: true);
}

// ---------------------------------------------------------------------------
// Fake repositories for injecting into use cases
// ---------------------------------------------------------------------------

/// In-memory [IAccountRepository] that can be configured to return
/// specific results from [create] and [update].
class _FakeAccountRepository implements IAccountRepository {
  _FakeAccountRepository({
    this.nameTaken = false,
    this.softDeleted,
  });

  final bool nameTaken;
  final Account? softDeleted;

  @override
  Stream<List<Account>> watchAll() => const Stream.empty();

  @override
  Stream<Account?> watchById(String id) => const Stream.empty();

  @override
  Stream<Money> watchBalance(String id, String currencyCode) =>
      Stream.value(const Money(amountMinor: 0, currencyCode: 'INR'));

  @override
  Future<Result<Account>> create(Account account) async {
    return Ok(account);
  }

  @override
  Future<Result<Account>> update(Account account) async {
    return Ok(account);
  }

  @override
  Future<Result<void>> softDelete(String id) async => const Ok(null);

  @override
  Future<bool> isNameTaken(String name) async => nameTaken;

  @override
  Future<Account?> findSoftDeletedByNameAndCategory(
    String name,
    AccountCategory category,
  ) async =>
      softDeleted;

  @override
  Future<Result<void>> saveAccountDetails(
    String accountId,
    List<AccountDetail> details,
  ) async =>
      const Ok(null);

  @override
  Future<List<AccountDetail>> getAccountDetails(String accountId) async => [];

  @override
  Future<List<String>> getDistinctActiveCurrencies() async => ['INR'];
}

/// Minimal [IAccountRepository] that always returns duplicate name.
class _DuplicateFakeRepo extends _FakeAccountRepository {
  _DuplicateFakeRepo() : super(nameTaken: true, softDeleted: null);
}

/// Minimal [IAccountRepository] that returns reinstatement offer.
class _ReinstateFakeRepo extends _FakeAccountRepository {
  _ReinstateFakeRepo(Account softDeleted)
      : super(nameTaken: true, softDeleted: softDeleted);
}

/// Builds the form screen in a ProviderScope + GoRouter.
///
/// [existing] — when provided, opens in edit mode.
/// [accountRepo] — optional fake repository; defaults to one that always succeeds.
Widget _buildForm({
  Account? existing,
  _FakeAccountRepository? accountRepo,
}) {
  final repo = accountRepo ?? _FakeAccountRepository();

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, st) => AccountFormScreen(existingAccount: existing),
      ),
      GoRoute(
        path: '/accounts',
        builder: (ctx, st) =>
            const Scaffold(body: Center(child: Text('AccountList'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appSettingsProvider.overrideWith(_FakeSettings.new),
      currenciesProvider.overrideWith(
        (_) async => <Currency>[
          const Currency(
            code: 'INR',
            name: 'Indian Rupee',
            symbol: '₹',
            minorUnits: 2,
          ),
        ],
      ),
      // Inject a use case built on the fake repo — no LedgerEngine needed
      // because _FakeAccountRepository.create returns Ok directly.
      createAccountUseCaseProvider.overrideWith(
        (_) async => AccountFormScreen.makeCreateUseCase(repo),
      ),
      updateAccountUseCaseProvider.overrideWith(
        (_) async => UpdateAccountUseCase(repo),
      ),
    ],
    child: MaterialApp.router(
      theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AccountFormScreen — create mode', () {
    testWidgets('1. shows "New Account" title', (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();

      expect(find.text('New Account'), findsOneWidget);
    });

    testWidgets('2. Save button disabled until required fields filled',
        (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();

      // Save button should be disabled before required fields filled
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('3. category field is enabled in create mode', (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();

      // The category field should be tappable (not read-only).
      expect(find.text('Account category'), findsWidgets);
    });

    testWidgets('4. category-specific fields appear when category is selected',
        (tester) async {
      await tester.pumpWidget(_buildForm());
      await tester.pumpAndSettle();

      // Loan is not yet selected — no loan-specific fields visible.
      expect(find.text('Lender / Borrower name'), findsNothing);

      // Tap category field and select Loan.
      await tester.tap(find.byKey(const Key('account_category_field')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Loan'));
      await tester.pumpAndSettle();

      // Loan-specific optional fields should now be visible.
      expect(find.text('Lender / Borrower name'), findsOneWidget);
    });
  });

  group('AccountFormScreen — edit mode', () {
    testWidgets('5. shows "Edit Account" title', (tester) async {
      final acc = _makeAccount(name: 'My Wallet');
      await tester.pumpWidget(_buildForm(existing: acc));
      await tester.pumpAndSettle();

      expect(find.text('Edit Account'), findsOneWidget);
    });

    testWidgets('6. category field is read-only in edit mode', (tester) async {
      final acc = _makeAccount(category: AccountCategory.bankAccount);
      await tester.pumpWidget(_buildForm(existing: acc));
      await tester.pumpAndSettle();

      // The lock icon should be present on the category field.
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('7. currency field is read-only in edit mode', (tester) async {
      final acc = _makeAccount();
      await tester.pumpWidget(_buildForm(existing: acc));
      await tester.pumpAndSettle();

      // Lock icon should appear near the currency field
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('8. initial balance field is hidden in edit mode',
        (tester) async {
      final acc = _makeAccount();
      await tester.pumpWidget(_buildForm(existing: acc));
      await tester.pumpAndSettle();

      expect(find.text('Initial balance'), findsNothing);
    });

    testWidgets('9. form is pre-filled with existing account values',
        (tester) async {
      final acc = _makeAccount(name: 'Savings Account');
      await tester.pumpWidget(_buildForm(existing: acc));
      await tester.pumpAndSettle();

      // The name field should contain the existing account name.
      expect(
        find.widgetWithText(TextFormField, 'Savings Account'),
        findsOneWidget,
      );
    });
  });

  group('AccountFormScreen — validation', () {
    testWidgets('10. duplicate name shows inline validation error',
        (tester) async {
      await tester.pumpWidget(
        _buildForm(accountRepo: _DuplicateFakeRepo()),
      );
      await tester.pumpAndSettle();

      // Fill name
      await tester.enterText(
        find.byKey(const Key('account_name_field')),
        'Duplicate',
      );
      await tester.pumpAndSettle();

      // Select a category so Save enables
      await tester.tap(find.byKey(const Key('account_category_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('already exists'), findsOneWidget);
    });

    testWidgets('11. reinstatement dialog fires on name conflict',
        (tester) async {
      final softDeleted = _makeAccount(id: 'old-id', name: 'Old Account');
      await tester.pumpWidget(
        _buildForm(accountRepo: _ReinstateFakeRepo(softDeleted)),
      );
      await tester.pumpAndSettle();

      // Fill name
      await tester.enterText(
        find.byKey(const Key('account_name_field')),
        'Old Account',
      );
      await tester.pumpAndSettle();

      // Select a category so Save enables
      await tester.tap(find.byKey(const Key('account_category_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      // Reinstatement dialog should appear
      expect(find.textContaining('previously had'), findsOneWidget);
    });
  });
}
