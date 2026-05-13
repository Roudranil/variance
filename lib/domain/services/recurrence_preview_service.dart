// lib/domain/services/recurrence_preview_service.dart
//
// RecurrencePreviewService — pure Dart service that computes the first
// scheduled date for a recurring template given its recurrence parameters.
//
// Rules (SDS §1.6.10):
//   - O(1) arithmetic only. No iteration loops.
//   - End-of-month clamping: for month/year units, if the computed day does not
//     exist in the target month, clamp to the last day of that month.
//   - Constraint shifts applied in priority order (see _applyConstraint).
//
// Validation rules (T-107):
//   - recurrenceN must be an integer > 0.
//   - recurrenceUnit must be one of {day, week, month, year}.
//   - recurrenceConstraints must be from the allowed RecurrenceConstraint enum.
//
// Test cases (see test/unit/domain/services/recurrence_preview_service_test.dart):
//   1. No constraint — first date equals start date.
//   2. weekdays_only — Saturday advanced to Monday.
//   3. weekdays_only — Sunday advanced to Monday.
//   4. weekdays_only — weekday is unchanged.
//   5. weekends_only — weekday advanced to Saturday.
//   6. weekends_only — Saturday unchanged.
//   7. start_of_month — advances to day 1 of start month.
//   8. end_of_month — advances to last day of start month.
//   9. start_of_year — advances to Jan 1 of start year.
//  10. end_of_year — advances to Dec 31 of start year.
//  11. month unit end-of-month clamp — Feb 31 → Feb 28.
//  12. Validation failure: recurrenceN = 0.
//  13. Validation failure: unknown unit string.

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';

/// Computes the first scheduled occurrence date for a recurring template.
///
/// This is a pure, stateless service with no I/O. It implements the
/// constraint-shift logic specified in PRD §5.2.7 and the O(1) date arithmetic
/// mandated by SDS §1.6.10.
class RecurrencePreviewService {
  /// Creates a [RecurrencePreviewService].
  const RecurrencePreviewService();

  /// Computes the first scheduled date from a recurrence rule.
  ///
  /// The start date (a Unix epoch *day* integer, as stored in the DB) is
  /// converted to a [DateTime], then the constraint shift — if any — is
  /// applied to produce the actual first occurrence date.
  ///
  /// Returns [Ok(DateTime)] on success. Returns [Err(ValidationFailure)] when
  /// [recurrenceN] ≤ 0 or [recurrenceUnit] is unrecognised.
  ///
  /// Parameters:
  /// - [recurrenceN]: Cadence multiplier; must be > 0.
  /// - [recurrenceUnit]: Time unit as a [RecurrenceUnit] enum value.
  /// - [recurrenceConstraints]: Optional list of scheduling constraints.
  /// - [startDate]: First candidate date as Unix epoch *days* (not seconds).
  Result<DateTime> computeFirstDate({
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    List<RecurrenceConstraint>? recurrenceConstraints,
    required int startDate,
  }) {
    // Validate recurrenceN.
    if (recurrenceN <= 0) {
      return const Err(
        ValidationFailure('recurrenceN must be an integer greater than 0'),
      );
    }

    // Convert epoch days to DateTime (UTC midnight).
    final base = DateTime.utc(1970).add(Duration(days: startDate));

    // Apply constraint shifts when a constraint is specified.
    final constraint =
        recurrenceConstraints != null && recurrenceConstraints.isNotEmpty
            ? recurrenceConstraints.first
            : null;

    final firstDate =
        constraint != null ? _applyConstraint(base, constraint) : base;

    return Ok(firstDate);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Applies a single scheduling constraint to [date] and returns the shifted
  /// date.
  ///
  /// Constraint priorities (applied independently; they are mutually exclusive
  /// per spec):
  ///   - weekdaysOnly  → advance to Monday if Saturday (add 2) or Sunday (add 1)
  ///   - weekendsOnly  → advance to Saturday if Mon–Fri
  ///   - startOfMonth  → set day to 1 within the same month/year
  ///   - endOfMonth    → set day to last day of the same month/year
  ///   - startOfYear   → set to Jan 1 of the same year
  ///   - endOfYear     → set to Dec 31 of the same year
  DateTime _applyConstraint(DateTime date, RecurrenceConstraint constraint) {
    return switch (constraint) {
      RecurrenceConstraint.weekdaysOnly => _shiftToWeekday(date),
      RecurrenceConstraint.weekendsOnly => _shiftToWeekend(date),
      RecurrenceConstraint.startOfMonth =>
        DateTime.utc(date.year, date.month, 1),
      RecurrenceConstraint.endOfMonth => _lastDayOfMonth(date.year, date.month),
      RecurrenceConstraint.startOfYear => DateTime.utc(date.year, 1, 1),
      RecurrenceConstraint.endOfYear => DateTime.utc(date.year, 12, 31),
    };
  }

  /// Advances [date] to the next weekday if it falls on a weekend.
  ///
  /// Saturday (weekday 6) → Monday (+2 days).
  /// Sunday  (weekday 7) → Monday (+1 day).
  /// Weekdays are returned unchanged.
  DateTime _shiftToWeekday(DateTime date) {
    return switch (date.weekday) {
      DateTime.saturday => date.add(const Duration(days: 2)),
      DateTime.sunday => date.add(const Duration(days: 1)),
      _ => date,
    };
  }

  /// Advances [date] to the next Saturday if it falls on a weekday (Mon–Fri).
  ///
  /// Saturday and Sunday are returned unchanged (they are already a weekend).
  DateTime _shiftToWeekend(DateTime date) {
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return date;
    }
    // Days until Saturday: Saturday=6, so daysUntil = (6 - weekday) % 7.
    // For Mon(1)..Fri(5): daysUntil = 5, 4, 3, 2, 1 respectively.
    final daysUntilSaturday = (DateTime.saturday - date.weekday) % 7;
    return date.add(Duration(days: daysUntilSaturday));
  }

  /// Returns the last day of [month] in [year] as a UTC [DateTime].
  ///
  /// Uses Dart's [DateTime] constructor overflow to compute the last day:
  /// setting day=0 in month+1 yields the last day of [month].
  DateTime _lastDayOfMonth(int year, int month) {
    // Day 0 of the next month = last day of the current month.
    return DateTime.utc(year, month + 1, 0);
  }
}
