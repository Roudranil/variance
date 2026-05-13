// lib/domain/core/failure.dart
//
// Sealed failure hierarchy used as the error payload in Result<T>.
//
// Every cross-layer error must be mapped to one of these subtypes before
// crossing a layer boundary — raw exceptions must never propagate up.
//
// Subtypes:
//   DatabaseFailure       — SQLite / Drift write/read errors
//   ValidationFailure     — User input or business-rule pre-condition failures
//   NetworkFailure        — HTTP / connectivity errors (exchange rates, etc.)
//   NotFoundFailure       — Requested entity does not exist
//   BusinessRuleFailure   — Domain invariant violations (e.g. posting to deleted account)

/// Base type for all domain-layer error representations.
///
/// Carries a human-readable [message] suitable for display or logging.
sealed class Failure {
  const Failure(this.message);

  /// Human-readable description of the failure.
  final String message;
}

/// Wraps a SQLite / Drift exception that occurred during a database operation.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Represents an input or pre-condition validation error.
///
/// Returned before any database write is attempted when field-level or
/// cross-field rules are violated.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Wraps a network or HTTP error (e.g. exchange-rate fetch failure).
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Returned when a required entity is absent from the data store.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Returned when a domain business-rule invariant is violated at use-case level.
///
/// Examples: posting to a soft-deleted account, debits ≠ credits on a ledger
/// transaction, attempting to archive an already-archived template.
final class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure(super.message);
}

/// Returned by [CreateAccountUseCase] when a soft-deleted account with the same
/// name and category exists.
///
/// The UI should offer the user the option to reinstate the existing account
/// (TC-035) instead of creating a new one.
final class ReinstateOfferFailure extends Failure {
  /// Creates a [ReinstateOfferFailure] carrying the soft-deleted account id.
  ///
  /// Parameters:
  /// - [message]: Human-readable description.
  /// - [softDeletedId]: UUID of the soft-deleted account to reinstate.
  const ReinstateOfferFailure(super.message, {required this.softDeletedId});

  /// UUID of the soft-deleted account that can be reinstated.
  final String softDeletedId;
}

/// Returned by [SoftDeleteAccountUseCase] when the user tries to delete the
/// last remaining account (at least one account must always exist).
final class LastAccountFailure extends Failure {
  const LastAccountFailure(super.message);
}

/// Returned by [GetExchangeRateUseCase] when no cached rate exists for the
/// requested currency pair.
///
/// The caller should either display "Rate unavailable" or fall back to a
/// manual rate entry.
final class RateUnavailableFailure extends Failure {
  const RateUnavailableFailure(super.message);
}
