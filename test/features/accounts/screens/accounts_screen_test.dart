import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/features/accounts/screens/accounts_screen.dart';

void main() {
  testWidgets('AccountsScreen renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AccountsScreen()));

    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Accounts Screen'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget); // FAB exists
  });
}
