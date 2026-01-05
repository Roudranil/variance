import 'package:drift/drift.dart' hide isNotNull;

import 'package:variance/core/utils/logger.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// Provides integrity verification functions for double-entry bookkeeping.
///
/// This service validates that the database maintains DEB invariants:
/// - Every transaction has balanced ledger entries (sum debits = sum credits)
/// - Account balances are correctly computed from ledger entries
/// - The global accounting equation holds (Assets = Liabilities + Equity + Net
///   Income)
class IntegrityService {
  final AppDatabase _db;

  /// Creates a new instance of [IntegrityService].
  ///
  /// Parameters:
  /// - [db]: The database instance to use.
  IntegrityService(this._db);

  /// Checks if a specific transaction is balanced.
  ///
  /// A transaction is balanced when sum(debits) = sum(credits) for all its
  /// ledger entries.
  ///
  /// Returns true if the transaction is balanced.
  ///
  /// Parameters:
  /// - [transactionId]: The unique identifier of the transaction.
  Future<bool> checkTransactionBalance(int transactionId) async {
    final entries = await (_db.select(
      _db.ledgerEntries,
    )..where((e) => e.transactionId.equals(transactionId))).get();

    double debitSum = 0.0;
    double creditSum = 0.0;

    for (final entry in entries) {
      if (entry.side == LedgerSide.debit) {
        debitSum += entry.amount;
      } else {
        creditSum += entry.amount;
      }
    }

    // allow for small floating point tolerance
    final isBalanced = (debitSum - creditSum).abs() < 0.01;
    if (!isBalanced) {
      VarianceLogger.warning(
        'Transaction $transactionId unbalanced: debits=$debitSum, credits=$creditSum',
      );
    }
    return isBalanced;
  }

  /// Checks if all non-void transactions are balanced.
  ///
  /// Returns a list of transaction IDs that are NOT balanced. Empty list means
  /// all transactions are valid.
  Future<List<int>> checkAllTransactionsBalance() async {
    final transactions = await (_db.select(
      _db.transactions,
    )..where((t) => t.isVoid.equals(false))).get();

    VarianceLogger.debug(
      'Checking balance for ${transactions.length} transactions',
    );

    final unbalanced = <int>[];

    for (final tx in transactions) {
      final isBalanced = await checkTransactionBalance(tx.id);
      if (!isBalanced) {
        unbalanced.add(tx.id);
      }
    }

    if (unbalanced.isNotEmpty) {
      VarianceLogger.error(
        'Found ${unbalanced.length} unbalanced transactions: $unbalanced',
      );
    } else {
      VarianceLogger.info('All transactions are balanced');
    }

    return unbalanced;
  }

