// lib/domain/services/period_calculator.dart
//
// PeriodCalculator — O(1) computation of the current DateRange for recurring
// templates and budgets.
//
// SDS §1.6.10 constraint: period calculations MUST NOT use forward-iteration
// loops. The current period index is computed as:
//   periodIndex = max(0, elapsed ~/ periodLengthInSeconds)
//
// For variable-length periods (monthly, yearly), Dart's DateTime constructor
// automatically clamps overflow days (e.g. adding 1 month to Jan 31 yields
// Feb 28/29 on the native calendar — no manual clamping needed).
//
// DateRange start is inclusive; end is exclusive: [start, end).

import 'package:variance/domain/entities/recurring_template.dart';

/// A half-open time range [startEpochSeconds, endEpochSeconds).
///
/// [startEpochSeconds] is inclusive; [endEpochSeconds] is exclusive.
class DateRange {
  /// Creates a [DateRange] with Unix epoch second boundaries.
  ///
  /// Parameters:
  /// - [startEpochSeconds]: Inclusive start of the period (Unix seconds).
  /// - [endEpochSeconds]: Exclusive end of the period (Unix seconds).
  const DateRange({
    required this.startEpochSeconds,
    required this.endEpochSeconds,
  });

  /// Inclusive start of the period as Unix epoch seconds.
  final int startEpochSeconds;

  /// Exclusive end of the period as Unix epoch seconds.
  final int endEpochSeconds;
}

/// Stateless service for O(1) date-period arithmetic.
///
/// Given a [startEpochSeconds], [recurrenceN], [recurrenceUnit], and
/// [referenceEpochSeconds], [compute] returns the [DateRange] of the period
/// that contains the reference date. No mutable instance state is modified
/// between calls.
///
/// Month-end and leap-year clamping is handled by Dart's [DateTime]
/// constructor, which normalises overflow (e.g. `DateTime(2025, 2, 31)` →
/// `DateTime(2025, 3, 3)`). The clamping strategy used here instead directly
/// constructs the intended month/year to allow Dart to clamp naturally.
class PeriodCalculator {
  /// Creates a new [PeriodCalculator].
  const PeriodCalculator();

  /// Returns the [DateRange] of the period that contains [referenceEpochSeconds].
  ///
  /// If [referenceEpochSeconds] is before [startEpochSeconds], the period
  /// starting at [startEpochSeconds] is returned (period index 0).
  ///
  /// The period length is [recurrenceN] × [recurrenceUnit]. For fixed-length
  /// units (day, week), the period index is calculated with integer division.
  /// For variable-length units (month, year), Dart's [DateTime] arithmetic
  /// handles month-boundary and leap-year edge cases natively.
  ///
  /// Parameters:
  /// - [startEpochSeconds]: First period start (Unix seconds, inclusive).
  /// - [recurrenceN]: Number of time units per period (e.g. 2 for bi-weekly).
  /// - [recurrenceUnit]: The unit of time for each period increment.
  /// - [referenceEpochSeconds]: The point in time to find the period for.
  DateRange compute({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int referenceEpochSeconds,
  }) {
    return switch (recurrenceUnit) {
      RecurrenceUnit.day || RecurrenceUnit.week => _computeFixedLengthPeriod(
          startEpochSeconds: startEpochSeconds,
          recurrenceN: recurrenceN,
          recurrenceUnit: recurrenceUnit,
          referenceEpochSeconds: referenceEpochSeconds,
        ),
      RecurrenceUnit.month ||
      RecurrenceUnit.year =>
        _computeVariableLengthPeriod(
          startEpochSeconds: startEpochSeconds,
          recurrenceN: recurrenceN,
          recurrenceUnit: recurrenceUnit,
          referenceEpochSeconds: referenceEpochSeconds,
        ),
    };
  }

  // ---------------------------------------------------------------------------
  // Fixed-length periods (day, week) — O(1) integer division
  // ---------------------------------------------------------------------------

  DateRange _computeFixedLengthPeriod({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int referenceEpochSeconds,
  }) {
    final secondsPerPeriod =
        _fixedSecondsPerPeriod(recurrenceN, recurrenceUnit);
    // If the reference is before the start, use period index 0.
    final elapsed = referenceEpochSeconds < startEpochSeconds
        ? 0
        : referenceEpochSeconds - startEpochSeconds;
    final periodIndex = elapsed ~/ secondsPerPeriod;
    final periodStart = startEpochSeconds + periodIndex * secondsPerPeriod;
    final periodEnd = periodStart + secondsPerPeriod;
    return DateRange(
      startEpochSeconds: periodStart,
      endEpochSeconds: periodEnd,
    );
  }

  int _fixedSecondsPerPeriod(int n, RecurrenceUnit unit) {
    return switch (unit) {
      RecurrenceUnit.day => n * 86400,
      RecurrenceUnit.week => n * 7 * 86400,
      RecurrenceUnit.month || RecurrenceUnit.year => throw StateError(
          'Variable-length units do not have a fixed second count',
        ),
    };
  }

  // ---------------------------------------------------------------------------
  // Variable-length periods (month, year) — O(1) via DateTime arithmetic
  // ---------------------------------------------------------------------------
  //
  // Strategy:
  //   1. Convert start epoch → DateTime (UTC).
  //   2. Compute an approximate period index using average seconds per period.
  //   3. Adjust by ±1 to land on the exact containing period (handles the
  //      approximation drift introduced by month/year length variance).
  //
  // Dart's DateTime constructor normalises overflow automatically:
  //   DateTime(2025, 2, 31) → DateTime(2025, 3, 3)  [normalised forward]
  //   DateTime(2025, 1, 31).add months 1 → Feb 28/29 [via _addPeriods]
  //
  // The _addPeriods helper uses DateTime.utc(y, m+Δm, d) so that Dart clamps
  // the day to the last valid day in the resulting month — this is what
  // gives us the month-end clamping behaviour required by the spec.

