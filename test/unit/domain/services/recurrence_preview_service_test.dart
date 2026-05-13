// test/unit/domain/services/recurrence_preview_service_test.dart
//
// Unit tests for RecurrencePreviewService (T-107).
//
// Test cases:
//   1.  No constraint — first date equals start date.
//   2.  weekdays_only — Saturday advanced to Monday.
//   3.  weekdays_only — Sunday advanced to Monday.
//   4.  weekdays_only — weekday is unchanged.
//   5.  weekends_only — weekday (Monday) advanced to Saturday.
//   6.  weekends_only — Saturday unchanged.
//   7.  weekends_only — Sunday unchanged.
//   8.  start_of_month — result is day 1 of start month.
//   9.  end_of_month — result is last day of start month.
//  10.  end_of_month Feb — result is Feb 28 (non-leap year).
//  11.  end_of_month Feb leap — result is Feb 29 (leap year).
//  12.  start_of_year — result is Jan 1 of start year.
//  13.  end_of_year — result is Dec 31 of start year.
//  14.  Validation failure — recurrenceN = 0.
//  15.  Validation failure — recurrenceN negative.
//  16.  Empty constraints list acts as no constraint.

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/services/recurrence_preview_service.dart';

void main() {
  const service = RecurrencePreviewService();

  // Helper: converts a DateTime(year, month, day) UTC to epoch days.
  int toEpochDays(int year, int month, int day) {
    final dt = DateTime.utc(year, month, day);
    return dt.millisecondsSinceEpoch ~/ 86400000;
  }

  group('RecurrencePreviewService.computeFirstDate', () {
    // -------------------------------------------------------------------------
    // 1. No constraint — first date equals start date
    // -------------------------------------------------------------------------
    test('no constraint returns start date unchanged', () {
      // 2025-05-15 (Thursday)
      final startDay = toEpochDays(2025, 5, 15);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        startDate: startDay,
      );
      expect(result, isA<Ok<DateTime>>());
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 5, 15));
    });

    // -------------------------------------------------------------------------
    // 2. weekdays_only — Saturday → Monday
    // -------------------------------------------------------------------------
    test('weekdays_only shifts Saturday to next Monday', () {
      // 2025-05-17 is Saturday
      final startDay = toEpochDays(2025, 5, 17);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        recurrenceConstraints: [RecurrenceConstraint.weekdaysOnly],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      // Saturday + 2 days = Monday 2025-05-19
      expect(date, DateTime.utc(2025, 5, 19));
    });

    // -------------------------------------------------------------------------
    // 3. weekdays_only — Sunday → Monday
    // -------------------------------------------------------------------------
    test('weekdays_only shifts Sunday to next Monday', () {
      // 2025-05-18 is Sunday
      final startDay = toEpochDays(2025, 5, 18);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        recurrenceConstraints: [RecurrenceConstraint.weekdaysOnly],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      // Sunday + 1 day = Monday 2025-05-19
      expect(date, DateTime.utc(2025, 5, 19));
    });

    // -------------------------------------------------------------------------
    // 4. weekdays_only — weekday is unchanged
    // -------------------------------------------------------------------------
    test('weekdays_only leaves a weekday unchanged', () {
      // 2025-05-15 is Thursday
      final startDay = toEpochDays(2025, 5, 15);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        recurrenceConstraints: [RecurrenceConstraint.weekdaysOnly],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 5, 15));
    });

    // -------------------------------------------------------------------------
    // 5. weekends_only — weekday (Monday) → Saturday
    // -------------------------------------------------------------------------
    test('weekends_only shifts Monday to next Saturday', () {
      // 2025-05-12 is Monday
      final startDay = toEpochDays(2025, 5, 12);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        recurrenceConstraints: [RecurrenceConstraint.weekendsOnly],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      // Monday(1) → Saturday(6): (6-1)%7 = 5 days → 2025-05-17
      expect(date, DateTime.utc(2025, 5, 17));
    });

    // -------------------------------------------------------------------------
    // 6. weekends_only — Saturday unchanged
    // -------------------------------------------------------------------------
    test('weekends_only leaves Saturday unchanged', () {
      // 2025-05-17 is Saturday
      final startDay = toEpochDays(2025, 5, 17);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        recurrenceConstraints: [RecurrenceConstraint.weekendsOnly],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 5, 17));
    });

    // -------------------------------------------------------------------------
    // 7. weekends_only — Sunday unchanged
    // -------------------------------------------------------------------------
    test('weekends_only leaves Sunday unchanged', () {
      // 2025-05-18 is Sunday
      final startDay = toEpochDays(2025, 5, 18);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        recurrenceConstraints: [RecurrenceConstraint.weekendsOnly],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 5, 18));
    });

    // -------------------------------------------------------------------------
    // 8. start_of_month — result is day 1
    // -------------------------------------------------------------------------
    test('start_of_month returns day 1 of start month', () {
      final startDay = toEpochDays(2025, 5, 15);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        recurrenceConstraints: [RecurrenceConstraint.startOfMonth],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 5, 1));
    });

    // -------------------------------------------------------------------------
    // 9. end_of_month — result is last day
    // -------------------------------------------------------------------------
    test('end_of_month returns last day of start month', () {
      final startDay = toEpochDays(2025, 5, 10);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        recurrenceConstraints: [RecurrenceConstraint.endOfMonth],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 5, 31));
    });

    // -------------------------------------------------------------------------
    // 10. end_of_month Feb non-leap → Feb 28
    // -------------------------------------------------------------------------
    test('end_of_month for February non-leap year returns Feb 28', () {
      final startDay = toEpochDays(2025, 2, 10);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        recurrenceConstraints: [RecurrenceConstraint.endOfMonth],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 2, 28));
    });

    // -------------------------------------------------------------------------
    // 11. end_of_month Feb leap year → Feb 29
    // -------------------------------------------------------------------------
    test('end_of_month for February leap year returns Feb 29', () {
      final startDay = toEpochDays(2024, 2, 10);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        recurrenceConstraints: [RecurrenceConstraint.endOfMonth],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2024, 2, 29));
    });

    // -------------------------------------------------------------------------
    // 12. start_of_year → Jan 1
    // -------------------------------------------------------------------------
    test('start_of_year returns Jan 1 of start year', () {
      final startDay = toEpochDays(2025, 8, 20);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.year,
        recurrenceConstraints: [RecurrenceConstraint.startOfYear],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 1, 1));
    });

    // -------------------------------------------------------------------------
    // 13. end_of_year → Dec 31
    // -------------------------------------------------------------------------
    test('end_of_year returns Dec 31 of start year', () {
      final startDay = toEpochDays(2025, 3, 5);
      final result = service.computeFirstDate(
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.year,
        recurrenceConstraints: [RecurrenceConstraint.endOfYear],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      expect(date, DateTime.utc(2025, 12, 31));
    });

    // -------------------------------------------------------------------------
    // 14. Validation failure — recurrenceN = 0
    // -------------------------------------------------------------------------
    test('returns ValidationFailure when recurrenceN is 0', () {
      final startDay = toEpochDays(2025, 5, 15);
      final result = service.computeFirstDate(
        recurrenceN: 0,
        recurrenceUnit: RecurrenceUnit.day,
        startDate: startDay,
      );
      expect(result, isA<Err<DateTime>>());
      final err = result as Err<DateTime>;
      expect(err.failure, isA<ValidationFailure>());
    });

    // -------------------------------------------------------------------------
    // 15. Validation failure — recurrenceN negative
    // -------------------------------------------------------------------------
    test('returns ValidationFailure when recurrenceN is negative', () {
      final startDay = toEpochDays(2025, 5, 15);
      final result = service.computeFirstDate(
        recurrenceN: -3,
        recurrenceUnit: RecurrenceUnit.week,
        startDate: startDay,
      );
      expect(result, isA<Err<DateTime>>());
      final err = result as Err<DateTime>;
      expect(err.failure, isA<ValidationFailure>());
    });

    // -------------------------------------------------------------------------
    // 16. Empty constraints list acts as no constraint
    // -------------------------------------------------------------------------
    test('empty constraints list returns start date unchanged', () {
      final startDay = toEpochDays(2025, 5, 17); // Saturday
      final result = service.computeFirstDate(
        recurrenceN: 2,
        recurrenceUnit: RecurrenceUnit.week,
        recurrenceConstraints: const [],
        startDate: startDay,
      );
      final date = (result as Ok<DateTime>).value;
      // No constraint applied — returns the Saturday unchanged.
      expect(date, DateTime.utc(2025, 5, 17));
    });
  });
}
