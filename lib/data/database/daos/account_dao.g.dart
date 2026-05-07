// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_dao.dart';

// ignore_for_file: type=lint
mixin _$AccountDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $AccountDetailsTable get accountDetails => attachedDatabase.accountDetails;
  AccountDaoManager get managers => AccountDaoManager(this);
}

class AccountDaoManager {
  final _$AccountDaoMixin _db;
  AccountDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$AccountDetailsTableTableManager get accountDetails =>
      $$AccountDetailsTableTableManager(
          _db.attachedDatabase, _db.accountDetails);
}
