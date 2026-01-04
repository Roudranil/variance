import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/features/accounts/screens/accounts_screen.dart';
import 'package:variance/features/dashboard/screens/dashboard_screen.dart';
import 'package:variance/features/home/screens/home_screen.dart';
import 'package:variance/features/settings/screens/settings_screen.dart';
import 'package:variance/features/transactions/screens/transactions_screen.dart';

void main() {
  Widget createHomeScreen() {
    return const MaterialApp(home: HomeScreen());
  }

  testWidgets('HomeScreen displays TransactionsScreen by default', (
    tester,
  ) async {
    await tester.pumpWidget(createHomeScreen());
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });

  testWidgets('HomeScreen navigation switches screens', (tester) async {
    await tester.pumpWidget(createHomeScreen());

    // Initially Transactions
    expect(find.byType(TransactionsScreen), findsOneWidget);

    // Tap Dashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(TransactionsScreen), findsNothing);

    // Tap Accounts
    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountsScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);

    // Tap Settings
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(AccountsScreen), findsNothing);
  });

  testWidgets('HomeScreen NavigationBar has 4 items', (tester) async {
    await tester.pumpWidget(createHomeScreen());
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });
}
