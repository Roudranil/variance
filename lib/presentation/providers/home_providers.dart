// lib/presentation/providers/home_providers.dart
//
// Riverpod providers for the Home screen domain layer.
//
// Provider graph (T-146, T-147, T-148):
//   homeProvider (HomeNotifier, keepAlive)
//     ← watchNetWorthUseCaseProvider
//     ← watchMonthlySummaryUseCaseProvider
//       ← transactionRepositoryProvider
//       ← appSettingsProvider (for homeCurrency)
//
// HomeNotifier is keepAlive so state persists across tab switches.
// Use-case providers are auto-dispose (lightweight value objects).
//
// Test cases (see test/unit/domain/usecases/home/home_notifier_test.dart):
//   - homeProvider resolves with current month on cold start
//   - changeMonth updates selectedMonth and re-queries summary
//   - reload re-triggers build

import 'dart:async';
import 'dart:developer' as dev;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/home_state.dart';
import 'package:variance/domain/services/net_worth_calculator.dart';
import 'package:variance/domain/usecases/home/watch_monthly_summary_use_case.dart';
import 'package:variance/domain/usecases/home/watch_net_worth_use_case.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'home_providers.g.dart';

// ---------------------------------------------------------------------------
// Use case providers
// ---------------------------------------------------------------------------

/// Provides the [WatchNetWorthUseCase] instance.
///
/// Depends on the account repository, exchange rate repository, and the home
/// currency from [appSettingsProvider]. Re-created when the home currency
/// setting changes.
@riverpod
Future<WatchNetWorthUseCase> watchNetWorthUseCase(Ref ref) async {
  final accountRepo = await ref.watch(accountRepositoryProvider.future);
  final rateRepo = await ref.watch(exchangeRateRepositoryProvider.future);
  final settings = ref.watch(appSettingsProvider).value;
  final homeCurrency = settings?.homeCurrency ?? 'INR';

  return WatchNetWorthUseCase(
    accountRepository: accountRepo,
    exchangeRateRepository: rateRepo,
    calculator: const NetWorthCalculator(),
    homeCurrency: homeCurrency,
  );
}

/// Provides the [WatchMonthlySummaryUseCase] instance.
///
/// Depends on the transaction repository and the home currency from settings.
/// Re-created when the home currency setting changes.
@riverpod
Future<WatchMonthlySummaryUseCase> watchMonthlySummaryUseCase(Ref ref) async {
  final txRepo = await ref.watch(transactionRepositoryProvider.future);
  final settings = ref.watch(appSettingsProvider).value;
  final homeCurrency = settings?.homeCurrency ?? 'INR';

  return WatchMonthlySummaryUseCase(
    transactionRepository: txRepo,
    homeCurrency: homeCurrency,
  );
}

// ---------------------------------------------------------------------------
// HomeNotifier
// ---------------------------------------------------------------------------

/// Reactive notifier for the Home screen dashboard state.
///
/// Bridges [WatchNetWorthUseCase] and [WatchMonthlySummaryUseCase] streams into
/// a single [AsyncValue<HomeState>] consumed by the Home screen widgets.
///
/// The selected month defaults to the current calendar month on first build.
/// Use [changeMonth] to update it; use [reload] to force a retry after errors.
@Riverpod(keepAlive: true)
class HomeNotifier extends _$HomeNotifier {
  // ---------------------------------------------------------------------------
  // Overridable use case accessors (for test subclassing)
  // ---------------------------------------------------------------------------
  // These getters are NOT called in the production build() path; they exist
  // so tests can subclass HomeNotifier and override build() while reusing
  // the changeMonth and reload implementations.
  //
  // Production build() always awaits the provider directly.
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Internal mutable state
  // ---------------------------------------------------------------------------

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  StreamSubscription<NetWorthResult>? _netWorthSub;
  StreamSubscription<MonthlySummary>? _summarySub;

  NetWorthResult? _latestNetWorth;
  MonthlySummary? _latestSummary;