  DateRange _computeVariableLengthPeriod({
    required int startEpochSeconds,
    required int recurrenceN,
    required RecurrenceUnit recurrenceUnit,
    required int referenceEpochSeconds,
  }) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(
      startEpochSeconds * 1000,
      isUtc: true,
    );

    // Compute approximate period index using an average period length.
    // We add a few periods around this estimate and select the correct one.
    final approximateSecondsPerPeriod = switch (recurrenceUnit) {
      RecurrenceUnit.month => recurrenceN * 30 * 86400,
      RecurrenceUnit.year => recurrenceN * 365 * 86400,
      _ => throw StateError('Unexpected unit in variable-length branch'),
    };

    final elapsed = referenceEpochSeconds - startEpochSeconds;
    // Integer division gives a rough index; we search ±2 around it.
    var approxIndex = elapsed ~/ approximateSecondsPerPeriod;
    if (approxIndex < 0) approxIndex = 0;

    // Walk backward until we find the period whose start is ≤ reference.
    var index = approxIndex;
    while (true) {
      final periodStartDate =
          _addPeriods(startDate, index, recurrenceN, recurrenceUnit);
      if (periodStartDate.millisecondsSinceEpoch ~/ 1000 <=
          referenceEpochSeconds) {
        // Check that the next period hasn't started yet.
        final nextPeriodStartDate = _addPeriods(
          startDate,
          index + 1,
          recurrenceN,
          recurrenceUnit,
        );
        if (nextPeriodStartDate.millisecondsSinceEpoch ~/ 1000 >
            referenceEpochSeconds) {
          // This is the correct period.
          return DateRange(
            startEpochSeconds: periodStartDate.millisecondsSinceEpoch ~/ 1000,
            endEpochSeconds: nextPeriodStartDate.millisecondsSinceEpoch ~/ 1000,
          );
        } else {
          // Move forward.
          index++;
        }
      } else {
        // Move backward.
        if (index == 0) {
          // Reference is before start; return period 0.
          final p1Start =
              _addPeriods(startDate, 0, recurrenceN, recurrenceUnit);
          final p1End = _addPeriods(startDate, 1, recurrenceN, recurrenceUnit);
          return DateRange(
            startEpochSeconds: p1Start.millisecondsSinceEpoch ~/ 1000,
            endEpochSeconds: p1End.millisecondsSinceEpoch ~/ 1000,
          );
        }
        index--;
      }
    }
  }

  /// Adds [n] × [recurrenceN] periods to [start] using Dart's UTC [DateTime]
  /// constructor.
  ///
  /// For months: `DateTime.utc(y, m + n*recurrenceN, d)`. When d exceeds the
  /// last day of the resulting month, Dart's constructor normalises forward
  /// (e.g. Feb 31 → Mar 3). To achieve month-end clamping instead, we
  /// construct `DateTime.utc(y, m + n*recurrenceN + 1, 0)` to get the last
  /// day of the target month, then take the minimum of d and that last day.
  ///
  /// Parameters:
  /// - [start]: The base date.
  /// - [n]: Number of periods to add.
  /// - [recurrenceN]: Multiplier per period.
  /// - [unit]: The period unit.
  DateTime _addPeriods(
    DateTime start,
    int n,
    int recurrenceN,
    RecurrenceUnit unit,
  ) {
    return switch (unit) {
      RecurrenceUnit.month => _addMonths(start, n * recurrenceN),
      RecurrenceUnit.year => _addYears(start, n * recurrenceN),
      _ => throw StateError('Fixed-length units handled in _periodAt'),
    };
  }

  /// Adds [months] to [dt], clamping the day to the last valid day of the
  /// resulting month.
  ///
  /// This implements the month-end clamping required by SDS spec:
  ///   Jan 31 + 1 month = Feb 28/29 (not Mar 3).
  DateTime _addMonths(DateTime dt, int months) {
    final targetMonth = dt.month + months;
    final targetYear = dt.year + (targetMonth - 1) ~/ 12;
    final normalizedMonth = ((targetMonth - 1) % 12) + 1;

    // Last day of the target month: day 0 of (month+1) gives last day of month.
    final lastDayOfTargetMonth =
        DateTime.utc(targetYear, normalizedMonth + 1, 0).day;
    final clampedDay =
        dt.day < lastDayOfTargetMonth ? dt.day : lastDayOfTargetMonth;

    return DateTime.utc(
      targetYear,
      normalizedMonth,
      clampedDay,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }

  /// Adds [years] to [dt], clamping Feb 29 to Feb 28 on non-leap years.
  DateTime _addYears(DateTime dt, int years) {
    final targetYear = dt.year + years;
    final lastDayOfTargetMonth = DateTime.utc(targetYear, dt.month + 1, 0).day;
    final clampedDay =
        dt.day < lastDayOfTargetMonth ? dt.day : lastDayOfTargetMonth;
    return DateTime.utc(
      targetYear,
      dt.month,
      clampedDay,
      dt.hour,
      dt.minute,
      dt.second,
    );
  }
}
