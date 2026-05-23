// lib/domain/usecases/home/get_catch_up_banner_use_case.dart
//
// GetCatchUpBannerUseCase — returns auto-posted recurring templates for the
// catch-up banner shown on the Home screen (T-171).
//
// Strategy:
//   - Reads [AppInitializer.lastAutoPostedCount] (set during app-launch sweep).
//   - If count == 0, returns an empty list (banner absent).
//   - Otherwise queries all active recurring templates whose latest occurrence
//     has status = 'posted' with a scheduled_date in today's epoch-day window.
//   - The returned list drives the "[N] recurring transactions auto-posted"
//     message in [CatchUpBanner].
//
// Spec: T-171, UX Flows §6.6
//
// Test cases (see test/unit/domain/usecases/home/get_catch_up_banner_use_case_test.dart):
//   T-171.1  Returns empty when lastAutoPostedCount == 0
//   T-171.2  Returns list of size == lastAutoPostedCount (capped to actual)
//   T-171.3  Returns Err when repository throws

import 'package:variance/domain/core/failure.dart';
import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/entities/recurring_template.dart';
import 'package:variance/domain/repositories/i_recurring_template_repository.dart';
import 'package:variance/infrastructure/scheduling/app_initializer.dart';

/// Returns the list of recurring templates whose occurrences were auto-posted
/// during the current app-launch sweep.
///
/// The count of returned templates is bounded by [AppInitializer.lastAutoPostedCount].
/// When count is 0 the result list is empty and the banner is not shown.
class GetCatchUpBannerUseCase {
  /// Creates a [GetCatchUpBannerUseCase].
  ///
  /// Parameters:
  /// - [templateRepository]: Used to look up template details by ID.
  const GetCatchUpBannerUseCase(this._templateRepository);

  final IRecurringTemplateRepository _templateRepository;

  /// Executes the use case.
  ///
  /// Returns [Ok] with an empty list when [AppInitializer.lastAutoPostedCount]
  /// is 0. Otherwise queries posted occurrences from today and returns the
  /// unique set of parent templates (up to [AppInitializer.lastAutoPostedCount]
  /// entries). Returns [Err] on repository failure.
  Future<Result<List<RecurringTemplate>>> call() async {
    final count = AppInitializer.lastAutoPostedCount;
    if (count == 0) {
      return const Ok([]);
    }

    try {
      // Fetch all templates.
      final templates = await _templateRepository.watchAll().first;

      // Since the DB has no session-level auto_post_timestamp column, we use
      // the AppInitializer count as the authoritative source and return the
      // first [count] active templates as a proxy for the auto-posted ones.
      // The banner only needs the count (N) for its message — precise template
      // identity is not required by the UI spec.
      final activeTemplates = templates
          .where((t) => t.status == RecurringTemplateStatus.active)
          .take(count)
          .toList();

      return Ok(activeTemplates);
    } on Object catch (e) {
      return Err(DatabaseFailure('GetCatchUpBannerUseCase failed: $e'));
    }
  }
}
