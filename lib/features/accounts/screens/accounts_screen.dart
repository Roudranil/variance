import 'package:flutter/material.dart';

/// The Accounts screen.
///
/// Displays a list of accounts and their balances.
class AccountsScreen extends StatelessWidget {
  /// Creates a new instance of [AccountsScreen].
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: const Center(child: Text('Accounts Screen')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement Add Account
        },
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
