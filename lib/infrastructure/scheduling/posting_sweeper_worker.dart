// lib/infrastructure/scheduling/posting_sweeper_worker.dart
//
// PostingSweeperWorker — WorkManager background task that runs the posting
// sweep when the app is not in the foreground (T-104, SCHED-01).
//
// Registration:
//   Call [PostingSweeperWorker.register] once on app startup.
//   WorkManager deduplicates via [kPostingSweeperTaskTag] with
//   ExistingWorkPolicy.keep so repeated calls are safe.
//
// Execution:
//   The top-level [postingSweeperCallbackDispatcher] is registered with
//   Workmanager().initialize() in main() before runApp().
//   It rebuilds the use-case graph from providers and calls both use cases.
//
// Constraints:
//   - frequency: 6 hours
//   - NetworkType.not_required (works offline)
//   - requiresCharging: false
//   - requiresDeviceIdle: false
//
// RECEIVE_BOOT_COMPLETED permission is declared in AndroidManifest.xml to
// allow WorkManager to re-register tasks after device restart.
//
// Spec: T-104, SCHED-01, SDS §2.6.1
//
// Test cases (see test/infrastructure/scheduling/posting_sweeper_worker_test.dart):
//   1. register() registers a periodic task with 6h frequency
//   2. execute() calls both use cases and returns true on success
//   3. execute() returns true on use-case failure (silent failure)

import 'dart:developer' as dev;

import 'package:variance/domain/core/result.dart';
import 'package:variance/domain/usecases/recurring/generate_lookahead_use_case.dart';
import 'package:variance/domain/usecases/recurring/post_due_occurrences_use_case.dart';
import 'package:workmanager/workmanager.dart';

/// Unique task name for WorkManager registration.
const kPostingSweeperTaskName = 'posting_sweeper';

/// Unique tag used for deduplication in WorkManager.
const kPostingSweeperTaskTag = 'posting_sweeper_tag';

/// Minimum interval between sweeps (6 hours).
///
/// WorkManager may delay execution beyond this minimum depending on device
/// state and battery optimisations. The app-launch sweep is the primary
/// catch-up path; this worker is a best-effort supplementary sweep.
const kPostingSweeperFrequency = Duration(hours: 6);

/// Stateless helper for registering the periodic posting sweep WorkManager task.
///
/// All collaborators are passed into [execute] so the top-level callback
/// can resolve them from the DI container without holding long-lived references.
class PostingSweeperWorker {
  const PostingSweeperWorker._();

  /// Registers the periodic WorkManager task.
  ///
  /// Uses [ExistingWorkPolicy.keep] so the task is registered at most once
  /// per install — repeated calls on app startup are safe.
  static Future<void> register() async {
    await Workmanager().registerPeriodicTask(
      kPostingSweeperTaskName,
      kPostingSweeperTaskName,
      tag: kPostingSweeperTaskTag,
      frequency: kPostingSweeperFrequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );
  }

  /// Executes the posting sweep logic.
  ///
  /// Called from the WorkManager callback. Runs both use cases and returns
  /// [true] in all cases — WorkManager's success signal. Errors are logged
  /// but swallowed; WorkManager will NOT retry on failure.
  ///
  /// Parameters:
  /// - [postDueOccurrences]: Posts overdue auto_post occurrences.
  /// - [generateLookahead]: Refreshes the 90-day materialized window.
  static Future<bool> execute({
    required PostDueOccurrencesUseCase postDueOccurrences,
    required GenerateLookaheadUseCase generateLookahead,
  }) async {
    try {
      final postResult = await postDueOccurrences.call();
      switch (postResult) {
        case Ok(:final value):
          dev.log(
            'PostingSweeperWorker: posted $value occurrence(s).',
            name: 'PostingSweeperWorker',
          );
        case Err(:final failure):
          dev.log(
            'PostingSweeperWorker: PostDueOccurrencesUseCase error: '
            '${failure.message}',
            name: 'PostingSweeperWorker',
          );
      }
    } on Object catch (e) {
      dev.log(
        'PostingSweeperWorker: unexpected error in PostDueOccurrencesUseCase: $e',
        name: 'PostingSweeperWorker',
      );
    }

    try {
      final lookaheadResult = await generateLookahead.call();
      switch (lookaheadResult) {
        case Ok(:final value):
          dev.log(
            'PostingSweeperWorker: generated $value lookahead occurrence(s).',
            name: 'PostingSweeperWorker',
          );
        case Err(:final failure):
          dev.log(
            'PostingSweeperWorker: GenerateLookaheadUseCase error: '
            '${failure.message}',
            name: 'PostingSweeperWorker',
          );
      }
    } on Object catch (e) {
      dev.log(
        'PostingSweeperWorker: unexpected error in GenerateLookaheadUseCase: $e',
        name: 'PostingSweeperWorker',
      );
    }

    // Always return true — WorkManager must not retry on error.
    return true;
  }
}
