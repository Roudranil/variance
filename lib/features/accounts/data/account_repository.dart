import 'package:drift/drift.dart' hide isNotNull;

import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// Manages [Accounts] entities.
///
/// Responsibilities:
/// - Creating new accounts with initial balances.
/// - Updating account details (name, type, limits).
/// - Watching account balances for the UI.
class AccountRepository {
  final AppDatabase _db;

  AccountRepository(this._db);

  /// Watches all accounts ordered by name.
  ///
  /// Excludes deleted accounts.
  Stream<List<Account>> watchAllAccounts() {
    return (_db.select(_db.accounts)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Gets a single account by ID.
  ///
  /// Parameters:
  /// - [id]: The ID of the account to fetch.
  Future<Account?> getAccount(int id) {
    return (_db.select(
      _db.accounts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Creates a new account and persists it to the database.
  ///
  /// The account is initialized with [initialBalance], which is also used as the
  /// initial value for the current balance.
  ///
  /// Returns the unique identifier of the newly created account.
  ///
  /// Parameters:
  /// - [name]: The display name of the account.
  /// - [type]: The type of account.
  /// - [initialBalance]: The starting balance.
  /// - [currencyCode]: ISO 4217 currency code. Defaults to `'INR'`.
  /// - [includeInTotals]: Whether the account is included in net worth totals.
  /// - [statementDay]: Credit card statement day (1–31).
  /// - [paymentDueDay]: Credit card payment due day (1–31).
  /// - [interestRate]: Annual interest rate, if applicable.
  Future<int> createAccount({
    /// The display name of the account.
    required String name,

    /// The type of account (for example, cash, bank account, or credit card).
    required AccountType type,

    /// The starting balance of the account.
    required double initialBalance,

    /// ISO 4217 currency code for the account.
    ///
    /// Defaults to `'INR'`.
    String currencyCode = 'INR',

    /// Whether this account is included in net worth calculations.
    ///
    /// Defaults to `true`.
    bool includeInTotals = true,

    /// The day of the month (1–31) on which a credit card statement is generated.
    ///
    /// Applicable only to credit card accounts.
    int? statementDay,

    /// The day of the month (1–31) on which a credit card payment is due.
    ///
    /// Applicable only to credit card accounts.
    int? paymentDueDay,

    /// The annual interest rate applied to the account, if applicable.
    double? interestRate,
  }) {
    return _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: name,
            type: type,
            initialBalance: Value(initialBalance),
            currentBalance: Value(initialBalance),
            currencyCode: Value(currencyCode),
            includeInTotals: Value(includeInTotals),
            statementDay: Value(statementDay),
            paymentDueDay: Value(paymentDueDay),
            interestRate: Value(interestRate),
          ),
        );
  }

  /// Updates an existing account.
  ///
  /// If [currentBalance] is changed, creates an 'adjustment' Transaction.
  ///
  /// Parameters:
  /// - [account]: The account object with updated values.
  Future<void> updateAccount(Account account) async {
    return _db.transaction(() async {
      // 1. Fetch old account state to check for balance change
      final oldAccount = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(account.id))).getSingle();

      // 2. Check for Balance Discrepancy
      if (oldAccount.currentBalance != account.currentBalance) {
        final diff = account.currentBalance - oldAccount.currentBalance;
        // If diff is positive: Income/Adjustment (+). If negative: Expense/Adjustment (-)
        // We use ABS(diff) for amount and rely on logic or context if needed?
        // Actually, just creating a transaction with 'adjustment' type.
        // For adjustment, we can assign it to the account.
        // If diff is positive: 'Income' semantics (but type=adjustment). Destination = Account.
        // If diff is negative: 'Expense' semantics. Source = Account.

        final isPositive = diff > 0;
        await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion.insert(
                amount: diff.abs(),
                type: TransactionType.adjustment,
                transactionDate: DateTime.now(),
                // If positive, money came INTO account
                destinationAccountId: isPositive
                    ? Value(account.id)
                    : const Value(null),
                // If negative, money left account
                sourceAccountId: isPositive
                    ? const Value(null)
                    : Value(account.id),
                description: const Value('Manual Balance Adjustment'),
              ),
            );
      }

      // 3. Update the Account record
      await _db.update(_db.accounts).replace(account);
    });
  }

  /// Soft deletes an account.
  ///
  /// Parameters:
  /// - [id]: The ID of the account to delete.
  Future<void> deleteAccount(int id) {
    return (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(id))).write(
      AccountsCompanion(isDeleted: const Value(true)),
    );
  }
}
