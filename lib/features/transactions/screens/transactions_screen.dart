import 'package:flutter/material.dart';

/// The Transactions screen.
///
/// Displays a list of transactions and allows adding new ones.
class TransactionsScreen extends StatelessWidget {
  /// Creates a new instance of [TransactionsScreen].
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: const Center(child: Text('Transactions Screen')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement Add Transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
