// lib/domain/core/result.dart
//
// Result<T> sealed type — explicit success/error return for all repository
// and use-case boundaries.
//
// Usage:
//   Future<Result<Account>> createAccount(Account account) async { ... }
//
//   final result = await createAccount(account);
//   switch (result) {
//     case Ok(:final value):  // use value
//     case Err(:final failure): // handle failure
//   }
//
// Rules (SDS §2.9.3):
//   - Use cases return Future<Result<T>>; they must never throw.
//   - Stream-returning methods do NOT use Result<T> — errors surface via
//     StreamController.addError and are handled at the presentation layer.
//   - The bang operator (.value!) is prohibited; always switch-exhaust both
//     branches.

import 'package:variance/domain/core/failure.dart';

/// Sealed return type that makes success and failure explicit in the type
/// signature, preventing silent error swallowing across layer boundaries.
sealed class Result<T> {
  const Result();
}

/// Successful outcome carrying a [value] of type [T].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  /// The successful result value.
  final T value;
}

/// Failed outcome carrying a typed [failure] that describes the error.
final class Err<T> extends Result<T> {
  const Err(this.failure);

  /// Structured failure describing why the operation did not succeed.
  final Failure failure;
}
