import 'package:drift/drift.dart';

import 'package:variance/database/schema.dart';
import 'package:variance/database/setup/native.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Tags,
    Transactions,
    TransactionTags,
    RecurringPatterns,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  // Constructor for testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
