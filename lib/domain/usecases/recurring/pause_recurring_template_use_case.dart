// lib/domain/usecases/recurring/pause_recurring_template_use_case.dart
//
// Use case: pause a recurring template for a defined duration.
//
// The pause duration can be specified as:
//   - M units of the template's recurrence unit (e.g. 3 months for a monthly
//     template), computed as `startDate + M * recurrenceUnit`.
//   - A custom absolute date; the epoch of midnight UTC on that date.
//
// Business rules (RECUR-03):
//   - Pause duration is required; open-ended pause is not allowed.
//   - Custom date must be strictly in the future (> now).
//   - N must be > 0 when using unit-based duration.
//   - On pause, all pending occurrences whose scheduled_date <= pause_until are
//     marked skipped in a single batch operation.
//   - Template status is set to 'paused' + pause_until written.
//
// Spec: T-113, RECUR-03, API Contracts §2.6.1, §2.6.3
//
// Test cases (see test/unit/domain/usecases/pause_recurring_template_use_case_test.dart):
//   1. N-units pause: computes correct pause_until epoch.
//   2. Custom date pause: pause_until equals midnight UTC of the custom date.
//   3. N = 0 returns ValidationFailure.
//   4. Custom date in the past returns ValidationFailure.
//   5. Pending occurrences within pause window are skipped.
//   6. Occurrences after pause_until are not skipped.
//   7. Template not found returns NotFoundFailure.

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/domain/repositories/i_scheduled_occurrence_repository.dart';

/// Input model for [PauseRecurringTemplateUseCase].
///
/// Exactly one of [durationN] + [durationUnit] (N-units mode) or
/// [customDate] (absolute date mode) must be provided.
class PauseInput {
  /// Creates a [PauseInput] in N-units mode.
  ///
  /// Parameters:
  /// - [templateId]: UUID of the template to pause.
  /// - [durationN]: Number of recurrence units to pause for; must be > 0.
  const PauseInput.byUnits({
    required this.templateId,
    required this.durationN,
  }) : customDate = null;

  /// Creates a [PauseInput] with an absolute custom date.
  ///
  /// Parameters:
  /// - [templateId]: UUID of the template to pause.
  /// - [customDate]: The date until which the template is paused; must be in
  ///   the future.
  const PauseInput.byDate({
    required this.templateId,
    required this.customDate,
  }) : durationN = null;

  /// UUID of the template to pause.
  final String templateId;

  /// Number of recurrence units to pause for; null in custom-date mode.
  final int? durationN;

  /// Custom pause-until date; null in N-units mode.
  final DateTime? customDate;
}

/// Pauses a recurring template for a defined duration.
///
/// Computes [pause_until] from [PauseInput], calls
/// [IRecurringTemplateRepository.pause], and marks all pending occurrences
/// within the pause window as skipped.
class PauseRecurringTemplateUseCase {
  /// Creates a [PauseRecurringTemplateUseCase].
  ///
  /// Parameters:
  /// - [templateRepository]: Repository for template lifecycle transitions.
  /// - [occurrenceRepository]: Repository for occurrence status mutations.
  const PauseRecurringTemplateUseCase(
    this._templateRepository,
    this._occurrenceRepository,
  );

  final IRecurringTemplateRepository _templateRepository;
  final IScheduledOccurrenceRepository _occurrenceRepository;

  /// Executes the pause flow.
  ///
  /// Returns [Ok(null)] on success. Returns [Err] with a [ValidationFailure]
  /// if the input is invalid, or [NotFoundFailure] if the template is missing.
  ///
  /// Parameters:
  /// - [input]: Pause duration specification.
  Future<Result<void>> call(PauseInput input) async {
    // Load the template to obtain recurrenceUnit for N-units computation.
    final template =
        await _templateRepository.watchById(input.templateId).first;
    if (template == null) {
      return Err(
        NotFoundFailure('Recurring template ${input.templateId} not found.'),
      );
    }

    // Compute pause_until epoch.
    final pauseUntilResult = _computePauseUntil(input, template);
    if (pauseUntilResult case Err(:final failure)) {
      return Err(failure);
    }
    final pauseUntilEpoch = (pauseUntilResult as Ok<int>).value;

    // Pause the template.
    final pauseResult = await _templateRepository.pause(
      input.templateId,
      pauseUntil: pauseUntilEpoch,
    );
    if (pauseResult case Err(:final failure)) {
      return Err(failure);
    }

    // Batch-skip all pending occurrences whose scheduled_date <= pause_until.
    await _skipOccurrencesInWindow(
      input.templateId,
      pauseUntilEpoch,
    );

    return const Ok(null);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Computes the [pause_until] Unix epoch seconds from [input] and [template].
  ///
  /// Returns [Ok(epochSeconds)] or [Err(ValidationFailure)] if input is invalid.
  Result<int> _computePauseUntil(PauseInput input, RecurringTemplate template) {
    if (input.customDate != null) {
      // Custom date mode: midnight UTC of the chosen date.
      final now = DateTime.now();
      final customMidnight = DateTime.utc(
        input.customDate!.year,
        input.customDate!.month,
        input.customDate!.day,
      );
      if (!customMidnight.isAfter(now)) {
        return const Err(
          ValidationFailure('Pause date must be strictly in the future'),
        );
      }
      return Ok(customMidnight.millisecondsSinceEpoch ~/ 1000);
    }

    // N-units mode.
    final n = input.durationN;
    if (n == null || n <= 0) {
      return const Err(
        ValidationFailure('Pause duration N must be greater than 0'),
      );
    }

    // Compute pause_until = now + N * recurrenceUnit (calendar arithmetic).
    final now = DateTime.now();
    final pauseUntil = switch (template.recurrenceUnit) {
      RecurrenceUnit.day => now.add(Duration(days: n)),
      RecurrenceUnit.week => now.add(Duration(days: n * 7)),
      RecurrenceUnit.month => DateTime(
          now.year,
          now.month + n,
          now.day,
          now.hour,
          now.minute,
          now.second,
        ),
      RecurrenceUnit.year => DateTime(
          now.year + n,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
        ),
    };

    return Ok(pauseUntil.millisecondsSinceEpoch ~/ 1000);
  }

  /// Marks all pending occurrences for [templateId] with
  /// scheduled_date ≤ [pauseUntilEpoch] as skipped.
  ///
  /// The scheduled_date column is stored as Unix epoch *days*; pause_until is
  /// epoch *seconds*. Convert: pauseUntilDays = pauseUntilEpoch ~/ 86400.
  Future<void> _skipOccurrencesInWindow(
    String templateId,
    int pauseUntilEpoch,
  ) async {
    final pauseUntilDays = pauseUntilEpoch ~/ 86400;
    // Use DateTime.fromMillisecondsSinceEpoch with a far-future upper bound
    // to fetch all pending occurrences, then filter client-side by date.
    final pending = await _occurrenceRepository.getPendingDue(
      DateTime.fromMillisecondsSinceEpoch(
        (pauseUntilDays + 1) * 86400 * 1000,
        isUtc: true,
      ),
    );

    // Filter to this template's pending occurrences within the pause window.
    final toSkip = pending
        .where(
          (o) =>
              o.templateId == templateId && o.scheduledDate <= pauseUntilDays,
        )
        .toList();

    // Batch skip — sequential calls; no transactional batch API exposed.
    for (final occ in toSkip) {
      await _occurrenceRepository.markSkipped(occ.id);
    }
  }
}
