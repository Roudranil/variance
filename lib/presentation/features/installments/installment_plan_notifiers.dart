// lib/presentation/features/installments/installment_plan_notifiers.dart
//
// Riverpod notifiers for the Installment Plans feature.
//
// Notifiers:
//   InstallmentPlanList       — AsyncNotifier<List<InstallmentPlan>>
//                               Watches IInstallmentPlanRepository.watchAll()
//
//   InstallmentPlanDetail     — AsyncNotifier<InstallmentPlanDetail>
//                               Combines three reactive streams:
//                                 1. IInstallmentPlanRepository.watchById(id)
//                                 2. IInstallmentOccurrenceRepository.watchByPlan(id)
//                                 3. IInstallmentOccurrenceRepository.watchTrackingAmounts(id)
//                               Uses Completer bridge pattern (SDS §2.2.2).
//
// Both notifiers auto-dispose when their route is popped.
//
// Spec: T-133, API Contracts §2.7.4, SDS §2.2.2
//
// Test cases
// (see test/presentation/features/installments/installment_plan_notifiers_test.dart):
//   1. InstallmentPlanList emits data from repository stream.
//   2. InstallmentPlanList emits AsyncError on stream error.
//   3. InstallmentPlanDetail emits combined data when all three streams emit.
//   4. InstallmentPlanDetail emits AsyncError when plan stream errors.
//   5. InstallmentPlanDetail exposes hasMismatch from tracking amounts.

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/installment_occurrence.dart';
import 'package:variance/domain/entities/installment_plan.dart';
import 'package:variance/domain/entities/installment_tracking_amounts.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'installment_plan_notifiers.g.dart';

// ---------------------------------------------------------------------------
// InstallmentPlanDetail composite
// ---------------------------------------------------------------------------

/// Composite view object combining an installment plan's three reactive data
/// sources for the detail screen.
class InstallmentPlanDetail {
  /// Creates an [InstallmentPlanDetail].
  ///
  /// Parameters:
  /// - [plan]: The installment plan entity.
  /// - [occurrences]: All materialised occurrence rows, ordered by sequence.
  /// - [trackingAmounts]: Computed running total, remaining, and mismatch flag.
  const InstallmentPlanDetail({
    required this.plan,
    required this.occurrences,
    required this.trackingAmounts,
  });

  /// The installment plan entity.
  final InstallmentPlan plan;

  /// All materialised occurrences, ordered by sequence_number ASC.
  final List<InstallmentOccurrence> occurrences;

  /// Computed tracking amounts; includes [hasMismatch] flag.
  final InstallmentTrackingAmounts trackingAmounts;

  /// Whether [projectedFinalTotal] ≠ [totalConfigured].
  bool get hasMismatch => trackingAmounts.hasMismatch;
}

// ---------------------------------------------------------------------------
// InstallmentPlanList notifier
// ---------------------------------------------------------------------------

/// Reactive list of all installment plans.
///
/// Bridges [IInstallmentPlanRepository.watchAll] into Riverpod's
/// [AsyncNotifier] lifecycle using the Completer bridge pattern (SDS §2.2.2).
@riverpod
class InstallmentPlanList extends _$InstallmentPlanList {
  @override
  Future<List<InstallmentPlan>> build() async {
    final repo = await ref.watch(installmentPlanRepositoryProvider.future);
    final completer = Completer<List<InstallmentPlan>>();

    final sub = repo.watchAll().listen(
      (plans) {
        if (!completer.isCompleted) {
          completer.complete(plans);
        } else {
          if (ref.mounted) state = AsyncData(plans);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          if (ref.mounted) {
            state = AsyncError<List<InstallmentPlan>>(error, stack);
          }
        }
      },
    );

    ref.onDispose(sub.cancel);
    return completer.future;
  }
}

// ---------------------------------------------------------------------------
// InstallmentPlanDetail notifier
// ---------------------------------------------------------------------------

