// lib/domain/repositories/i_draft_repository.dart
//
// Abstract repository interface for the Draft aggregate.

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/draft.dart';

/// Contract for Draft (auto-saved form state) data-access operations.
abstract interface class IDraftRepository {
  /// Watches all drafts, ordered by creation epoch (oldest first).
  ///
  /// Max 5 rows enforced by the data layer (FIFO eviction).
  Stream<List<Draft>> watchAll();

  /// Creates or replaces a draft for the given [draft.id].
  Future<Result<Draft>> upsert(Draft draft);

  /// Permanently deletes the draft with [id].
  Future<Result<void>> delete(String id);
}
