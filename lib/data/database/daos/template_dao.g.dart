// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_dao.dart';

// ignore_for_file: type=lint
mixin _$TemplateDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $PayeesTable get payees => attachedDatabase.payees;
  $RecurringTemplatesTable get recurringTemplates =>
      attachedDatabase.recurringTemplates;
  $InstallmentPlansTable get installmentPlans =>
      attachedDatabase.installmentPlans;
  TemplateDaoManager get managers => TemplateDaoManager(this);
}

class TemplateDaoManager {
  final _$TemplateDaoMixin _db;
  TemplateDaoManager(this._db);
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
  $$InstallmentPlansTableTableManager get installmentPlans =>
      $$InstallmentPlansTableTableManager(
          _db.attachedDatabase, _db.installmentPlans);
}
