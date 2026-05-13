// lib/data/models/category_dto.dart
//
// Data Transfer Object that maps between the Drift-generated Category row
// class and the domain Category entity.
//
// Naming note: The Drift-generated row class for `categories` is also named
// `Category`. To avoid ambiguity, the domain entity is imported with the
// alias `domain`. The Drift row type is imported via show.
//
// Epoch representation: all timestamps in the database are stored as
// INTEGER Unix epoch SECONDS (not milliseconds). The domain entity also
// uses epoch seconds (int fields), so no conversion is needed here.
//
// Test cases (see test/data/models/category_dto_test.dart):
//   1. fromRow + toEntity round-trips all fields without data loss
//   2. tree_type 'income' maps to CategoryTreeType.income
//   3. tree_type 'expense' maps to CategoryTreeType.expense
//   4. unknown tree_type falls back to CategoryTreeType.expense

import 'package:variance/data/database/app_database.dart' show Category;
import 'package:variance/domain/entities/category.dart' as domain;

/// Maps a Drift [Category] row to the domain [domain.Category] entity.
///
/// All type conversions (enum parsing, epoch handling) are centralised here
/// so the repository and DAO remain free of mapping boilerplate.
class CategoryDto {
  /// Creates a [CategoryDto] from a Drift-generated [Category] row.
  ///
  /// Parameters:
  /// - [row]: The Drift row from the `categories` table.
  const CategoryDto.fromRow(this._row);

  final Category _row;

  /// Converts this DTO to the domain [domain.Category] entity.
  ///
  /// Returns a fully populated immutable [domain.Category] instance.
  domain.Category toEntity() {
    return domain.Category(
      id: _row.id,
      parentId: _row.parentId,
      treeType: _treeTypeFromString(_row.treeType),
      name: _row.name,
      iconRef: _row.iconRef,
      isDeleted: _row.isDeleted,
      // deletedAt is stored as INTEGER epoch seconds; domain uses int?
      deletedAt: _row.deletedAt,
      isProtected: _row.isProtected,
      sortOrder: _row.sortOrder,
      createdAt: _row.createdAt,
      updatedAt: _row.updatedAt,
      largeTxnThresholdMinor: _row.largeTxnThresholdMinor,
    );
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  /// Parses a `tree_type` column value to [domain.CategoryTreeType].
  ///
  /// Falls back to [domain.CategoryTreeType.expense] for unrecognised values
  /// as a forward-compatibility guard.
  ///
  /// Parameters:
  /// - [value]: Raw string stored in the `tree_type` column.
  static domain.CategoryTreeType _treeTypeFromString(String value) {
    return switch (value) {
      'income' => domain.CategoryTreeType.income,
      'expense' => domain.CategoryTreeType.expense,
      // Forward-compat guard: unknown values default to expense.
      _ => domain.CategoryTreeType.expense,
    };
  }

  /// Converts a [domain.CategoryTreeType] enum to its database string value.
  ///
  /// Parameters:
  /// - [type]: The enum value to convert.
  static String treeTypeToString(domain.CategoryTreeType type) {
    return switch (type) {
      domain.CategoryTreeType.income => 'income',
      domain.CategoryTreeType.expense => 'expense',
    };
  }
}
