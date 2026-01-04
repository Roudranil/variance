import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:variance/features/transactions/screens/transactions_screen.dart';

void main() {
  testWidgets('TransactionsScreen renders correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TransactionsScreen()));

    expect(find.text('Transactions'), findsOneWidget); // AppBar title
    expect(find.text('Transactions Screen'), findsOneWidget); // Body
    expect(find.byType(FloatingActionButton), findsOneWidget); // FAB exists
  });
}
