// lib/domain/entities/tag.dart
//
// Tag domain entity.
//
// Free-form tags for cross-cutting transaction grouping (many-to-many).
// Schema-ready in v1 but not surfaced in the v1 UI.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

/// Immutable domain entity for a transaction tag.
@freezed
abstract class Tag with _$Tag {
  const factory Tag({
    /// UUID v4 stable identifier.
    required String id,

    /// Tag label; unique (case-insensitive enforced at app layer).
    required String name,

    /// Creation epoch (Unix seconds).
    required int createdAt,
  }) = _Tag;
}
