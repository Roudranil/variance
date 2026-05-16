// lib/domain/usecases/recurring/generate_lookahead_use_case.dart
//
// Use case: materialize scheduled_occurrences rows up to 90 days ahead (T-102).
//
// For each active template, computes future occurrence dates from
// max(template.startDate, today) to today+90 and inserts them via
// IScheduledOccurrenceRepository.generateLookahead.
//
// Date arithmetic rules (SDS §1.6.10):
//   - O(1) per occurrence — no iteration loops for period index computation.
//   - End-of-month clamping: if target day > last day of month, use last day.
//   - recurrenceConstraints shift occurrence date as required:
//       weekdaysOnly  → advance to next Monday if date falls on weekend
//       weekendsOnly  → advance to next Saturday if date falls on weekday
//       startOfMonth  → pin to first day of occurrence month
//       endOfMonth    → pin to last day of occurrence month
//       startOfYear   → pin to 1 January of occurrence year
//       endOfYear     → pin to 31 December of occurrence year
//
// Idempotent: existing non-cancelled occurrences are skipped.
//
// Test cases (see test/unit/domain/usecases/generate_lookahead_use_case_test.dart):
//   1. monthly on day 31 → clamped to last day of month (Feb 28/29)
//   2. leap year Feb 29 → materializes correctly in a leap year
//   3. weekdays_only → weekend occurrences shifted to next Monday
//   4. end_of_month → occurrence pinned to last day of month
//   5. existing occurrence → duplicate date skipped

import 'dart:developer' as dev;

import 'package:uuid/uuid.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/entities/scheduled_occurrence.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';

// ignore: prefer_const_constructors — Uuid must not be const
final _uuid = Uuid();

/// Lookahead window in days.
const _kLookaheadDays = 90;

/// Generates materialized [ScheduledOccurrence] rows for all active templates
/// covering the window [today, today + 90 days].
///
/// Uses O(1) arithmetic per occurrence per the SDS §1.6.10 constraint.
/// Delegates insertion (with idempotent duplicate skipping) to
/// [IScheduledOccurrenceRepository.generateLookahead].
class GenerateLookaheadUseCase {
  /// Creates a [GenerateLookaheadUseCase].
  ///
  /// Parameters:
  /// - [templateRepository]: Source of active recurring templates.
  /// - [occurrenceRepository]: Sink for generated occurrence rows.
  const GenerateLookaheadUseCase(
    this._templateRepository,
    this._occurrenceRepository,
  );

  final IRecurringTemplateRepository _templateRepository;
  final IScheduledOccurrenceRepository _occurrenceRepository;

  /// Runs the lookahead generation as of [today].
  ///
  /// Returns [Ok(n)] where n is the total number of new occurrences inserted
  /// across all templates. Skipped (already-existing) dates are not counted.
  ///
  /// Parameters:
  /// - [today]: Reference date for the lookahead window. Defaults to
  ///   [DateTime.now()] when not provided.
  Future<Result<int>> call({DateTime? today}) async {
    final effectiveToday = today ?? DateTime.now();
    final toDate = effectiveToday.add(const Duration(days: _kLookaheadDays));

    List<RecurringTemplate> allTemplates;
    try {
      allTemplates = await _templateRepository.watchAll().first;
    } on Object catch (e) {
      dev.log(
        'GenerateLookaheadUseCase: failed to load templates: $e',
        name: 'GenerateLookaheadUseCase',
      );
      return Err(DatabaseFailure('Failed to load templates: $e'));
    }

    // Only active non-installment templates need lookahead.
    final activeTemplates = allTemplates
        .where(
          (t) => t.status == RecurringTemplateStatus.active && !t.isInstallment,
        )
        .toList();

    var totalInserted = 0;

    for (final template in activeTemplates) {
      try {
        final occurrences = _computeOccurrences(
          template: template,
          fromDate: effectiveToday,
          toDate: toDate,
        );

        if (occurrences.isEmpty) continue;

        final result = await _occurrenceRepository.generateLookahead(
          templateId: template.id,
          fromDate: effectiveToday,
          toDate: toDate,
          occurrences: occurrences,
        );

        if (result case Ok()) {
          totalInserted += occurrences.length;
        } else if (result case Err(:final failure)) {
          dev.log(
            'GenerateLookaheadUseCase: insertion failed for template '
            '${template.id}: ${failure.message}',
            name: 'GenerateLookaheadUseCase',
          );
        }
      } on Object catch (e) {
        dev.log(
          'GenerateLookaheadUseCase: error for template ${template.id}: $e',
          name: 'GenerateLookaheadUseCase',
        );
      }
    }

    return Ok(totalInserted);
  }

