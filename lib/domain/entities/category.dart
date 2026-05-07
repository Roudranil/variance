// lib/domain/entities/category.dart
//
// Category domain entity.
//
// Two-level hierarchy (parent/child). Income and expense trees are separate.
// System-protected categories (Balance Adjustment, Fees & Charges) cannot be
// deleted. parent_id = null means top-level (root) category.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// Which category tree this category belongs to.
enum CategoryTreeType {
  income,
  expense,
}

/// Immutable domain entity for a transaction category.
@freezed
abstract class Category with _$Category {
  const factory Category({
    /// UUID v4 stable identifier.
    required String id,

    /// Parent category UUID; null for root categories.
    String? parentId,

    /// Income or expense tree.
    required CategoryTreeType treeType,

    /// Display name; unique within tree/parent (case-insensitive, incl. soft-deleted).
    required String name,

    /// Material Symbols icon identifier.
    required String iconRef,

    /// Soft-delete flag.
    @Default(false) bool isDeleted,

    /// Soft-delete epoch (Unix seconds); set when [isDeleted] becomes true.
    int? deletedAt,

    /// True for BAI/BAE and "Balance Adjustment" parent; blocks deletion.
    @Default(false) bool isProtected,

    /// Manual sort order; null = alphabetical (v1 default).
    int? sortOrder,

    /// Creation epoch (Unix seconds).
    required int createdAt,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,
  }) = _Category;
}
