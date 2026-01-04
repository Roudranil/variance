import 'package:flutter/material.dart';

import 'package:variance/core/utils/logger.dart';

import '../../accounts/screens/accounts_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../transactions/screens/transactions_screen.dart';

/// The main shell of the application.
///
/// This widget manages the bottom navigation bar and switchable content details using [IndexedStack].
class HomeScreen extends StatefulWidget {
  /// Creates a new instance of [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TransactionsScreen(),
    DashboardScreen(),
    AccountsScreen(),
    SettingsScreen(),
  ];

  final List<String> _labels = const [
    'Transactions',
    'Dashboard',
    'Accounts',
    'Settings',
  ];

  void _onDestinationSelected(int index) {
    VarianceLogger.debug('Selected destination: $index');
    VarianceLogger.debug('Selected label: ${_labels[index]}');
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    VarianceLogger.info('Building HomeScreen');
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
