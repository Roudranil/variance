// lib/domain/entities/payee.dart
//
// Payee domain entity.
//
// Optional named payees/merchants attached to transactions.
// Schema-ready in v1; the payee management screen is v2.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'payee.freezed.dart';

/// Immutable domain entity for a payee or merchant.
@freezed
abstract class Payee with _$Payee {
  const factory Payee({
    /// UUID v4 stable identifier.
    required String id,

    /// Payee name; unique (case-insensitive enforced at app layer).
    required String name,

    /// Soft-delete flag.
    @Default(false) bool isDeleted,

    /// Soft-delete epoch (Unix seconds).
    int? deletedAt,

    /// Creation epoch (Unix seconds).
    required int createdAt,

    /// Last-modified epoch (Unix seconds).
    required int updatedAt,
  }) = _Payee;
}
