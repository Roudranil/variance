// lib/infrastructure/scheduling/app_initializer.dart
//
// AppInitializer — synchronous launch sweep before first frame (T-103).
//
// Called from main() before runApp(). Runs:
//   1. PostDueOccurrencesUseCase — posts all overdue auto_post occurrences.
//   2. GenerateLookaheadUseCase  — refreshes the 90-day materialized window.
//
// The count of auto-posted occurrences is stored in [lastAutoPostedCount]
// for use by the Catch-Up Banner (S-47).
//
// Spec: T-103, SCHED-01, SDS §1.4.3
//
// Test cases (see test/infrastructure/scheduling/app_initializer_test.dart):
//   1. both use cases called in order
//   2. lastAutoPostedCount set to count returned by PostDueOccurrencesUseCase
//   3. failure in PostDueOccurrencesUseCase is logged, lastAutoPostedCount = 0
//   4. failure in GenerateLookaheadUseCase is logged, does not affect count

import 'dart:developer' as dev;

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/usecases/recurring/generate_lookahead_use_case.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';

/// Synchronous launch sweep that runs before the first Flutter frame.
///
/// Provides a [lastAutoPostedCount] for use by the Catch-Up Banner (S-47).
/// All errors are logged and swallowed — a failed sweep must never crash the
/// app on launch.
class AppInitializer {
  AppInitializer._();

  /// Number of occurrences auto-posted in the most recent [run] call.
  ///
  /// Zero if [run] has not been called or if [PostDueOccurrencesUseCase]
  /// returned an error.
  static int lastAutoPostedCount = 0;

  /// Runs the launch sweep.
  ///
  /// Must be awaited in [main] before [runApp]. Completes synchronously
  /// from the caller's perspective (blocking the first frame is acceptable
  /// for a catch-up sweep; the DB is local and fast).
  ///
  /// Parameters:
  /// - [postDueOccurrences]: Posts all overdue auto_post occurrences.
  /// - [generateLookahead]: Refreshes the 90-day materialized window.
  static Future<void> run({
    required PostDueOccurrencesUseCase postDueOccurrences,
    required GenerateLookaheadUseCase generateLookahead,
  }) async {
    // Step 1: post overdue occurrences.
    try {
      final result = await postDueOccurrences.call();
      switch (result) {
        case Ok(:final value):
          lastAutoPostedCount = value;
          dev.log(
            'AppInitializer: posted $value overdue occurrence(s).',
            name: 'AppInitializer',
          );
        case Err(:final failure):
          lastAutoPostedCount = 0;
          dev.log(
            'AppInitializer: PostDueOccurrencesUseCase failed: '
            '${failure.message}',
            name: 'AppInitializer',
          );
      }
    } on Object catch (e) {
      lastAutoPostedCount = 0;
      dev.log(
        'AppInitializer: unexpected error in PostDueOccurrencesUseCase: $e',
        name: 'AppInitializer',
      );
    }

    // Step 2: refresh the 90-day lookahead window.
    try {
      final result = await generateLookahead.call();
      switch (result) {
        case Ok(:final value):
          dev.log(
            'AppInitializer: generated $value lookahead occurrence(s).',
            name: 'AppInitializer',
          );
        case Err(:final failure):
          dev.log(
            'AppInitializer: GenerateLookaheadUseCase failed: '
            '${failure.message}',
            name: 'AppInitializer',
          );
      }
    } on Object catch (e) {
      dev.log(
        'AppInitializer: unexpected error in GenerateLookaheadUseCase: $e',
        name: 'AppInitializer',
      );
    }
  }

  /// Resets state for test isolation.
  ///
  /// Call in [setUp] for any test that checks [lastAutoPostedCount].
  // ignore: unused_element — used by test suite
  static void clearForTest() => lastAutoPostedCount = 0;
}
