// lib/presentation/providers/alerts_providers.dart
//
// Unified Riverpod providers for all Home screen alert cards (T-167).
//
// Provider graph:
//   alertsProvider (AlertsNotifier)
//     ← pendingOccurrencesProvider     (T-168, already in alerts_strip_providers)
//     ← creditCardAlertProvider         (T-169)
//     ← backupReminderProvider          (T-170)
//
// AlertsState:
//   - pendingOccurrences: List<PendingOccurrenceItem> — remind_and_confirm due
//   - creditCardAlerts:   List<CreditCardAlertItem>  — CC payment due
//   - showBackupReminder: bool                       — backup threshold reached
//
// Priority order in AlertsStrip (T-167):
//   1. Pending confirmations (highest)
//   2. Credit card payment due
//   3. Backup reminder (lowest)
//
// Test cases (see test/presentation/notifiers/alerts_notifier_test.dart):
//   T-167.1  Pending items appear before CC items in combined state
//   T-169.1  CC alert card rendered for creditCard accounts with due date in window
//   T-169.2  CC alert absent for accounts outside reminder window
//   T-170.1  Backup reminder shown when count >= 50 and no backup made
//   T-170.2  Backup reminder hidden when lastBackupAt is set

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:variance/domain/entities/account.dart';
import 'package:variance/domain/entities/account_detail.dart';
import 'package:variance/domain/entities/app_settings.dart';
import 'package:variance/domain/entities/money.dart';
import 'package:variance/domain/repositories/i_app_settings_repository.dart';
import 'package:variance/domain/services/backup_reminder_checker.dart';
import 'package:variance/presentation/providers/alerts_strip_providers.dart';
import 'package:variance/presentation/providers/app_settings_providers.dart';
import 'package:variance/presentation/providers/repository_providers.dart';

part 'alerts_providers.g.dart';

// ---------------------------------------------------------------------------
// CreditCardAlertItem
// ---------------------------------------------------------------------------

/// A credit card account paired with its payment-due metadata for display in
/// the AlertsStrip (T-169).
class CreditCardAlertItem {
  /// Creates a [CreditCardAlertItem].
  const CreditCardAlertItem({
    required this.account,
    required this.balance,
    required this.paymentDueDayOfMonth,
    required this.daysUntilDue,
  });

  /// The credit card account.
  final Account account;

  /// Current balance (amount owed) denominated in account currency.
  final Money balance;

  /// Day of month when payment is due (1–31).
  final int paymentDueDayOfMonth;

  /// Days remaining until payment due date (0 = today, negative = overdue).
  final int daysUntilDue;
}

// ---------------------------------------------------------------------------
// AlertsState
// ---------------------------------------------------------------------------

/// Immutable snapshot of all current alert data for the Home screen.
///
/// Combines all three alert types in their display-priority order:
///   1. [pendingOccurrences] — remind_and_confirm confirmations
///   2. [creditCardAlerts]  — CC payment due
///   3. [showBackupReminder] — backup threshold exceeded
class AlertsState {
  /// Creates an [AlertsState].
  const AlertsState({
    this.pendingOccurrences = const [],
    this.creditCardAlerts = const [],
    this.showBackupReminder = false,
  });

  /// Pending remind_and_confirm occurrences waiting for user confirmation.
  final List<PendingOccurrenceItem> pendingOccurrences;

  /// Credit card accounts with payment due within the reminder window.
  final List<CreditCardAlertItem> creditCardAlerts;

  /// Whether the backup reminder card should be displayed.
  final bool showBackupReminder;

  /// Returns true when at least one alert is present.
  bool get hasAlerts =>
      pendingOccurrences.isNotEmpty ||
      creditCardAlerts.isNotEmpty ||
      showBackupReminder;
}

// ---------------------------------------------------------------------------
// Credit Card Alert Provider (T-169)
// ---------------------------------------------------------------------------

/// Days before payment due date within which the reminder card is shown.
///
/// Cards appear when `daysUntilDue <= kCcReminderWindowDays`.
const kCcReminderWindowDays = 7;

