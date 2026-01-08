import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/core/widgets/grouped_list_card.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/settings/widgets/account_type_menu.dart';

/// Tests for Phase 3A Account Management widgets.
///
/// Note: AccountSettingsListScreen tests are excluded because the StreamBuilder
/// creates pending timers that are difficult to clean up in widget tests.
/// Integration tests should be used for testing the full screen with database.
void main() {
  group('GroupedListCard', () {
    testWidgets('renders title and children', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupedListCard(
              title: 'Test Group',
              children: [
                const ListTile(title: Text('Item 1')),
                const ListTile(title: Text('Item 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test Group'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('renders leading icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupedListCard(
              title: 'With Icon',
              leadingIcon: Icons.star,
              children: const [ListTile(title: Text('Child'))],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders without icon when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupedListCard(
              title: 'No Icon',
              children: const [ListTile(title: Text('Child'))],
            ),
          ),
        ),
      );

      expect(find.text('No Icon'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });

  group('AccountTypeMenu', () {
    testWidgets('renders all account types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AccountTypeMenu())),
      );

      expect(find.text('Select account type'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
      expect(find.text('Bank Account'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text('Loan'), findsOneWidget);
      expect(find.text('Investment'), findsOneWidget);
      expect(find.text('Insurance'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
    });

    testWidgets('tapping type pops with selected type', (tester) async {
      AccountType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  selectedType = await showModalBottomSheet<AccountType>(
                    context: context,
                    builder: (_) => const AccountTypeMenu(),
                  );
                },
                child: const Text('Show Menu'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      expect(selectedType, AccountType.cash);
    });
  });
}