  @override
  Future<HomeState> build() async {
    ref.onDispose(_cancelSubscriptions);

    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _latestNetWorth = null;
    _latestSummary = null;

    // Await use case resolution before subscribing to their streams.
    final nwUseCase = await ref.watch(watchNetWorthUseCaseProvider.future);
    final sumUseCase =
        await ref.watch(watchMonthlySummaryUseCaseProvider.future);

    final completer = Completer<HomeState>();

    // --- Net worth stream ---
    _netWorthSub = nwUseCase.call().listen(
      (result) {
        _latestNetWorth = result;
        _tryComplete(completer);
        // After initial resolve, update state on subsequent emissions.
        if (completer.isCompleted && ref.mounted && _latestSummary != null) {
          state = AsyncData(_buildState(result, _latestSummary!));
        }
      },
      onError: (Object error, StackTrace stack) {
        dev.log(
          'HomeNotifier: net worth error: $error',
          name: 'HomeNotifier',
          stackTrace: stack,
        );
        if (!completer.isCompleted) {
          completer.completeError(error, stack);
        } else if (ref.mounted) {
          state = AsyncError<HomeState>(error, stack);
        }
      },
    );

    // --- Monthly summary stream ---
    _summarySub = _subscribeSummary(
      sumUseCase,
      buildCompleter: completer,
    );

    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Updates the selected month and re-queries the financial summary.
  ///
  /// The net worth stream is unaffected (it is not month-scoped).
  ///
  /// Parameters:
  /// - [year]: Four-digit calendar year.
  /// - [month]: 1-based calendar month (1 = January, 12 = December).
  Future<void> changeMonth(int year, int month) async {
    _selectedMonth = DateTime(year, month);
    _latestSummary = null;

    await _summarySub?.cancel();

    final sumUseCase =
        await ref.read(watchMonthlySummaryUseCaseProvider.future);
    _summarySub = _subscribeSummary(sumUseCase, buildCompleter: null);
  }

  /// Forces a rebuild of the notifier.
  ///
  /// Called by the retry button on the error card.
  void reload() {
    ref.invalidateSelf();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Subscribes to the monthly summary stream for the current [_selectedMonth].
  ///
  /// Parameters:
  /// - [useCase]: The resolved [WatchMonthlySummaryUseCase] instance.
  /// - [buildCompleter]: Completer to resolve after the first combined event.
  ///   Null when called from [changeMonth] (build is already resolved).
  StreamSubscription<MonthlySummary> _subscribeSummary(
    WatchMonthlySummaryUseCase useCase, {
    required Completer<HomeState>? buildCompleter,
  }) {
    return useCase.call(_selectedMonth.year, _selectedMonth.month).listen(
      (summary) {
        _latestSummary = summary;
        if (buildCompleter != null) {
          _tryComplete(buildCompleter);
        } else if (_latestNetWorth != null && ref.mounted) {
          state = AsyncData(_buildState(_latestNetWorth!, summary));
        }
      },
      onError: (Object error, StackTrace stack) {
        dev.log(
          'HomeNotifier: summary error: $error',
          name: 'HomeNotifier',
          stackTrace: stack,
        );
        if (buildCompleter != null && !buildCompleter.isCompleted) {
          buildCompleter.completeError(error, stack);
        } else if (ref.mounted) {
          state = AsyncError<HomeState>(error, stack);
        }
      },
    );
  }

  /// Completes [completer] once both net worth and summary have emitted.
  void _tryComplete(Completer<HomeState> completer) {
    if (completer.isCompleted) return;
    final nw = _latestNetWorth;
    final summary = _latestSummary;
    if (nw == null || summary == null) return;
    completer.complete(_buildState(nw, summary));
  }

  /// Constructs a [HomeState] from the current net worth and summary snapshots.
  HomeState _buildState(NetWorthResult netWorth, MonthlySummary summary) {
    final now = DateTime.now();
    final isFuture = _selectedMonth.year > now.year ||
        (_selectedMonth.year == now.year && _selectedMonth.month > now.month);

    return HomeState(
      selectedMonth: _selectedMonth,
      netWorthMinor: netWorth.totalMinor,
      netWorthCurrencyCode: netWorth.homeCurrency,
      hasStaleFx: netWorth.hasStaleRates || summary.hasStaleFx,
      hasNoFxRate: netWorth.hasStaleRates && netWorth.totalMinor == 0,
      isFutureMonth: isFuture,
      monthlySummary: summary,
    );
  }

  /// Cancels all active stream subscriptions.
  void _cancelSubscriptions() {
    _netWorthSub?.cancel();
    _summarySub?.cancel();
    _netWorthSub = null;
    _summarySub = null;
  }
}