/// Loads credit card accounts with a payment due date within the reminder
/// window (T-169).
///
/// Returns a list of [CreditCardAlertItem] sorted by [daysUntilDue] ascending
/// (most urgent first). Items whose due date has already passed (overdue) are
/// included with negative [daysUntilDue].
@riverpod
Future<List<CreditCardAlertItem>> creditCardAlerts(Ref ref) async {
  final accountRepo = await ref.watch(accountRepositoryProvider.future);
  final settingsValue = ref.watch(appSettingsProvider);
  final currency =
      settingsValue.value?.homeCurrency ?? 'INR';

  // Watch all accounts and filter to non-deleted credit cards.
  final allAccounts = await accountRepo.watchAll().first;
  final creditCards = allAccounts
      .where(
        (a) =>
            a.accountCategory == AccountCategory.creditCard && !a.isDeleted,
      )
      .toList();

  final today = DateTime.now();
  final items = <CreditCardAlertItem>[];

  for (final account in creditCards) {
    final details = await accountRepo.getAccountDetails(account.id);

    // Find the payment_due_date detail key.
    final dueDateDetail = details.where(
      (d) => d.detailKey == AccountDetailKey.paymentDueDate.value,
    ).firstOrNull;

    if (dueDateDetail?.detailValue == null) continue;

    // paymentDueDate stores day of month (1–31).
    final dueDayOfMonth = int.tryParse(dueDateDetail!.detailValue!);
    if (dueDayOfMonth == null) continue;

    // Compute the next occurrence of this day-of-month.
    final dueDate = _nextDueDate(today, dueDayOfMonth);
    final daysUntilDue = dueDate.difference(
      DateTime(today.year, today.month, today.day),
    ).inDays;

    // Only show within the reminder window.
    if (daysUntilDue > kCcReminderWindowDays) continue;

    // Get current balance (amount owed on the card).
    final balance = await accountRepo.watchBalance(account.id, currency).first;

    items.add(
      CreditCardAlertItem(
        account: account,
        balance: balance,
        paymentDueDayOfMonth: dueDayOfMonth,
        daysUntilDue: daysUntilDue,
      ),
    );
  }

  // Sort by urgency: most overdue/soonest first.
  items.sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));
  return items;
}

/// Computes the next occurrence of [dayOfMonth] at or after [from].
///
/// If [dayOfMonth] is today or in the future within the current month, returns
/// that date. If [dayOfMonth] has already passed this month, returns the date
/// in the next month. Clamps to the last valid day of the month for months
/// shorter than [dayOfMonth].
DateTime _nextDueDate(DateTime from, int dayOfMonth) {
  final thisMonth = DateTime(from.year, from.month, dayOfMonth);
  // If the due day hasn't passed yet in the current month, use it.
  if (!thisMonth.isBefore(DateTime(from.year, from.month, from.day))) {
    return thisMonth;
  }
  // Otherwise use next month (clamped).
  final nextMonth = from.month == 12
      ? DateTime(from.year + 1, 1, 1)
      : DateTime(from.year, from.month + 1, 1);
  final lastDayOfNext = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
  return DateTime(
    nextMonth.year,
    nextMonth.month,
    dayOfMonth.clamp(1, lastDayOfNext),
  );
}

// ---------------------------------------------------------------------------
// Backup Reminder Provider (T-170)
// ---------------------------------------------------------------------------

/// Evaluates whether the backup reminder card should be shown (T-170).
///
/// Returns [BackupReminderResult] using [BackupReminderChecker] which checks:
///   - Days since onboarding >= 30, OR transaction count >= 50.
///   - Skips when [AppSettings.lastBackupAt] is not null.
@riverpod
Future<BackupReminderResult> backupReminder(Ref ref) async {
  final settingsValue = ref.watch(appSettingsProvider);
  final settings = settingsValue.value ?? const AppSettings();

  final settingsRepo = await ref.watch(appSettingsRepositoryProvider.future);
  final txRepo = await ref.watch(transactionRepositoryProvider.future);

  final onboardingCompletedAt = await settingsRepo.getOnboardingCompletedAt();

  final checker = BackupReminderChecker(transactionRepository: txRepo);
  return checker.check(
    settings: settings,
    onboardingCompletedAt: onboardingCompletedAt,
  );
}

// ---------------------------------------------------------------------------
// AlertsNotifier (T-167)
// ---------------------------------------------------------------------------

/// Combines all alert sources into a single [AlertsState] snapshot.
///
/// Watches [pendingOccurrencesProvider], [creditCardAlertsProvider], and
/// [backupReminderProvider] and merges them into one [AlertsState].
///
/// Display priority:
///   1. Pending confirmations (remind_and_confirm occurrences)
///   2. Credit card payment due alerts
///   3. Backup reminder
@riverpod
class AlertsNotifier extends _$AlertsNotifier {
  @override
  Future<AlertsState> build() async {
    final pendingAsync = ref.watch(pendingOccurrencesProvider);
    final ccAsync = ref.watch(creditCardAlertsProvider);
    final backupAsync = ref.watch(backupReminderProvider);

    final pending = pendingAsync.value ?? [];
    final cc = ccAsync.value ?? [];
    final backup = backupAsync.value;

    return AlertsState(
      pendingOccurrences: pending,
      creditCardAlerts: cc,
      showBackupReminder: backup?.shouldShow ?? false,
    );
  }

  /// Dismisses the backup reminder by writing the current epoch to
  /// [AppSettings.lastBackupAt].
  ///
  /// This marks the reminder as "acknowledged" so it does not appear again
  /// until [lastBackupAt] is reset (i.e., never shown again once dismissed).
  Future<void> dismissBackupReminder() async {
    final settingsRepo = await ref.read(appSettingsRepositoryProvider.future);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await settingsRepo.update(AppSettingsPatch(lastBackupAt: now));
    ref.invalidateSelf();
  }
}