  /// Computes the balance of an account from ledger entries.
  ///
  /// Balance calculation depends on [AccountNature]:
  /// - ASSET, EXPENSE: balance = sum(debits) - sum(credits)
  /// - LIABILITY, EQUITY, INCOME: balance = sum(credits) - sum(debits)
  ///
  /// Only non-void transactions are included.
  ///
  /// Returns the computed balance.
  ///
  /// Parameters:
  /// - [accountId]: The unique identifier of the account.
  Future<double> computeAccountBalance(int accountId) async {
    // fetch account to determine nature
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(accountId))).getSingleOrNull();

    if (account == null) return 0.0;

    // fetch all ledger entries for this account from non-void transactions
    final query =
        _db.select(_db.ledgerEntries).join([
            innerJoin(
              _db.transactions,
              _db.transactions.id.equalsExp(_db.ledgerEntries.transactionId),
            ),
          ])
          ..where(_db.ledgerEntries.accountId.equals(accountId))
          ..where(_db.transactions.isVoid.equals(false));

    final entries = await query.get();

    double debitSum = 0.0;
    double creditSum = 0.0;

    for (final row in entries) {
      final entry = row.readTable(_db.ledgerEntries);
      if (entry.side == LedgerSide.debit) {
        debitSum += entry.amount;
      } else {
        creditSum += entry.amount;
      }
    }

    // calculate balance based on nature
    if (account.nature == AccountNature.asset ||
        account.nature == AccountNature.expense) {
      return debitSum - creditSum;
    } else {
      return creditSum - debitSum;
    }
  }

  /// Computes balances for all accounts.
  ///
  /// Returns a map of account ID to computed balance.
  Future<Map<int, double>> computeAllBalances() async {
    final accounts = await _db.select(_db.accounts).get();
    final balances = <int, double>{};

    for (final account in accounts) {
      balances[account.id] = await computeAccountBalance(account.id);
    }

    return balances;
  }

  /// Checks the global accounting equation.
  ///
  /// The equation: Assets = Liabilities + Equity + (Income - Expenses)
  ///
  /// Returns a [GlobalEquationResult] with the computed values and whether the
  /// equation holds.
  Future<GlobalEquationResult> checkGlobalEquation() async {
    final accounts = await (_db.select(
      _db.accounts,
    )..where((a) => a.isDeleted.equals(false))).get();

    double assets = 0.0;
    double liabilities = 0.0;
    double equity = 0.0;
    double income = 0.0;
    double expenses = 0.0;

    for (final account in accounts) {
      final balance = await computeAccountBalance(account.id);

      switch (account.nature) {
        case AccountNature.asset:
          assets += balance;
        case AccountNature.liability:
          liabilities += balance;
        case AccountNature.equity:
          equity += balance;
        case AccountNature.income:
          income += balance;
        case AccountNature.expense:
          expenses += balance;
      }
    }

    // equation: Assets = Liabilities + Equity + (Income - Expenses)
    final lhs = assets;
    final rhs = liabilities + equity + (income - expenses);
    final isBalanced = (lhs - rhs).abs() < 0.01;

    if (isBalanced) {
      VarianceLogger.info(
        'Global equation balanced: Assets=$assets, Liab=$liabilities, Equity=$equity, Net=${income - expenses}',
      );
    } else {
      VarianceLogger.error(
        'Global equation UNBALANCED: LHS=$lhs, RHS=$rhs, diff=${(lhs - rhs).abs()}',
      );
    }

    return GlobalEquationResult(
      assets: assets,
      liabilities: liabilities,
      equity: equity,
      income: income,
      expenses: expenses,
      isBalanced: isBalanced,
    );
  }

  /// Checks if an account can be soft-deleted.
  ///
  /// An account can only be deleted if its balance is zero.
  ///
  /// Returns true if the account balance is zero (within tolerance).
  ///
  /// Parameters:
  /// - [accountId]: The unique identifier of the account.
  Future<bool> canSoftDeleteAccount(int accountId) async {
    final balance = await computeAccountBalance(accountId);
    return balance.abs() < 0.01;
  }
}

/// Result of the global accounting equation check.
///
/// Contains the computed totals for each account nature and whether the
/// equation holds.
class GlobalEquationResult {
  /// Total of all asset account balances.
  final double assets;

  /// Total of all liability account balances.
  final double liabilities;

  /// Total of all equity account balances.
  final double equity;

  /// Total of all income account balances.
  final double income;

  /// Total of all expense account balances.
  final double expenses;

  /// Whether the accounting equation holds.
  ///
  /// True if Assets = Liabilities + Equity + (Income - Expenses).
  final bool isBalanced;

  /// Creates a new instance of [GlobalEquationResult].
  GlobalEquationResult({
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.income,
    required this.expenses,
    required this.isBalanced,
  });

  /// The net income (Income - Expenses).
  double get netIncome => income - expenses;

  /// The left-hand side of the equation (Assets).
  double get lhs => assets;

  /// The right-hand side of the equation (Liabilities + Equity + Net Income).
  double get rhs => liabilities + equity + netIncome;

  @override
  String toString() {
    return 'GlobalEquationResult('
        'assets: $assets, '
        'liabilities: $liabilities, '
        'equity: $equity, '
        'income: $income, '
        'expenses: $expenses, '
        'isBalanced: $isBalanced)';
  }
}
