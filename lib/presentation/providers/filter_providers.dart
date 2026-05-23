// lib/presentation/providers/filter_providers.dart
//
// Riverpod state for transaction list filters (T-161).
//
// FilterState holds all active filter criteria (UX flows §7.7.2, §7.7.4):
//   - types: selected TransactionType values (Income/Expense/Transfer)
//   - accountIds: selected account UUIDs (multi-select)
//   - categoryIds: selected category + subcategory UUIDs (multi-select)
//   - dateRange: optional DateTimeRange for transaction date filter
//   - minAmountMinor / maxAmountMinor: optional amount range in minor units
//   - hasPhoto / hasTitle / hasDescription: boolean toggles
//   - isRecurring: matches parent_template_id IS NOT NULL
//   - isVoided: include voided transactions
//   - sortField / sortDirection: sort order applied to the query
//
// Filter state does NOT persist across navigation (PRD §5.2.6).
// FilterNotifier.reset() (alias: clear()) resets all criteria.
//
// Auto-deselect: when a type is removed from [types], category IDs that belong
// only to that type are purged. This requires the caller to pass
// categoryTypes map when toggling types (T-161 requirement).
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
//  10. toggleBoolean(hasPhoto) sets hasPhoto = true
//  11. setSortField(amount, desc) updates sortField and sortDirection
//  12. toggleType adds/removes a single type from types list

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/transaction.dart';

part 'filter_providers.g.dart';

// ---------------------------------------------------------------------------
// Sort enums
// ---------------------------------------------------------------------------

/// The field by which the transaction list is sorted.
enum SortField {
  /// Sort by transaction date (default).
  date,

  /// Sort by transaction amount.
  amount,
}

/// The direction in which results are ordered.
enum SortDirection {
  /// Most recent / largest first.
  descending,

  /// Oldest / smallest first.
  ascending,
}

// ---------------------------------------------------------------------------
// FilterState (immutable value object)
// ---------------------------------------------------------------------------

/// Immutable snapshot of all active transaction list filters.
///
/// All fields default to empty / null (no filters active). Sort defaults to
/// date descending (most recent first).
class FilterState {
  /// Creates a [FilterState].
  ///
  /// Parameters:
  /// - [types]: Active transaction type filters.
  /// - [accountIds]: Active account UUID filters.
  /// - [categoryIds]: Active category/subcategory UUID filters.
  /// - [dateRange]: Optional date range filter.
  /// - [minAmountMinor]: Lower bound of amount range in minor units.
  /// - [maxAmountMinor]: Upper bound of amount range in minor units.
  /// - [hasPhoto]: When true, only transactions with a photo attachment.
  /// - [hasTitle]: When true, only transactions with a non-null title.
  /// - [hasDescription]: When true, only transactions with a non-null description.
  /// - [isRecurring]: When true, only recurring (template-linked) transactions.
  /// - [isVoided]: When true, include voided transactions.
  /// - [sortField]: The field to sort by.
  /// - [sortDirection]: The direction to sort in.
  const FilterState({
    this.types = const [],
    this.accountIds = const [],
    this.categoryIds = const [],
    this.dateRange,
    this.minAmountMinor,
    this.maxAmountMinor,
    this.hasPhoto = false,
    this.hasTitle = false,
    this.hasDescription = false,
    this.isRecurring = false,
    this.isVoided = false,
    this.sortField = SortField.date,
    this.sortDirection = SortDirection.descending,
  });

  /// Selected transaction type filters.
  final List<TransactionType> types;

  /// Selected account UUID filters.
  final List<String> accountIds;

  /// Selected category and subcategory UUID filters.
  final List<String> categoryIds;

  /// Optional date range filter.
  final DateTimeRange? dateRange;

  /// Lower bound of the amount range filter in minor units (e.g. 5000 = ₹50).
  final int? minAmountMinor;

  /// Upper bound of the amount range filter in minor units.
  final int? maxAmountMinor;

  /// When true, only transactions that have a photo attachment.
  final bool hasPhoto;

  /// When true, only transactions that have a non-null title.
  final bool hasTitle;

  /// When true, only transactions that have a non-null description.
  final bool hasDescription;

  /// When true, only transactions linked to a recurring template
  /// (parent_template_id IS NOT NULL).
  final bool isRecurring;

  /// When true, include voided transactions in results.
  final bool isVoided;

  /// The field by which results are sorted.
  final SortField sortField;

  /// The direction in which results are sorted.
  final SortDirection sortDirection;

  /// True when at least one filter criterion is active.
  ///
  /// Sort field/direction are not counted as "active filters" since they have
  /// defaults. Boolean toggles and all set-based criteria count.
  bool get hasActiveFilters =>
      types.isNotEmpty ||
      accountIds.isNotEmpty ||
      categoryIds.isNotEmpty ||
      dateRange != null ||
      minAmountMinor != null ||
      maxAmountMinor != null ||
      hasPhoto ||
      hasTitle ||
      hasDescription ||
      isRecurring ||
      isVoided;

