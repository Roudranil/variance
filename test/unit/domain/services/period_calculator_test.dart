// test/unit/domain/services/period_calculator_test.dart
//
// Unit tests for PeriodCalculator.
//
// All period computations must be O(1) — no iteration.
// DateRange is [start, end) — end is exclusive.
//
// Test cases:
//   1. Daily period — standard case
//   2. Weekly period — standard case
//   3. Monthly period — standard case (mid-month)
//   4. Yearly period — standard case
//   5. Monthly period: Jan 31 start — period 1 starts Feb 28 (non-leap 2025)
//   6. Monthly period: Jan 31 start — period 1 starts Feb 29 (leap year 2024)
//   7. Monthly period: March 31 start — period 1 starts April 30
//   8. Year boundary — Dec 15 + 1 month = Jan 15
//   9. Reference date before start → returns period 0 (the start period)
//  10. Custom period (n=2 weeks) — standard case
//  11. Reference date exactly on start → period 0
//  12. Reference date exactly on period boundary → next period starts
//  13. PeriodCalculator is stateless — two calls with same inputs yield same result
//  14. Leap year 2000: Jan 31 → period 1 starts Feb 29
//  15. Non-leap year 2100: Jan 31 → period 1 starts Feb 28

import 'package:flutter_test/flutter_test.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/services/period_calculator.dart';

