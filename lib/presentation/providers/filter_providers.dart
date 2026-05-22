// lib/presentation/providers/filter_providers.dart
//
// Riverpod state for transaction list filters (T-59).
//
// FilterState holds all active filter criteria:
//   - types: selected TransactionType values
//   - accountIds: selected account UUIDs (multi-select)
//   - categoryIds: selected category UUIDs (multi-select)
//   - dateRange: optional DateTimeRange for transaction date filter
//   - minAmountMinor / maxAmountMinor: optional amount range in minor units
//
// Filter state does NOT persist across navigation (PRD §5.2.6).
// FilterNotifier.clear() resets all criteria.
//
// Test cases (see test/presentation/features/transactions/filter_sheet_test.dart):
//   1. initial state is empty
//   2. setTypes updates types
//   3. setAccountIds updates accountIds
//   4. setCategoryIds updates categoryIds
//   5. clear resets all fields
//   6. setDateRange updates date range
//   7. setAmountRange updates amount range
//   8. hasActiveFilters returns false when all empty
//   9. hasActiveFilters returns true when any field set

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/transaction.dart';

part 'filter_providers.g.dart';

// ---------------------------------------------------------------------------
// FilterState (immutable value object)
// ---------------------------------------------------------------------------

/// Immutable snapshot of all active transaction list filters.
///
/// All fields default to empty / null (no filters active).
class FilterState {
  /// Creates a [FilterState].
  ///
  /// Parameters:
  /// - [types]: Active transaction type filters.
  /// - [accountIds]: Active account UUID filters.
  /// - [categoryIds]: Active category UUID filters.
  /// - [dateRange]: Optional date range filter.
  /// - [minAmountMinor]: Lower bound of amount range in minor units.
  /// - [maxAmountMinor]: Upper bound of amount range in minor units.
  const FilterState({
    this.types = const [],
    this.accountIds = const [],
    this.categoryIds = const [],
    this.dateRange,
    this.minAmountMinor,
    this.maxAmountMinor,
  });

  /// Selected transaction type filters.
  final List<TransactionType> types;

  /// Selected account UUID filters.
  final List<String> accountIds;

  /// Selected category UUID filters.
  final List<String> categoryIds;

  /// Optional date range filter.
  final DateTimeRange? dateRange;

  /// Lower bound of the amount range filter in minor units (e.g. 5000 = ₹50).
  final int? minAmountMinor;

  /// Upper bound of the amount range filter in minor units.
  final int? maxAmountMinor;

  /// True when at least one filter criterion is active.
  bool get hasActiveFilters =>
      types.isNotEmpty ||
      accountIds.isNotEmpty ||
      categoryIds.isNotEmpty ||
      dateRange != null ||
      minAmountMinor != null ||
      maxAmountMinor != null;

  /// Returns a copy with only the specified fields replaced.
  FilterState copyWith({
    List<TransactionType>? types,
    List<String>? accountIds,
    List<String>? categoryIds,
    Object? dateRange = _sentinel,
    Object? minAmountMinor = _sentinel,
    Object? maxAmountMinor = _sentinel,
  }) {
    return FilterState(
      types: types ?? this.types,
      accountIds: accountIds ?? this.accountIds,
      categoryIds: categoryIds ?? this.categoryIds,
      dateRange:
          dateRange == _sentinel ? this.dateRange : dateRange as DateTimeRange?,
      minAmountMinor: minAmountMinor == _sentinel
          ? this.minAmountMinor
          : minAmountMinor as int?,
      maxAmountMinor: maxAmountMinor == _sentinel
          ? this.maxAmountMinor
          : maxAmountMinor as int?,
    );
  }
}

// Sentinel object used to distinguish "not provided" from explicit null in
// copyWith.
const _sentinel = Object();

// ---------------------------------------------------------------------------
// FilterNotifier
// ---------------------------------------------------------------------------

/// Manages the [FilterState] for the transaction list filter panel (T-59).
///
/// State does NOT persist across navigation — it is auto-disposed when the
/// filter sheet is closed. The notifier auto-disposes (default Riverpod
/// behaviour) when its last listener is removed.
@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  FilterState build() => const FilterState();

  /// Replaces the active type filters.
  ///
  /// Parameters:
  /// - [types]: New set of selected [TransactionType] values.
  void setTypes(List<TransactionType> types) {
    state = state.copyWith(types: types);
  }

  /// Replaces the active account UUID filters.
  ///
  /// Parameters:
  /// - [accountIds]: New set of selected account UUIDs.
  void setAccountIds(List<String> accountIds) {
    state = state.copyWith(accountIds: accountIds);
  }

  /// Replaces the active category UUID filters.
  ///
  /// Parameters:
  /// - [categoryIds]: New set of selected category UUIDs.
  void setCategoryIds(List<String> categoryIds) {
    state = state.copyWith(categoryIds: categoryIds);
  }

  /// Updates the date range filter.
  ///
  /// Pass null to clear the date range.
  ///
  /// Parameters:
  /// - [range]: The new [DateTimeRange] or null to clear.
  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  /// Updates the amount range filter (both bounds at once).
  ///
  /// Parameters:
  /// - [minMinor]: Lower bound in minor units. Pass null to clear.
  /// - [maxMinor]: Upper bound in minor units. Pass null to clear.
  void setAmountRange({int? minMinor, int? maxMinor}) {
    state = state.copyWith(
      minAmountMinor: minMinor,
      maxAmountMinor: maxMinor,
    );
  }

  /// Resets all filter criteria to empty / unset.
  void clear() {
    state = const FilterState();
  }
}
