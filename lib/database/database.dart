import 'package:drift/drift.dart';

import 'package:variance/database/enums.dart';
import 'package:variance/database/schema.dart';

import 'setup/native.dart';
part 'database.g.dart';

/// The main database class for the Variance application.
///
/// Configures all tables and provides access to the underlying SQLite database.
/// Uses Drift for type-safe database operations.
@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Tags,
    Transactions,
    LedgerEntries,
    TransactionTags,
    RecurringPatterns,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates a new instance of [AppDatabase].
  ///
  /// Initializes the database connection using the native platform
  /// implementation.
  AppDatabase() : super(openConnection());

  /// Creates a new instance of [AppDatabase] for testing purposes.
  ///
  /// Parameters:
  /// - [e]: The query executor to use (e.g., in-memory database).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;
}
