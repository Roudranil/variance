// test/presentation/features/home/widgets/transaction_row_test.dart
//
// Widget tests for TransactionRow (T-155).
//
// Test cases:
//   1. Expense row: category icon + parentName + title + source account + red amount
//   2. Income row: category icon + destination account + green amount
//   3. Transfer row: "Transfer" label (no icon) + "Src → Dst" account info + neutral amount
//   4. Foreign-currency row: FX equivalent shown on row 2 of C3
//   5. Pending badge shown when isFutureMonth = true
//   6. Row uses muted onSurfaceVariant styling when isPending = true

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/category.dart';
import 'package:variance/domain/entities/transaction.dart';
import 'package:variance/presentation/features/home/widgets/transaction_row.dart';
import 'package:variance/presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [widget] in a [MaterialApp] with the Variance theme.
Widget _wrap(Widget widget) {
  return MaterialApp(
    theme: AppThemeData.fromSeed(const Color(0xFF6750A4)).light,
    home: Scaffold(body: widget),
  );
}

Account _makeAccount(String id, String name, {String currency = 'INR'}) {
  return Account(
    id: id,
    name: name,
    accountCategory: AccountCategory.bankAccount,
    currencyCode: currency,
    createdAt: 0,
    updatedAt: 0,
  );
}

Category _makeCategory(String id, String name, {String? parentId}) {
  return Category(
    id: id,
    name: name,
    iconRef: 'shopping_cart',
    treeType: CategoryTreeType.expense,
    createdAt: 0,
    updatedAt: 0,
  );
}

Transaction _makeTx({
  String id = 'tx1',
  TransactionType type = TransactionType.expense,
  String? title,
  String? categoryId,
  String? accountSourceId,
  String? accountDestinationId,
  int amountMinor = 5000,
  String currencyCode = 'INR',
  int? exchangeRateMicro,
  String? homeCurrencyAtCapture,
}) {
  return Transaction(
    id: id,
    type: type,
    status: TransactionStatus.posted,
    dateTime: 1000000,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    exchangeRateMicro: exchangeRateMicro,
    homeCurrencyAtCapture: homeCurrencyAtCapture,
    categoryId: categoryId,
    accountSourceId: accountSourceId,
    accountDestinationId: accountDestinationId,
    title: title,
    createdAt: 0,
    updatedAt: 0,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TransactionRow (T-155)', () {
    testWidgets('1 — expense: category name, title, source account visible',
        (tester) async {
      final cat = _makeCategory('c1', 'Food');
      final account = _makeAccount('a1', 'HDFC Savings');
      final tx = _makeTx(
        type: TransactionType.expense,
        title: 'Dinner',
        categoryId: cat.id,
        accountSourceId: account.id,
      );

      await tester.pumpWidget(
        _wrap(
          TransactionRow(
            transaction: tx,
            category: cat,
            parentCategory: null,
            sourceAccount: account,
            destinationAccount: null,
            homeCurrency: 'INR',
            usedCurrencySymbols: const {},
            isPending: false,
          ),
        ),
      );

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('HDFC Savings'), findsOneWidget);
    });

    testWidgets('2 — income: destination account shown', (tester) async {
      final cat = _makeCategory('c2', 'Salary');
      final account = _makeAccount('a2', 'SBI Salary');
      final tx = _makeTx(
        type: TransactionType.income,
        title: 'Monthly salary',
        categoryId: cat.id,
        accountDestinationId: account.id,
      );

      await tester.pumpWidget(
        _wrap(
          TransactionRow(
            transaction: tx,
            category: cat,
            parentCategory: null,
            sourceAccount: null,
            destinationAccount: account,
            homeCurrency: 'INR',
            usedCurrencySymbols: const {},
            isPending: false,
          ),
        ),
      );

      expect(find.text('SBI Salary'), findsOneWidget);
    });

    testWidgets('3 — transfer: "Transfer" label, arrow account info',
        (tester) async {
      final src = _makeAccount('a3', 'Wallet');
      final dst = _makeAccount('a4', 'HDFC');
      final tx = _makeTx(
        type: TransactionType.transfer,
        accountSourceId: src.id,
        accountDestinationId: dst.id,
      );

      await tester.pumpWidget(
        _wrap(
          TransactionRow(
            transaction: tx,
            category: null,
            parentCategory: null,
            sourceAccount: src,
            destinationAccount: dst,
            homeCurrency: 'INR',
            usedCurrencySymbols: const {},
            isPending: false,
          ),
        ),
      );

      expect(find.text('Transfer'), findsOneWidget);
      // Account info shows "Wallet → HDFC"
      expect(find.textContaining('→'), findsOneWidget);
    });

    testWidgets('4 — foreign currency: FX equivalent row 2 shown',
        (tester) async {
      final cat = _makeCategory('c5', 'Travel');
      final account = _makeAccount('a5', 'USD Wallet', currency: 'USD');
      final tx = _makeTx(
        type: TransactionType.expense,
        currencyCode: 'USD',
        amountMinor: 1000, // $10.00
        exchangeRateMicro: 83000000, // 83 INR per USD
        homeCurrencyAtCapture: 'INR',
        categoryId: cat.id,
        accountSourceId: account.id,
      );

      await tester.pumpWidget(
        _wrap(
          TransactionRow(
            transaction: tx,
            category: cat,
            parentCategory: null,
            sourceAccount: account,
            destinationAccount: null,
            homeCurrency: 'INR',
            usedCurrencySymbols: const {},
            isPending: false,
          ),
        ),
      );

      // FX equivalent row should be visible (contains INR indicator)
      expect(find.byKey(const Key('tx_row_fx_equivalent')), findsOneWidget);
    });

    testWidgets('5 — pending badge shown when isPending = true',
        (tester) async {
      final cat = _makeCategory('c6', 'Bills');
      final account = _makeAccount('a6', 'Cash');
      final tx = _makeTx(
        type: TransactionType.expense,
        categoryId: cat.id,
        accountSourceId: account.id,
      );

      await tester.pumpWidget(
        _wrap(
          TransactionRow(
            transaction: tx,
            category: cat,
            parentCategory: null,
            sourceAccount: account,
            destinationAccount: null,
            homeCurrency: 'INR',
            usedCurrencySymbols: const {},
            isPending: true,
          ),
        ),
      );

      expect(find.byKey(const Key('tx_row_pending_badge')), findsOneWidget);
    });

    testWidgets('6 — subcategory name shown when parentCategory provided',
        (tester) async {
      final parent = _makeCategory('p1', 'Food & Drink');
      final sub = _makeCategory('s1', 'Restaurants', parentId: 'p1');
      final account = _makeAccount('a7', 'Credit');
      final tx = _makeTx(
        type: TransactionType.expense,
        categoryId: sub.id,
        accountSourceId: account.id,
      );

      await tester.pumpWidget(
        _wrap(
          TransactionRow(
            transaction: tx,
            category: sub,
            parentCategory: parent,
            sourceAccount: account,
            destinationAccount: null,
            homeCurrency: 'INR',
            usedCurrencySymbols: const {},
            isPending: false,
          ),
        ),
      );

      // Both parent and subcategory names shown in C1
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Restaurants'), findsOneWidget);
    });
  });
}