  // ---------------------------------------------------------------------------
  // Date computation
  // ---------------------------------------------------------------------------

  /// Computes occurrence [DateTime]s for [template] in [[fromDate], [toDate]].
  ///
  /// Uses O(1) arithmetic: computes the first period index that falls within
  /// the window via integer division, then steps forward one period at a time.
  ///
  /// Parameters:
  /// - [template]: Source template providing recurrence parameters.
  /// - [fromDate]: Inclusive window start.
  /// - [toDate]: Exclusive window end.
  List<ScheduledOccurrence> _computeOccurrences({
    required RecurringTemplate template,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    // Convert startDate (epoch days) to DateTime.
    final startDt = DateTime.utc(1970).add(
      Duration(days: template.startDate),
    );

    // Convert endDate (epoch days) to DateTime if set.
    final endDt = template.endDate != null
        ? DateTime.utc(1970).add(Duration(days: template.endDate!))
        : null;

    // The effective window start is max(template.startDate, fromDate).
    final windowStart = startDt.isAfter(fromDate) ? startDt : fromDate;

    // If the template hasn't started yet or is already ended, skip.
    if (endDt != null && !endDt.isAfter(windowStart)) return [];
    if (!startDt.isBefore(toDate)) return [];

    // O(1): compute first period index that overlaps the window.
    final firstIndex = _periodIndexAtDate(
      startDt: startDt,
      targetDt: windowStart,
      recurrenceN: template.recurrenceN,
      unit: template.recurrenceUnit,
    );

    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final occurrences = <ScheduledOccurrence>[];
    var index = firstIndex;

    while (true) {
      // Compute the raw occurrence date.
      var occurrenceDt = _addPeriods(
        startDt: startDt,
        periods: index,
        recurrenceN: template.recurrenceN,
        unit: template.recurrenceUnit,
      );

      // Apply end-of-month clamping (already handled by DateTime arithmetic
      // when month overflows, but we ensure it explicitly for clarity).
      occurrenceDt = _clampToLastDayOfMonth(
        target: occurrenceDt,
        originalDay: startDt.day,
        unit: template.recurrenceUnit,
      );

      // Apply recurrence constraints.
      occurrenceDt = _applyConstraints(
        occurrenceDt,
        template.recurrenceConstraints ?? [],
      );

      // Stop if we've passed the window or the template end.
      if (!occurrenceDt.isBefore(toDate)) break;
      if (endDt != null && !occurrenceDt.isBefore(endDt)) break;

      // Only include dates that fall within or after the window start.
      if (!occurrenceDt.isBefore(windowStart)) {
        final epochDay = occurrenceDt.millisecondsSinceEpoch ~/ 86400000;
        occurrences.add(
          ScheduledOccurrence(
            id: _uuid.v4(),
            templateId: template.id,
            scheduledDate: epochDay,
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );
      }

      index++;
    }

    return occurrences;
  }

  /// Computes the period index (0-based) that contains [targetDt] given
  /// a series starting at [startDt] with period [recurrenceN] × [unit].
  ///
  /// Returns 0 if [targetDt] is before or equal to [startDt].
  int _periodIndexAtDate({
    required DateTime startDt,
    required DateTime targetDt,
    required int recurrenceN,
    required RecurrenceUnit unit,
  }) {
    if (!targetDt.isAfter(startDt)) return 0;

    final elapsedMs =
        targetDt.millisecondsSinceEpoch - startDt.millisecondsSinceEpoch;

    // Average ms per period for O(1) estimation.
    final avgMsPerPeriod = switch (unit) {
      RecurrenceUnit.day => recurrenceN * 86400 * 1000,
      RecurrenceUnit.week => recurrenceN * 7 * 86400 * 1000,
      RecurrenceUnit.month => recurrenceN * 30 * 86400 * 1000,
      RecurrenceUnit.year => recurrenceN * 365 * 86400 * 1000,
    };

    // Integer division gives approximate index; walk back if needed.
    var index = (elapsedMs / avgMsPerPeriod).floor();
    if (index < 0) index = 0;

    // Walk backward to the correct period (handles variable-length months).
    while (index > 0) {
      final periodStart = _addPeriods(
        startDt: startDt,
        periods: index,
        recurrenceN: recurrenceN,
        unit: unit,
      );
      if (!periodStart.isAfter(targetDt)) break;
      index--;
    }

    return index;
  }

  /// Adds [periods] × ([recurrenceN] × [unit]) to [startDt].
  ///
  /// For month/year, applies end-of-month clamping: the target day is clamped
  /// to the last valid day in the resulting month before the DateTime is built,
  /// preventing Dart's overflow normalisation (e.g. Jan 31 + 1 month → Mar 3).
  DateTime _addPeriods({
    required DateTime startDt,
    required int periods,
    required int recurrenceN,
    required RecurrenceUnit unit,
  }) {
    final totalUnits = periods * recurrenceN;
    switch (unit) {
      case RecurrenceUnit.day:
        return startDt.add(Duration(days: totalUnits));
      case RecurrenceUnit.week:
        return startDt.add(Duration(days: totalUnits * 7));
      case RecurrenceUnit.month:
        // Compute target year/month with overflow normalised by DateTime.
        final rawTarget = DateTime.utc(
          startDt.year,
          startDt.month + totalUnits,
          1, // day=1 always valid; we set the day explicitly below
        );
        final lastDay = _lastDayOfMonth(rawTarget.year, rawTarget.month);
        final clampedDay = startDt.day <= lastDay ? startDt.day : lastDay;
        return DateTime.utc(rawTarget.year, rawTarget.month, clampedDay);
      case RecurrenceUnit.year:
        final targetYear = startDt.year + totalUnits;
        final lastDay = _lastDayOfMonth(targetYear, startDt.month);
        final clampedDay = startDt.day <= lastDay ? startDt.day : lastDay;
        return DateTime.utc(targetYear, startDt.month, clampedDay);
    }
  }

  /// Returns the last day of [month] in [year].
  ///
  /// Uses `DateTime.utc(year, month+1, 0)` which normalises day-0 to the last
  /// day of the previous month.
  int _lastDayOfMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  /// Clamps [target] to the last day of its month when the [originalDay]
  /// exceeds the number of days in [target]'s month.
  ///
  /// Only applies to month/year recurrences. This is a post-processing step;
  /// the primary clamping now happens inside [_addPeriods].
  DateTime _clampToLastDayOfMonth({
    required DateTime target,
    required int originalDay,
    required RecurrenceUnit unit,
  }) {
    if (unit != RecurrenceUnit.month && unit != RecurrenceUnit.year) {
      return target;
    }
    final lastDay = _lastDayOfMonth(target.year, target.month);
    if (originalDay > lastDay && target.day != lastDay) {
      return DateTime.utc(target.year, target.month, lastDay);
    }
    return target;
  }

  /// Applies [constraints] to shift [dt] as required.
  ///
  /// Multiple constraints are applied sequentially. Shifting may land on a
  /// new day that violates a constraint; this is acceptable per spec (one pass
  /// of constraint application).
  DateTime _applyConstraints(
    DateTime dt,
    List<RecurrenceConstraint> constraints,
  ) {
    var result = dt;
    for (final constraint in constraints) {
      result = switch (constraint) {
        RecurrenceConstraint.weekdaysOnly => _shiftToWeekday(result),
        RecurrenceConstraint.weekendsOnly => _shiftToWeekend(result),
        RecurrenceConstraint.startOfMonth =>
          DateTime.utc(result.year, result.month, 1),
        RecurrenceConstraint.endOfMonth =>
          DateTime.utc(result.year, result.month + 1, 0),
        RecurrenceConstraint.startOfYear => DateTime.utc(result.year, 1, 1),
        RecurrenceConstraint.endOfYear => DateTime.utc(result.year, 12, 31),
      };
    }
    return result;
  }

  /// Advances [dt] to the next Monday if it falls on a weekend.
  DateTime _shiftToWeekday(DateTime dt) {
    // DateTime.monday=1 … DateTime.sunday=7
    return switch (dt.weekday) {
      DateTime.saturday => dt.add(const Duration(days: 2)),
      DateTime.sunday => dt.add(const Duration(days: 1)),
      _ => dt,
    };
  }

  /// Advances [dt] to the next Saturday if it falls on a weekday.
  DateTime _shiftToWeekend(DateTime dt) {
    final daysUntilSaturday = (DateTime.saturday - dt.weekday + 7) % 7;
    return daysUntilSaturday == 0
        ? dt
        : dt.add(Duration(days: daysUntilSaturday));
  }
}
