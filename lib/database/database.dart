import 'package:drift/drift.dart';

import 'package:variance/database/enums.dart';
import 'package:variance/database/schema.dart';
import 'package:variance/database/setup/native.dart';

part 'database.g.dart';

/// The main database class for the application.
///
/// Configures tables and provides access to the underlying SQLite database.
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
  /// Creates a new instance of [AppDatabase].
  ///
  /// Initializes the database connection using the native platform implementation.
  AppDatabase() : super(openConnection());

  /// Creates a new instance of [AppDatabase] for testing purposes.
  ///
  /// Parameters:
  /// - [e]: The query executor to use (e.g., in-memory).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
