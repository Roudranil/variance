// test/unit/domain/core/result_test.dart
//
// Tests for Result<T>, Ok<T>, and Err<T> sealed types.
//
// Test cases:
//   1. Ok carries the correct value
//   2. Ok is a Result<T>
//   3. Err carries the correct Failure
//   4. Err is a Result<T>
//   5. Switch exhaustiveness: Ok branch executes on Ok
//   6. Switch exhaustiveness: Err branch executes on Err
//   7. Ok<void> is constructible with null
//   8. Nested Result is supported (Result<Result<int>>)
//   9. DatabaseFailure carries message
//  10. ValidationFailure carries message
//  11. NetworkFailure carries message
//  12. NotFoundFailure carries message
//  13. BusinessRuleFailure carries message
//  14. All Failure subtypes are Failure instances
//  15. Different Failure subtypes are not equal by type

import 'package:flutter_test/flutter_test.dart';

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';

void main() {
  group('Ok', () {
    test('1. carries the correct value', () {
      const result = Ok(42);
      expect(result.value, equals(42));
    });

    test('2. is a Result<int>', () {
      const result = Ok(1);
      expect(result, isA<Result<int>>());
    });

    test('7. Ok<void> is constructible with null value', () {
      const result = Ok<void>(null);
      expect(result, isA<Ok<void>>());
    });

    test('8. nested Result is supported', () {
      const inner = Ok(10);
      const outer = Ok<Result<int>>(inner);
      expect(outer.value, isA<Ok<int>>());
    });
  });

  group('Err', () {
    test('3. carries the correct Failure', () {
      const failure = DatabaseFailure('db error');
      const result = Err<int>(failure);
      expect(result.failure, equals(failure));
    });

    test('4. is a Result<int>', () {
      const result = Err<int>(DatabaseFailure('msg'));
      expect(result, isA<Result<int>>());
    });
  });

  group('Switch exhaustiveness', () {
    test('5. Ok branch executes on Ok', () {
      const Result<int> result = Ok(7);
      final output = switch (result) {
        Ok(:final value) => 'ok:$value',
        Err(:final failure) => 'err:${failure.message}',
      };
      expect(output, equals('ok:7'));
    });

    test('6. Err branch executes on Err', () {
      const Result<int> result = Err(ValidationFailure('bad input'));
      final output = switch (result) {
        Ok(:final value) => 'ok:$value',
        Err(:final failure) => 'err:${failure.message}',
      };
      expect(output, equals('err:bad input'));
    });
  });

  group('Failure hierarchy', () {
    test('9. DatabaseFailure carries message', () {
      const f = DatabaseFailure('sqlite error');
      expect(f.message, equals('sqlite error'));
    });

    test('10. ValidationFailure carries message', () {
      const f = ValidationFailure('amount must be positive');
      expect(f.message, equals('amount must be positive'));
    });

    test('11. NetworkFailure carries message', () {
      const f = NetworkFailure('timeout');
      expect(f.message, equals('timeout'));
    });

    test('12. NotFoundFailure carries message', () {
      const f = NotFoundFailure('account not found');
      expect(f.message, equals('account not found'));
    });

    test('13. BusinessRuleFailure carries message', () {
      const f = BusinessRuleFailure('debit != credit');
      expect(f.message, equals('debit != credit'));
    });

    test('14. all Failure subtypes are Failure instances', () {
      expect(const DatabaseFailure(''), isA<Failure>());
      expect(const ValidationFailure(''), isA<Failure>());
      expect(const NetworkFailure(''), isA<Failure>());
      expect(const NotFoundFailure(''), isA<Failure>());
      expect(const BusinessRuleFailure(''), isA<Failure>());
    });

    test('15. distinct Failure subtypes are not the same type', () {
      const Failure a = DatabaseFailure('x');
      const Failure b = ValidationFailure('x');
      expect(a, isNot(isA<ValidationFailure>()));
      expect(b, isNot(isA<DatabaseFailure>()));
    });
  });
}
