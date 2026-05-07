// lib/domain/repositories/i_tag_repository.dart
//
// Abstract repository interface for the Tag aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/tag.dart';

/// Contract for all Tag data-access operations.
abstract interface class ITagRepository {
  /// Watches all tags.
  Stream<List<Tag>> watchAll();

  /// Creates a new tag with [name].
  Future<Result<Tag>> create(String name);

  /// Renames the tag with [id].
  Future<Result<Tag>> rename(String id, String name);

  /// Soft-deletes the tag with [id].
  Future<Result<void>> softDelete(String id);
}
