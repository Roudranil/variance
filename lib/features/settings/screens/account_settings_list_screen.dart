import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:variance/core/utils/logger.dart';
import 'package:variance/core/utils/search_algorithm.dart';
import 'package:variance/core/widgets/grouped_list_card.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';
import 'package:variance/features/settings/screens/account_edit_screen.dart';
import 'package:variance/features/settings/widgets/account_type_menu.dart';

/// Screen for managing accounts from the Settings section.
///
/// Displays a list of accounts grouped by [AccountType], with search
/// functionality and options to add, edit, or delete accounts.
class AccountSettingsListScreen extends StatefulWidget {
  /// Creates a new instance of [AccountSettingsListScreen].
  const AccountSettingsListScreen({super.key});

  @override
  State<AccountSettingsListScreen> createState() =>
      _AccountSettingsListScreenState();
}

class _AccountSettingsListScreenState extends State<AccountSettingsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Account',
            onPressed: () => _showAddAccountMenu(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export', child: Text('Export')),
              const PopupMenuItem(value: 'reorder', child: Text('Reorder')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search accounts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
                  128,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Account>>(
              stream: db.accountRepository.watchAllAccounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  VarianceLogger.error(
                    'Error loading accounts: ${snapshot.error}',
                  );
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final accounts = snapshot.data ?? [];
                final filtered = _searchQuery.isEmpty
                    ? accounts
                    : SearchAlgorithmV1.search(
                        items: accounts,
                        query: _searchQuery,
                        getSearchableFields: (a) => [
                          a.name,
                          a.type?.name ?? '',
                        ],
                      );

                final grouped = _groupByType(filtered);

                if (grouped.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No accounts yet'
                              : 'No matching accounts',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  children: grouped.entries.map((entry) {
                    return _buildAccountTypeCard(
                      context,
                      entry.key,
                      entry.value,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<AccountType, List<Account>> _groupByType(List<Account> accounts) {
    final grouped = <AccountType, List<Account>>{};
    for (final account in accounts) {
      final type = account.type;
      if (type == null) continue;
      grouped.putIfAbsent(type, () => []).add(account);
    }
    return grouped;
  }

  Widget _buildAccountTypeCard(
    BuildContext context,
    AccountType type,
    List<Account> accounts,
  ) {
    return GroupedListCard(
      title: _accountTypeLabel(type),
      leadingIcon: _accountTypeIcon(type),
      children: accounts.asMap().entries.expand((entry) {
        final index = entry.key;
        final account = entry.value;
        return [
          ListTile(
            title: Text(account.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToEdit(context, account),
          ),
          if (index < accounts.length - 1)
            Divider(height: 8, color: Theme.of(context).colorScheme.surface),
        ];
      }).toList(),
    );
  }

  String _accountTypeLabel(AccountType type) {
    return switch (type) {
      AccountType.cash => 'Cash',
      AccountType.savings => 'Savings',
      AccountType.bankAccount => 'Bank Accounts',
      AccountType.creditCard => 'Credit Cards',
      AccountType.loan => 'Loans',
      AccountType.investment => 'Investments',
      AccountType.insurance => 'Insurance',
      AccountType.wallet => 'Wallets',
    };
  }

  IconData _accountTypeIcon(AccountType type) {
    return switch (type) {
      AccountType.cash => Icons.payments_outlined,
      AccountType.savings => Icons.savings_outlined,
      AccountType.bankAccount => Icons.account_balance_outlined,
      AccountType.creditCard => Icons.credit_card_outlined,
      AccountType.loan => Icons.request_quote_outlined,
      AccountType.investment => Icons.trending_up_outlined,
      AccountType.insurance => Icons.health_and_safety_outlined,
      AccountType.wallet => Icons.account_balance_wallet_outlined,
    };
  }

  void _showAddAccountMenu(BuildContext context) {
    showModalBottomSheet<AccountType>(
      context: context,
      builder: (context) => const AccountTypeMenu(),
    ).then((type) {
      if (type != null) _navigateToAdd(context, type);
    });
  }

  void _navigateToEdit(BuildContext context, Account account) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AccountEditScreen(account: account),
      ),
    );
  }

  void _navigateToAdd(BuildContext context, AccountType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AccountEditScreen(accountType: type),
      ),
    );
  }

  void _handleMenuAction(String action) {
    VarianceLogger.info('Menu action: $action');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action coming soon!')));
  }
}