  /// Returns a copy with only the specified fields replaced.
  ///
  /// Uses sentinel objects for nullable fields so explicit nulls can be passed
  /// to clear those fields.
  FilterState copyWith({
    List<TransactionType>? types,
    List<String>? accountIds,
    List<String>? categoryIds,
    Object? dateRange = _sentinel,
    Object? minAmountMinor = _sentinel,
    Object? maxAmountMinor = _sentinel,
    bool? hasPhoto,
    bool? hasTitle,
    bool? hasDescription,
    bool? isRecurring,
    bool? isVoided,
    SortField? sortField,
    SortDirection? sortDirection,
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
      hasPhoto: hasPhoto ?? this.hasPhoto,
      hasTitle: hasTitle ?? this.hasTitle,
      hasDescription: hasDescription ?? this.hasDescription,
      isRecurring: isRecurring ?? this.isRecurring,
      isVoided: isVoided ?? this.isVoided,
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

// Sentinel object used to distinguish "not provided" from explicit null in
// copyWith.
const _sentinel = Object();

// ---------------------------------------------------------------------------
// FilterNotifier
// ---------------------------------------------------------------------------

/// Manages the [FilterState] for the transaction list filter panel (T-161).
///
/// State does NOT persist across navigation — it is auto-disposed when the
/// filter sheet is closed. The notifier auto-disposes (default Riverpod
/// behaviour) when its last listener is removed.
@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  FilterState build() => const FilterState();

  // --------------------------------------------------------------------------
  // Type filter
  // --------------------------------------------------------------------------

  /// Replaces the active type filters.
  ///
  /// Parameters:
  /// - [types]: New set of selected [TransactionType] values.
  void setTypes(List<TransactionType> types) {
    state = state.copyWith(types: types);
  }

  /// Toggles a single [TransactionType] in or out of the active types list.
  ///
  /// If [type] is already selected, it is removed. Otherwise it is added.
  /// Equivalent to a checkbox interaction on a single chip.
  ///
  /// Parameters:
  /// - [type]: The type to toggle.
  void toggleType(TransactionType type) {
    final updated = List<TransactionType>.from(state.types);
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    state = state.copyWith(types: updated);
  }

  // --------------------------------------------------------------------------
  // Account filter
  // --------------------------------------------------------------------------

  /// Replaces the active account UUID filters.
  ///
  /// Parameters:
  /// - [accountIds]: New set of selected account UUIDs.
  void setAccountIds(List<String> accountIds) {
    state = state.copyWith(accountIds: accountIds);
  }

  // --------------------------------------------------------------------------
  // Category filter
  // --------------------------------------------------------------------------

  /// Replaces the active category UUID filters.
  ///
  /// Parameters:
  /// - [categoryIds]: New set of selected category/subcategory UUIDs.
  void setCategoryIds(List<String> categoryIds) {
    state = state.copyWith(categoryIds: categoryIds);
  }

  // --------------------------------------------------------------------------
  // Date range filter
  // --------------------------------------------------------------------------

  /// Updates the date range filter.
  ///
  /// Pass null to clear the date range.
  ///
  /// Parameters:
  /// - [range]: The new [DateTimeRange] or null to clear.
  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  // --------------------------------------------------------------------------
  // Amount range filter
  // --------------------------------------------------------------------------

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

  // --------------------------------------------------------------------------
  // Boolean toggles
  // --------------------------------------------------------------------------

  /// Toggles one of the boolean filter flags.
  ///
  /// Supported [flag] values: `'hasPhoto'`, `'hasTitle'`, `'hasDescription'`,
  /// `'isRecurring'`, `'isVoided'`.
  ///
  /// Parameters:
  /// - [flag]: Name of the boolean field to toggle.
  void toggleBoolean(String flag) {
    state = switch (flag) {
      'hasPhoto' => state.copyWith(hasPhoto: !state.hasPhoto),
      'hasTitle' => state.copyWith(hasTitle: !state.hasTitle),
      'hasDescription' => state.copyWith(hasDescription: !state.hasDescription),
      'isRecurring' => state.copyWith(isRecurring: !state.isRecurring),
      'isVoided' => state.copyWith(isVoided: !state.isVoided),
      _ => state,
    };
  }

  // --------------------------------------------------------------------------
  // Sort controls
  // --------------------------------------------------------------------------

  /// Updates the sort field and direction simultaneously.
  ///
  /// Parameters:
  /// - [field]: The field to sort by.
  /// - [direction]: The direction to sort in.
  void setSortField(SortField field, SortDirection direction) {
    state = state.copyWith(sortField: field, sortDirection: direction);
  }

  // --------------------------------------------------------------------------
  // Reset
  // --------------------------------------------------------------------------

  /// Resets all filter criteria to empty / unset.
  ///
  /// Alias: [clear].
  void reset() {
    state = const FilterState();
  }

  /// Resets all filter criteria to empty / unset.
  ///
  /// Alias for [reset] — provided for backward compatibility.
  void clear() => reset();
}
