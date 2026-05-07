// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $PayeesTable get payees => attachedDatabase.payees;
  $RecurringTemplatesTable get recurringTemplates =>
      attachedDatabase.recurringTemplates;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $EntriesTable get entries => attachedDatabase.entries;
  TransactionDaoManager get managers => TransactionDaoManager(this);
}

class TransactionDaoManager {
  final _$TransactionDaoMixin _db;
  TransactionDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$PayeesTableTableManager get payees =>
      $$PayeesTableTableManager(_db.attachedDatabase, _db.payees);
  $$RecurringTemplatesTableTableManager get recurringTemplates =>
      $$RecurringTemplatesTableTableManager(
          _db.attachedDatabase, _db.recurringTemplates);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db.attachedDatabase, _db.entries);
}
