// lib/domain/entities/draft.dart
//
// Draft domain entity.
//
// Auto-saved transaction entry form state. Max 5 rows enforced at app layer
// (FIFO eviction). Not part of the ledger; purely a UX convenience.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft.freezed.dart';

/// Immutable domain entity for an auto-saved form draft.
@freezed
abstract class Draft with _$Draft {
  const factory Draft({
    /// UUID v4 stable identifier.
    required String id,

    /// Serialized form state (JSON string).
    required String payloadJson,

    /// Creation epoch used for FIFO eviction (Unix seconds).
    required int createdAt,

    /// Last auto-save epoch (Unix seconds).
    required int updatedAt,
  }) = _Draft;
}
