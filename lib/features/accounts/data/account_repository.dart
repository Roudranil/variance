import 'package:drift/drift.dart' hide isNotNull;

import 'package:variance/core/utils/logger.dart';
import 'package:variance/database/database.dart';
import 'package:variance/database/enums.dart';

/// Manages [Accounts] entities and computes balances from ledger entries.
///
/// In the DEB system, account balances are computed from [LedgerEntries] rather
/// than being stored as cached values. This repository provides methods to
/// create accounts, compute their balances, and manage the Opening Balances
/// equity account.
class AccountRepository {
  final AppDatabase _db;

  /// The name of the system equity account used for opening balances.
  static const String openingBalancesAccountName = 'Opening Balances';

  /// Creates a new instance of [AccountRepository].
  ///
  /// Parameters:
  /// - [db]: The database instance to use.
  AccountRepository(this._db);

  /// Watches all user-visible accounts ordered by name.
  ///
  /// Excludes deleted accounts and system accounts (categories, equity).
  ///
  /// Returns a [Stream] of [Account] lists that updates when data changes.
  Stream<List<Account>> watchAllAccounts() {
    return (_db.select(_db.accounts)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..where((tbl) => tbl.isUserVisible.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Gets a single account by ID.
  ///
  /// Returns null if the account does not exist.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the account.
  Future<Account?> getAccount(int id) {
    return (_db.select(
      _db.accounts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Computes the current balance of an account from ledger entries.
  ///
  /// Balance calculation depends on [AccountNature]:
  /// - ASSET, EXPENSE: balance = sum(debits) - sum(credits)
  /// - LIABILITY, EQUITY, INCOME: balance = sum(credits) - sum(debits)
  ///
  /// Only non-void transactions are included in the calculation.
  ///
  /// Returns the computed balance as a [double].
  ///
  /// Parameters:
  /// - [accountId]: The unique identifier of the account.
  Future<double> getAccountBalance(int accountId) async {
    final account = await getAccount(accountId);
    if (account == null) return 0.0;

    // join ledger entries with transactions to filter out voided ones
    final query =
        _db.selectOnly(_db.ledgerEntries).join([
            innerJoin(
              _db.transactions,
              _db.transactions.id.equalsExp(_db.ledgerEntries.transactionId),
            ),
          ])
          ..where(_db.ledgerEntries.accountId.equals(accountId))
          ..where(_db.transactions.isVoid.equals(false));

    // calculate sum of debits
    final debitSum = _db.ledgerEntries.amount.sum(
      filter: _db.ledgerEntries.side.equalsValue(LedgerSide.debit),
    );

    // calculate sum of credits
    final creditSum = _db.ledgerEntries.amount.sum(
      filter: _db.ledgerEntries.side.equalsValue(LedgerSide.credit),
    );

    query.addColumns([debitSum, creditSum]);

    final result = await query.getSingle();
    final debits = result.read(debitSum) ?? 0.0;
    final credits = result.read(creditSum) ?? 0.0;

    // calculate balance based on account nature
    final nature = account.nature;
    if (nature == AccountNature.asset || nature == AccountNature.expense) {
      return debits - credits;
    } else {
      // liability, equity, income
      return credits - debits;
    }
  }

  /// Creates a new user-visible account with an opening balance.
  ///
  /// This method performs the following in a single transaction:
  /// 1. Creates the account record.
  /// 2. If [initialBalance] is non-zero, creates an opening balance transaction
  ///    against the Opening Balances equity account.
  ///
  /// Returns the unique identifier of the newly created account.
  ///
  /// Parameters:
  /// - [name]: The display name of the account.
  /// - [type]: The user-facing account type for UI grouping.
  /// - [nature]: The accounting nature (determines debit/credit behavior).
  /// - [initialBalance]: The starting balance. Defaults to `0.0`.
  /// - [currencyCode]: ISO 4217 currency code. Defaults to `'INR'`.
  /// - [includeInTotals]: Whether to include in net worth. Defaults to `true`.
  /// - [statementDay]: Credit card statement day (1-31).
  /// - [paymentDueDay]: Credit card payment due day (1-31).
  /// - [creditLimit]: Credit card limit.
  /// - [interestRate]: Annual interest rate.
  /// - [principal]: Loan principal amount.
  /// - [installmentAmount]: Loan EMI amount.
  /// - [nextDueDate]: Loan next payment date.
  /// - [maturityDate]: Savings/FD maturity date.
  /// - [color]: Optional custom color for theming (as int value).
  /// - [description]: Optional description for the account.
  Future<int> createAccount({
    required String name,
    required AccountType type,
    required AccountNature nature,
    double initialBalance = 0.0,
    String currencyCode = 'INR',
    bool includeInTotals = true,
    int? statementDay,
    int? paymentDueDay,
    double? creditLimit,
    double? interestRate,
    double? principal,
    double? installmentAmount,
    DateTime? nextDueDate,
    DateTime? maturityDate,
    int? color,
    String? description,
  }) async {
    return _db.transaction(() async {
      // create the account
      final accountId = await _db
          .into(_db.accounts)
          .insert(
            AccountsCompanion.insert(
              name: name,
              type: Value(type),
              nature: nature,
              isUserVisible: const Value(true),
              currencyCode: Value(currencyCode),
              includeInTotals: Value(includeInTotals),
              statementDay: Value(statementDay),
              paymentDueDay: Value(paymentDueDay),
              creditLimit: Value(creditLimit),
              interestRate: Value(interestRate),
              principal: Value(principal),
              installmentAmount: Value(installmentAmount),
              nextDueDate: Value(nextDueDate),
              maturityDate: Value(maturityDate),
              color: Value(color),
              description: Value(description),
            ),
          );

      // create opening balance transaction if needed
      if (initialBalance != 0.0) {
        await _createOpeningBalanceTransaction(
          accountId: accountId,
          accountNature: nature,
          amount: initialBalance.abs(),
          isPositive: initialBalance > 0,
        );
        VarianceLogger.debug(
          'Created opening balance transaction for account $accountId: $initialBalance',
        );
      }

      VarianceLogger.info(
        'Created account "$name" (id=$accountId, type=$type, nature=$nature)',
      );
      return accountId;
    });
  }

  /// Updates an existing account's metadata.
  ///
  /// This method does NOT allow balance changes. To adjust a balance, use
  /// [TransactionRepository.createAdjustment].
  ///
  /// Parameters:
  /// - [account]: The account object with updated values.
  Future<void> updateAccount(Account account) async {
    await (_db.update(
      _db.accounts,
    )..where((a) => a.id.equals(account.id))).write(
      AccountsCompanion(
        name: Value(account.name),
        type: Value(account.type),
        currencyCode: Value(account.currencyCode),
        includeInTotals: Value(account.includeInTotals),
        statementDay: Value(account.statementDay),
        paymentDueDay: Value(account.paymentDueDay),
        creditLimit: Value(account.creditLimit),
        interestRate: Value(account.interestRate),
        principal: Value(account.principal),
        installmentAmount: Value(account.installmentAmount),
        nextDueDate: Value(account.nextDueDate),
        maturityDate: Value(account.maturityDate),
        color: Value(account.color),
        updatedAt: Value(DateTime.now()),
        description: Value(account.description),
      ),
    );
    VarianceLogger.debug('Updated account ${account.id}: ${account.name}');
  }

  /// Checks if an account can be soft-deleted.
  ///
  /// An account can only be deleted if its computed balance is zero.
  ///
  /// Returns true if the account balance is zero (within tolerance).
  ///
  /// Parameters:
  /// - [accountId]: The unique identifier of the account.
  Future<bool> canSoftDelete(int accountId) async {
    final balance = await getAccountBalance(accountId);
    return balance.abs() < 0.01;
  }

  /// Soft deletes an account.
  ///
  /// The account is hidden from the UI but kept for historical integrity.
  /// This method does NOT check if the balance is zero; call [canSoftDelete]
  /// first if needed.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the account.
  Future<void> softDeleteAccount(int id) async {
    await (_db.update(_db.accounts)..where((tbl) => tbl.id.equals(id))).write(
      AccountsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    VarianceLogger.info('Soft deleted account $id');
  }

  /// Gets or creates the Opening Balances equity account.
  ///
  /// This is a system account used to balance opening balance transactions.
  /// It is not visible to users.
  ///
  /// Returns the account ID.
  Future<int> getOrCreateOpeningBalancesAccount() async {
    // check if it already exists
    final existing =
        await (_db.select(_db.accounts)
              ..where((a) => a.name.equals(openingBalancesAccountName))
              ..where((a) => a.nature.equalsValue(AccountNature.equity)))
            .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    // create it
    final newId = await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: openingBalancesAccountName,
            nature: AccountNature.equity,
            isUserVisible: const Value(false),
            includeInTotals: const Value(false),
          ),
        );
    VarianceLogger.info('Created Opening Balances equity account (id=$newId)');
    return newId;
  }

  /// Creates an opening balance transaction.
  ///
  /// This creates a transaction and ledger entries to establish the initial
  /// balance of an account using the Opening Balances equity account.
  Future<void> _createOpeningBalanceTransaction({
    required int accountId,
    required AccountNature accountNature,
    required double amount,
    required bool isPositive,
  }) async {
    final openingBalancesId = await getOrCreateOpeningBalancesAccount();

    // create the transaction
    final transactionId = await _db
        .into(_db.transactions)
        .insert(
          TransactionsCompanion.insert(
            transactionDate: DateTime.now(),
            type: TransactionType.adjustment,
            userNote: const Value('Opening balance'),
          ),
        );

    // determine debit/credit sides based on account nature and sign
    // for asset/expense accounts: positive balance = debit the account
    // for liability/equity/income accounts: positive balance = credit the account
    LedgerSide accountSide;
    LedgerSide equitySide;

    if (accountNature == AccountNature.asset ||
        accountNature == AccountNature.expense) {
      // asset/expense: positive = debit, negative = credit
      accountSide = isPositive ? LedgerSide.debit : LedgerSide.credit;
      equitySide = isPositive ? LedgerSide.credit : LedgerSide.debit;
    } else {
      // liability/equity/income: positive = credit, negative = debit
      accountSide = isPositive ? LedgerSide.credit : LedgerSide.debit;
      equitySide = isPositive ? LedgerSide.debit : LedgerSide.credit;
    }

    // create ledger entries
    await _db
        .into(_db.ledgerEntries)
        .insert(
          LedgerEntriesCompanion.insert(
            transactionId: transactionId,
            accountId: accountId,
            amount: amount,
            side: accountSide,
          ),
        );

    await _db
        .into(_db.ledgerEntries)
        .insert(
          LedgerEntriesCompanion.insert(
            transactionId: transactionId,
            accountId: openingBalancesId,
            amount: amount,
            side: equitySide,
          ),
        );
  }
}