DateTime _d(int year, int month, int day) => DateTime.utc(year, month, day);
int _epoch(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

void main() {
  final calc = PeriodCalculator();

  group('PeriodCalculator — Daily', () {
    test('1. daily period — reference on day 3 → period [day3, day4)', () {
      final start = _d(2025, 1, 1);
      final reference = _d(2025, 1, 4); // day index 3 from start
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.day,
        referenceEpochSeconds: _epoch(reference),
      );
      expect(
        DateTime.fromMillisecondsSinceEpoch(
          range.startEpochSeconds * 1000,
          isUtc: true,
        ),
        equals(_d(2025, 1, 4)),
      );
      expect(
        DateTime.fromMillisecondsSinceEpoch(
          range.endEpochSeconds * 1000,
          isUtc: true,
        ),
        equals(_d(2025, 1, 5)),
      );
    });
  });

  group('PeriodCalculator — Weekly', () {
    test('2. weekly period — reference on week 1 → period [week1, week2)', () {
      final start = _d(2025, 1, 1); // Wednesday
      final reference = _d(2025, 1, 12); // day 11 → week index 1
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        referenceEpochSeconds: _epoch(reference),
      );
      expect(
        DateTime.fromMillisecondsSinceEpoch(
          range.startEpochSeconds * 1000,
          isUtc: true,
        ),
        equals(_d(2025, 1, 8)),
      );
      expect(
        DateTime.fromMillisecondsSinceEpoch(
          range.endEpochSeconds * 1000,
          isUtc: true,
        ),
        equals(_d(2025, 1, 15)),
      );
    });
  });

  group('PeriodCalculator — Monthly', () {
    test('3. monthly period — reference Mar 20 with start Jan 15 → period 2',
        () {
      final start = _d(2025, 1, 15);
      // Period 0: Jan 15 – Feb 15
      // Period 1: Feb 15 – Mar 15
      // Period 2: Mar 15 – Apr 15  ← reference Mar 20 is here
      final reference = _d(2025, 3, 20);
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        referenceEpochSeconds: _epoch(reference),
      );
      expect(
        DateTime.fromMillisecondsSinceEpoch(
          range.startEpochSeconds * 1000,
          isUtc: true,
        ),
        equals(_d(2025, 3, 15)),
      );
      expect(
        DateTime.fromMillisecondsSinceEpoch(
          range.endEpochSeconds * 1000,
          isUtc: true,
        ),
        equals(_d(2025, 4, 15)),
      );
    });

    test(
      '5. Jan 31 start: period 1 boundary = Feb 28 (non-leap 2025)',
      () {
        final start = _d(2025, 1, 31);
        // Period 0: Jan 31 – Feb 28
        // Period 1: Feb 28 – Mar 31  ← reference Mar 5 is here
        final reference = _d(2025, 3, 5);
        final range = calc.compute(
          startEpochSeconds: _epoch(start),
          recurrenceN: 1,
          recurrenceUnit: RecurrenceUnit.month,
          referenceEpochSeconds: _epoch(reference),
        );
        final periodStart = DateTime.fromMillisecondsSinceEpoch(
          range.startEpochSeconds * 1000,
          isUtc: true,
        );
        // Period 1 starts at Feb 28 (month-end clamping from Jan 31)
        expect(periodStart, equals(_d(2025, 2, 28)));
      },
    );

    test(
      '6. Jan 31 start: period 1 boundary = Feb 29 (leap year 2024)',
      () {
        final start = _d(2024, 1, 31);
        // Period 0: Jan 31 – Feb 29 (2024 is a leap year)
        // Period 1: Feb 29 – Mar 31  ← reference Mar 5 is here
        final reference = _d(2024, 3, 5);
        final range = calc.compute(
          startEpochSeconds: _epoch(start),
          recurrenceN: 1,
          recurrenceUnit: RecurrenceUnit.month,
          referenceEpochSeconds: _epoch(reference),
        );
        final periodStart = DateTime.fromMillisecondsSinceEpoch(
          range.startEpochSeconds * 1000,
          isUtc: true,
        );
        // Period 1 starts at Feb 29, 2024 (leap year)
        expect(periodStart, equals(_d(2024, 2, 29)));
      },
    );

    test(
      '7. March 31 start: period 1 boundary = April 30 (month-end clamping)',
      () {
        final start = _d(2025, 3, 31);
        // Period 0: Mar 31 – Apr 30
        // Period 1: Apr 30 – May 31  ← reference May 5 is here
        final reference = _d(2025, 5, 5);
        final range = calc.compute(
          startEpochSeconds: _epoch(start),
          recurrenceN: 1,
          recurrenceUnit: RecurrenceUnit.month,
          referenceEpochSeconds: _epoch(reference),
        );
        final periodStart = DateTime.fromMillisecondsSinceEpoch(
          range.startEpochSeconds * 1000,
          isUtc: true,
        );
        expect(periodStart, equals(_d(2025, 4, 30)));
      },
    );

    test('8. year boundary — Dec 15 start: period 1 starts Jan 15', () {
      final start = _d(2024, 12, 15);
      // Period 0: Dec 15 – Jan 15
      // Period 1: Jan 15 – Feb 15  ← reference Jan 20 is here
      final reference = _d(2025, 1, 20);
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        referenceEpochSeconds: _epoch(reference),
      );
      final periodStart = DateTime.fromMillisecondsSinceEpoch(
        range.startEpochSeconds * 1000,
        isUtc: true,
      );
      expect(periodStart, equals(_d(2025, 1, 15)));
    });
  });

  group('PeriodCalculator — Yearly', () {
    test('4. yearly period — reference Jul 2025 with start Jun 2023 → period 2',
        () {
      final start = _d(2023, 6, 1);
      // Period 0: Jun 1 2023 – Jun 1 2024
      // Period 1: Jun 1 2024 – Jun 1 2025
      // Period 2: Jun 1 2025 – Jun 1 2026  ← reference Jul 15 2025
      final reference = _d(2025, 7, 15);
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.year,
        referenceEpochSeconds: _epoch(reference),
      );
      final periodStart = DateTime.fromMillisecondsSinceEpoch(
        range.startEpochSeconds * 1000,
        isUtc: true,
      );
      final periodEnd = DateTime.fromMillisecondsSinceEpoch(
        range.endEpochSeconds * 1000,
        isUtc: true,
      );
      expect(periodStart, equals(_d(2025, 6, 1)));
      expect(periodEnd, equals(_d(2026, 6, 1)));
    });
  });

  group('PeriodCalculator — edge cases', () {
    test('9. reference before start → returns start period (period 0)', () {
      final start = _d(2025, 5, 1);
      final reference = _d(2025, 4, 1); // before start
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        referenceEpochSeconds: _epoch(reference),
      );
      final periodStart = DateTime.fromMillisecondsSinceEpoch(
        range.startEpochSeconds * 1000,
        isUtc: true,
      );
      expect(periodStart, equals(start));
    });

    test('10. custom period n=2 weeks — reference in period 1', () {
      final start = _d(2025, 1, 1);
      // Period 0: Jan 1 – Jan 15 (14 days)
      // Period 1: Jan 15 – Jan 29  ← reference Jan 16 is here
      final reference = _d(2025, 1, 16);
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 2,
        recurrenceUnit: RecurrenceUnit.week,
        referenceEpochSeconds: _epoch(reference),
      );
      final periodStart = DateTime.fromMillisecondsSinceEpoch(
        range.startEpochSeconds * 1000,
        isUtc: true,
      );
      expect(periodStart, equals(_d(2025, 1, 15)));
    });

    test('11. reference exactly on start → period 0', () {
      final start = _d(2025, 3, 1);
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        referenceEpochSeconds: _epoch(start),
      );
      final periodStart = DateTime.fromMillisecondsSinceEpoch(
        range.startEpochSeconds * 1000,
        isUtc: true,
      );
      expect(periodStart, equals(start));
    });

    test('12. reference exactly on period boundary → next period starts', () {
      final start = _d(2025, 1, 1);
      // Period 0: Jan 1 – Jan 8 (7 days)
      // Period 1: Jan 8 – Jan 15  ← reference is exactly Jan 8 (boundary)
      final reference = _d(2025, 1, 8);
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.week,
        referenceEpochSeconds: _epoch(reference),
      );
      final periodStart = DateTime.fromMillisecondsSinceEpoch(
        range.startEpochSeconds * 1000,
        isUtc: true,
      );
      expect(periodStart, equals(_d(2025, 1, 8)));
    });
  });

  group('PeriodCalculator — statelessness', () {
    test('13. two calls with same inputs yield same result', () {
      final start = _d(2025, 1, 1);
      final reference = _d(2025, 3, 15);
      final r1 = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        referenceEpochSeconds: _epoch(reference),
      );
      final r2 = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        referenceEpochSeconds: _epoch(reference),
      );
      expect(r1.startEpochSeconds, equals(r2.startEpochSeconds));
      expect(r1.endEpochSeconds, equals(r2.endEpochSeconds));
    });
  });

  group('PeriodCalculator — leap year edge cases', () {
    test('14. leap year 2000: Jan 31 start → period 1 boundary is Feb 29', () {
      final start = _d(2000, 1, 31);
      // Period 0: Jan 31 – Feb 29 (2000 is a leap year)
      // Period 1: Feb 29 – Mar 31  ← reference Mar 5 is here
      final reference = _d(2000, 3, 5);
      final range = calc.compute(
        startEpochSeconds: _epoch(start),
        recurrenceN: 1,
        recurrenceUnit: RecurrenceUnit.month,
        referenceEpochSeconds: _epoch(reference),
      );
      final periodStart = DateTime.fromMillisecondsSinceEpoch(
        range.startEpochSeconds * 1000,
        isUtc: true,
      );
      expect(periodStart, equals(_d(2000, 2, 29)));
    });

    test(
      '15. non-leap year 2100: Jan 31 start → period 1 boundary is Feb 28',
      () {
        final start = _d(2100, 1, 31);
        // 2100 is NOT a leap year (divisible by 100 but not 400)
        // Period 0: Jan 31 – Feb 28
        // Period 1: Feb 28 – Mar 31  ← reference Mar 5 is here
        final reference = _d(2100, 3, 5);
        final range = calc.compute(
          startEpochSeconds: _epoch(start),
          recurrenceN: 1,
          recurrenceUnit: RecurrenceUnit.month,
          referenceEpochSeconds: _epoch(reference),
        );
        final periodStart = DateTime.fromMillisecondsSinceEpoch(
          range.startEpochSeconds * 1000,
          isUtc: true,
        );
        expect(periodStart, equals(_d(2100, 2, 28)));
      },
    );
  });
}
