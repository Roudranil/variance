// test/presentation/features/accounts/account_detail_screen_test.dart
//
// Widget tests for AccountDetailScreen (T-41, T-42).
//
// Test cases:
//   1. credit_card account shows Pay FAB
//   2. non-credit-card account does not show Pay FAB
//   3. null account (not found) shows "Account not found."
//   4. deleted account shows deleted banner; no edit/delete actions in app bar

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/presentation/features/accounts/account_detail_screen.dart';
import 'package:variance/presentation/providers/account_providers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

Account _makeAccount({
  String id = 'acc-1',
  String name = 'Test Account',
  AccountCategory category = AccountCategory.bankAccount,
  bool isDeleted = false,
}) {
  return Account(
    id: id,
    name: name,
    accountCategory: category,
    currencyCode: 'INR',
    createdAt: _now,
    updatedAt: _now,
    isDeleted: isDeleted,
  );
}

Widget _buildScreen(Account? account) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) =>
            const AccountDetailScreen(accountId: 'acc-1'),
      ),
      GoRoute(
        path: '/transaction/new',
        builder: (_, __) =>
            const Scaffold(body: Text('TransactionForm')),
      ),
      GoRoute(
        path: '/accounts/acc-1/edit',
        builder: (_, __) => const Scaffold(body: Text('EditAccount')),
      ),
      GoRoute(
        path: '/accounts/acc-1/reconcile',
        builder: (_, __) =>
            const Scaffold(body: Text('ReconcileScreen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      accountByIdProvider.overrideWith(
        (_, __) => Stream<Account?>.value(account),
      ),
      accountBalanceProvider.overrideWith(
        (_, __) => Stream<int>.value(0),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  testWidgets('1. credit_card account shows Pay FAB', (tester) async {
    final account = _makeAccount(category: AccountCategory.creditCard);
    await tester.pumpWidget(_buildScreen(account));
    await tester.pumpAndSettle();

    expect(find.text('Pay'), findsOneWidget);
  });

  testWidgets('2. non-credit-card account does not show Pay FAB',
      (tester) async {
    final account = _makeAccount(category: AccountCategory.bankAccount);
    await tester.pumpWidget(_buildScreen(account));
    await tester.pumpAndSettle();

    expect(find.text('Pay'), findsNothing);
  });

  testWidgets('3. null account shows Account not found message',
      (tester) async {
    await tester.pumpWidget(_buildScreen(null));
    await tester.pumpAndSettle();

    expect(find.text('Account not found.'), findsOneWidget);
  });

  testWidgets('4. deleted account shows deleted banner, no edit icon',
      (tester) async {
    final account = _makeAccount(isDeleted: true);
    await tester.pumpWidget(_buildScreen(account));
    await tester.pumpAndSettle();

    expect(
      find.text('This account has been deleted.'),
      findsOneWidget,
    );
    // Edit icon should not be present for deleted accounts.
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });
}