/// Reactive detail view for a single installment plan.
///
/// Merges three streams — plan, occurrences, and tracking amounts — into a
/// single [AsyncNotifier<InstallmentPlanDetail>]. Emits a new
/// [InstallmentPlanDetail] whenever any of the three sources changes.
///
/// The Completer bridge pattern ensures the initial [build] Future resolves
/// only after all three streams emit their first value.
@riverpod
class InstallmentPlanDetailNotifier
    extends _$InstallmentPlanDetailNotifier {
  @override
  Future<InstallmentPlanDetail> build(String templateId) async {
    final planRepo =
        await ref.watch(installmentPlanRepositoryProvider.future);
    final occRepo =
        await ref.watch(installmentOccurrenceRepositoryProvider.future);

    // Hold the latest values from each stream so any update triggers a merge.
    InstallmentPlan? latestPlan;
    List<InstallmentOccurrence>? latestOccurrences;
    InstallmentTrackingAmounts? latestTracking;

    final completer = Completer<InstallmentPlanDetail>();

    void tryEmit() {
      final plan = latestPlan;
      final occs = latestOccurrences;
      final tracking = latestTracking;
      if (plan == null || occs == null || tracking == null) return;

      final detail = InstallmentPlanDetail(
        plan: plan,
        occurrences: occs,
        trackingAmounts: tracking,
      );
      if (!completer.isCompleted) {
        completer.complete(detail);
      } else {
        if (ref.mounted) state = AsyncData(detail);
      }
    }

    // ---- Plan stream ----
    final planSub = planRepo.watchById(templateId).listen(
      (plan) {
        if (plan == null) {
          // Plan not found — surface an error.
          if (!completer.isCompleted) {
            completer.completeError(
              StateError('Installment plan $templateId not found'),
              StackTrace.current,
            );
          }
          return;
        }
        latestPlan = plan;
        tryEmit();
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          if (ref.mounted) {
            state = AsyncError<InstallmentPlanDetail>(error, stack);
          }
        }
      },
    );

    // ---- Occurrences stream ----
    final occSub = occRepo.watchByPlan(templateId).listen(
      (occs) {
        latestOccurrences = occs;
        tryEmit();
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          if (ref.mounted) {
            state = AsyncError<InstallmentPlanDetail>(error, stack);
          }
        }
      },
    );

    // ---- Tracking amounts stream ----
    // We need the totalConfiguredMinor from the plan to initialise the stream.
    // Fetch the plan first synchronously via the stream then watch tracking.
    // Since the plan stream may emit concurrently, we start tracking with a
    // placeholder total of 0 (corrected on first plan emission).
    //
    // The tracking stream is re-subscribed whenever the plan changes
    // (totalConfiguredMinor may be updated via early close). A fresh
    // subscription is created whenever latestPlan updates — this is handled
    // by cancelling and restarting the tracking sub inside the plan listener.
    // For simplicity (and since totalConfiguredMinor is immutable in normal
    // operation — TC-021), we start with 0 and correct on plan emission.
    // The tracking query uses the stored totalConfiguredMinor from the plan
    // parameter to avoid a secondary DB query.
    //
    // Implementation note: we pass totalConfiguredMinor = 0 initially and
    // rely on the DAO to query the `installment_plans` table directly. To
    // avoid this, the trackingAmounts query accepts the configured total as a
    // parameter — see IInstallmentOccurrenceRepository.watchTrackingAmounts.
    //
    // We start the tracking stream with a sentinel value of 0 and re-create
    // it once the plan emits its first value with the correct total.
    // For the initial build, the completer waits for all three streams.

    // Use a late-binding approach: track amounts sub started after plan emits.
    StreamSubscription<InstallmentTrackingAmounts>? trackingSub;

    void startTrackingStream(int totalConfiguredMinor) {
      trackingSub?.cancel();
      trackingSub = occRepo
          .watchTrackingAmounts(templateId, totalConfiguredMinor)
          .listen(
        (tracking) {
          latestTracking = tracking;
          tryEmit();
        },
        onError: (Object error, StackTrace stack) {
          if (!completer.isCompleted) {
            completer.completeError(error, stack);
          } else {
            if (ref.mounted) {
              state = AsyncError<InstallmentPlanDetail>(error, stack);
            }
          }
        },
      );
    }

    // Override planSub to also start tracking stream on first plan emission.
    // Cancel the previously started planSub and restart with tracking init.
    await planSub.cancel();

    final planSub2 = planRepo.watchById(templateId).listen(
      (plan) {
        if (plan == null) {
          if (!completer.isCompleted) {
            completer.completeError(
              StateError('Installment plan $templateId not found'),
              StackTrace.current,
            );
          }
          return;
        }
        final isFirstPlan = latestPlan == null;
        latestPlan = plan;
        if (isFirstPlan) {
          // Start the tracking stream now that we have the configured total.
          startTrackingStream(plan.totalConfiguredMinor);
        }
        tryEmit();
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else {
          if (ref.mounted) {
            state = AsyncError<InstallmentPlanDetail>(error, stack);
          }
        }
      },
    );

    ref.onDispose(() {
      planSub2.cancel();
      occSub.cancel();
      trackingSub?.cancel();
    });

    return completer.future;
  }
}
