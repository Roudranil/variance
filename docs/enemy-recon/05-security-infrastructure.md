# Cashew Security & Infrastructure Intelligence Report

**Target:** Cashew (open-source Flutter personal expense tracker)
**Codebase location:** `/Users/rodas/code/variance/Cashew/budget/`
**Report date:** 2026-04-15
**Analyst:** Security & Infrastructure Specialist

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Authentication & Authorization](#2-authentication--authorization)
3. [Data Security & Privacy](#3-data-security--privacy)
4. [Backup & Restore](#4-backup--restore)
5. [Cloud Sync Architecture](#5-cloud-sync-architecture)
6. [Platform Abstractions](#6-platform-abstractions)
7. [In-App Purchases & Premium](#7-in-app-purchases--premium)
8. [Notifications & Background Processing](#8-notifications--background-processing)
9. [Deep Linking & Home Widgets](#9-deep-linking--home-widgets)
10. [Code Quality & Tooling](#10-code-quality--tooling)
11. [Onboarding Flow](#11-onboarding-flow)
12. [Vulnerability Summary](#12-vulnerability-summary)
13. [Lessons for Variance](#13-lessons-for-variance)

---

## 1. Executive Summary

Cashew is a local-first expense tracker built with Flutter and Drift (SQLite ORM). Its cloud features rely entirely on Google Sign-In, Google Drive (for backups and sync), and Firebase Firestore (for shared budgets). The app targets Android, iOS, and Web.

**Critical findings:**

- **No database encryption.** The SQLite database is stored as a plain `.sqlite` file on the device filesystem. There is no use of SQLCipher, `flutter_secure_storage`, or any encryption layer whatsoever.
- **Firebase credentials are hardcoded in source.** API keys for all three platforms (web, Android, iOS) are committed in `lib/firebase_options.dart`.
- **No Firestore security rules found in repo.** There are no `firestore.rules` files, meaning we cannot verify server-side authorization. The Firestore access patterns in the code suggest rules must exist on the server, but they are not version-controlled.
- **Sync protocol is last-write-wins with no real conflict resolution.** The entire SQLite database is uploaded/downloaded from Google Drive for sync. Merge conflicts are resolved by timestamp comparison with no vector clocks or CRDTs.
- **Verbose print-based logging exposes sensitive data paths in debug builds.**
- **Essentially zero test coverage.** The single test file is a Flutter scaffold placeholder that does not even compile against the actual app.

---

## 2. Authentication & Authorization

### 2.1 Firebase Auth (Google Sign-In)

**File:** `lib/struct/firebaseAuthGlobal.dart`

The entire auth system is built on Google Sign-In, using the resulting OAuth credential to authenticate with Firebase Auth. There are two auth paths:

1. **Authenticated (Google):** Uses `GoogleAuthProvider.credential` from `google_sign_in` to create an `OAuthCredential`, then calls `FirebaseAuth.instance.signInWithCredential()`.
2. **Anonymous:** `FirebaseAuth.instance.signInAnonymously()` -- used for anonymous Firestore access (e.g., shared budget discovery).

**Auth state management:**

The credential is cached in a module-level variable:

```dart
OAuthCredential? _credential;
```

And the Google user account is stored as a global mutable variable in `accountAndBackup.dart`:

```dart
signIn.GoogleSignInAccount? googleUser;
```

This is not a proper state management pattern -- it is a global mutable singleton with no lifecycle management, no refresh token handling, and no secure storage of tokens.

**Retry logic on credential failure:**

```dart
// In firebaseGetDBInstance():
_credential = null;
googleUser = null;
return await firebaseGetDBInstance(); // Recursive retry with no backoff or limit
```

This creates an infinite recursion risk if the credential repeatedly fails.

**User email stored in SharedPreferences:**

```dart
updateSettings("currentUserEmail", FirebaseAuth.instance.currentUser!.email, ...);
```

The user's email is stored in plaintext SharedPreferences, not secure storage.

### 2.2 Biometric Auth

**File:** `lib/struct/initializeBiometrics.dart`

Uses the `local_auth` package to gate app access behind biometrics/device lock:

- **Web excluded:** Biometrics are disabled on web (`kIsWeb` check returns `AuthResult.authenticated` immediately).
- **Bypass on backup restore:** If a database was just imported (`isDatabaseImportedOnThisSession`), the biometric error is shown as a popup but the user is auto-authenticated. This is a deliberate UX choice to prevent lockout after restore, but it is a security gap -- anyone who can trigger a DB import bypasses the biometric lock.
- **Setting stored unprotected:** The `requireAuth` boolean is in SharedPreferences (plaintext). An attacker with filesystem access could flip this to `false` to disable the lock.

### 2.3 Security Assessment

| Aspect | Status | Severity |
|--------|--------|----------|
| Auth token storage | Global mutable variable, not secure storage | HIGH |
| Email in SharedPreferences | Plaintext | MEDIUM |
| Biometric bypass on restore | By design, but exploitable | MEDIUM |
| Credential retry | Infinite recursion risk | HIGH |
| No session expiry management | No explicit token refresh handling | MEDIUM |
| No `flutter_secure_storage` anywhere | Confirmed via grep -- zero usage | CRITICAL |

---

## 3. Data Security & Privacy

### 3.1 Database Encryption

**Finding: NONE.**

A grep for `encrypt`, `cipher`, `sqlcipher`, and `encryption` across the entire `lib/` directory returned zero relevant results (only a match in `iconObjects.dart` for an icon name).

The database is stored as:
- **Native (Android/iOS):** Plain `.sqlite` file in `getApplicationDocumentsDirectory()` (`lib/database/platform/native.dart`).
- **Web:** IndexedDB or `window.localStorage` via Drift's `DriftWebStorage` (`lib/database/platform/web.dart`). The localStorage fallback uses a `bin2str` codec (simple char code conversion) -- this is encoding, not encryption.

All financial data (amounts, account names, transaction details, budget information) is stored in the clear.

### 3.2 What Data Goes Where

| Data | Storage | Encrypted? |
|------|---------|-----------|
| All transactions, categories, budgets, wallets | Local SQLite (Drift) | No |
| User settings and preferences | SharedPreferences | No |
| Backup database files | Google Drive `appDataFolder` | No (plain .sqlite) |
| Shared budget data | Firebase Firestore | Transit only (TLS) |
| Shared transaction data | Firebase Firestore sub-collections | Transit only (TLS) |
| Attachment files | Google Drive (public "Cashew" folder) | No |
| User email | SharedPreferences | No |
| Sync timestamps | SharedPreferences (JSON string) | No |

### 3.3 Data Sanitization

There is no evidence of systematic input sanitization. The app uses Drift's parameterized queries (which prevents SQL injection at the local DB layer), but:

- Shared budget data is written directly to Firestore without sanitization.
- Transaction names, notes, and category names from shared budgets are inserted as-is.
- Deep link parameters are parsed and used with minimal validation (amount is `double.tryParse`, dates use `DateTime.parse`).

### 3.4 Attachment Privacy Concern

**File:** `lib/struct/uploadAttachment.dart`

Attachments (photos, files) are uploaded to a regular Google Drive folder named "Cashew" (not `appDataFolder`). The code has a commented-out section that would have made files publicly readable:

```dart
// Only if we want attachments to be publicly available
// drive.Permission permission = drive.Permission();
// permission.role = "reader";
// await driveApi.permissions.create(...)
```

This was intentionally not activated, but the files are still in a user-visible Drive folder. The `webViewLink` is returned and presumably stored, meaning anyone with the link could access the file if Drive sharing settings allow it.

---

## 4. Backup & Restore

### 4.1 Backup Format

**Files:** `lib/widgets/accountAndBackup.dart`, `lib/widgets/exportDB.dart`

Backups are **raw SQLite database files** uploaded to Google Drive's `appDataFolder` (hidden from the user in Drive UI but accessible via API).

Backup naming convention:
```
db-v{schemaVersion}-{deviceName}.sqlite
```

For sync backups:
```
sync-{clientID}.sqlite
```

**No encryption, no integrity checks, no checksums.** The file is the raw database bytes.

### 4.2 Export to Device

`exportDB.dart` exports the database as a `.sql` file via `saveFile()`. The filename includes a timestamp:

```dart
"cashew-" + cleanFileNameString(DateTime.now().toString()) + ".sql"
```

Again, plain unencrypted SQLite bytes.

### 4.3 Import/Restore

**File:** `lib/widgets/importDB.dart`

Import flow:
1. User picks a file via `FilePicker`.
2. A loose file extension check (`.sql` or `.sqlite`) produces a warning if the extension does not match, but import proceeds regardless.
3. `cancelAndPreventSyncOperation()` is called to halt any in-progress sync.
4. The file bytes are written directly to the database path via `overwriteDefaultDB()`.
5. The app requests a restart.

**No integrity validation:** There is no check that the imported file is a valid SQLite database, no schema version check, no checksum. A malformed or malicious `.sqlite` file could corrupt the app state.

### 4.4 Google Drive Backup Management

- **Auto-backups:** Configurable frequency (1-14 days). Runs on app launch if the last backup is older than the configured interval.
- **Backup limit:** Configurable (10-30). Old backups are deleted after a new one is created.
- **Settings backup:** `backupSettings()` is called before each backup to embed the current settings into the database (likely as a table row).

### 4.5 Backup Reminder

The app nudges users to back up every 7 logins if they are not signed in, configurable via `canShowBackupReminderPopup`.

---

## 5. Cloud Sync Architecture

### 5.1 Sync Protocol Overview

**File:** `lib/struct/syncClient.dart`

The sync system is a **full-database-copy, timestamp-based merge** protocol:

1. **Upload phase:** The current device uploads its entire SQLite database to Google Drive as `sync-{clientID}.sqlite`.
2. **Download phase:** The device downloads all other devices' sync backup files from Drive.
3. **Merge phase:** For each remote database, the device opens it as a temporary `FinanceDatabase`, queries for records modified after the last sync timestamp, and creates `SyncLog` entries.
4. **Apply phase:** `database.processSyncLogs(syncLogs)` applies all changes to the main database.
5. **Timestamp update:** The last-synced timestamp for each client is stored in SharedPreferences as a JSON map.

### 5.2 Conflict Resolution: Last-Write-Wins

The sync compares `dateTimeModified` timestamps. There is no vector clock, no merge strategy for concurrent edits, and no conflict detection UI. If two devices edit the same record, the one whose sync file was most recently uploaded wins.

The timestamp comparison:

```dart
DateTime lastSynced = await getDateOfLastSyncedWithClient(
    getDeviceFromSyncBackupFileName(file.name));
if (file.modifiedTime == null ||
    lastSynced.isAfter(file.modifiedTime!.toLocal()) ||
    lastSynced == file.modifiedTime!.toLocal()) {
  // Skip -- no new data from this client
  continue;
}
```

### 5.3 Delete Propagation

Deletions are tracked via a `DeleteLog` table. When syncing, delete logs are fetched alongside new records and applied in order. This is a soft-delete propagation mechanism.

### 5.4 Cancellation and Throttling

- A `CancelableCompleter` allows cancellation of in-progress syncs.
- A `Debouncer` with 5000ms delay prevents rapid-fire syncs.
- A `syncTimeoutTimer` prevents re-entry for 5 seconds.
- A global `canSyncData` boolean provides a mutex.

### 5.5 Offline Queue (Shared Budgets)

**File:** `lib/struct/shareBudget.dart`

When the device is offline and a shared transaction operation fails, the operation is queued in `appStateSettings["sendTransactionsToServerQueue"]` (SharedPreferences). The queue is flushed on next successful connection via `syncPendingQueueOnServer()`.

This is a rudimentary offline queue with no retry limits and no idempotency guarantees.

### 5.6 Sync Security Assessment

| Aspect | Status | Severity |
|--------|--------|----------|
| Full DB uploaded to Drive | Unencrypted | CRITICAL |
| No conflict resolution beyond LWW | Data loss risk | HIGH |
| Timestamps stored in SharedPreferences | Tamperable | MEDIUM |
| No sync integrity validation | Corrupted sync could break app | HIGH |
| Offline queue in SharedPreferences | Not durable, no idempotency | MEDIUM |

---

## 6. Platform Abstractions

### 6.1 Database Platform Layer

**Files:** `lib/database/platform/shared.dart`, `native.dart`, `web.dart`, `unsupported.dart`

The platform abstraction uses Dart's conditional exports:

```dart
// shared.dart
export 'unsupported.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';
```

Each platform implements three functions: `constructDb()`, `getCurrentDBFileInfo()`, and `overwriteDefaultDB()`.

**Native (Android/iOS):**
- Uses `NativeDatabase` from Drift with a `MultiExecutor` (foreground for reads, background for writes).
- Database stored in `getApplicationDocumentsDirectory()`.

**Web:**
- Uses `DriftWebStorage.indexedDbIfSupported()` for IndexedDB.
- Falls back to `window.localStorage` with `bin2str` encoding.
- Has an `InMemoryWebStorage` for temporary sync databases.

**Unsupported:**
- Throws `UnimplementedError` for all three functions.

### 6.2 Binary/String Conversion

**File:** `lib/database/binary_string_conversion.dart`

A `Codec<Uint8List, String>` that converts binary data to/from strings using `String.fromCharCodes`. This is used for the web localStorage fallback. It chunks data at 0xFFFF boundaries to avoid browser limits. This is purely encoding (not encryption).

### 6.3 Scroll Behavior

**File:** `lib/struct/scrollBehaviorOverride.dart`

A simple `MaterialScrollBehavior` override that:
- Adds mouse drag support (for web/desktop).
- Switches to `BouncingScrollPhysics` when iOS emulation is enabled.

### 6.4 Platform Detection

The app uses a custom `getPlatform()` utility (referenced extensively) that returns `PlatformOS.isIOS`, `PlatformOS.isAndroid`, or detects web. An `iOSEmulate` debug flag can override behavior.

---

## 7. In-App Purchases & Premium

### 7.1 Premium Features

**File:** `lib/pages/premiumPage.dart`

Premium gating affects:
- **Unlimited budgets and goals** (free tier limited to 1 of each).
- **Past budget period viewing.**
- **Unlimited color picker.**
- **Support the developer.**

### 7.2 Purchase Verification

The app uses the `in_app_purchase` Flutter package, delegating verification entirely to the platform stores (Google Play / App Store). There is **no server-side receipt validation.**

Purchase state is stored in `appStateSettings["purchaseID"]` (SharedPreferences). On each app launch:

```dart
// Reset any purchases if we can connect to the store
updateSettings("purchaseID", null, updateGlobalState: false);
// ... then restore purchases
await InAppPurchase.instance.restorePurchases();
```

This means the purchase state is re-verified from the store on every launch, which is a reasonable pattern for a non-server app.

### 7.3 Product IDs

```dart
Map<String, String> productIDs = {
  'yearly': 'cashew.pro.yearly',
  'monthly': 'cashew.pro.monthly',
  'lifetime': getPlatform(...) == PlatformOS.isIOS
      ? 'cashew.pro.life'    // iOS
      : 'cashew.pro.lifetime', // Android
};
```

### 7.4 "Continue for Free" Bypass

The premium page includes a deliberate free bypass. First-time users must wait through a 26-second timer before they can unlock for free. Subsequent visits show the bypass immediately. This is a soft gate, not a hard paywall.

```dart
int remainingTime = appStateSettings["premiumPopupFreeSeen"] != true ? 26 : 0;
```

### 7.5 Premium Popup Frequency

The premium popup is shown after every 5 transactions, resetting daily:

```dart
if (appStateSettings["premiumPopupAddTransactionCount"] > 5) {
  // Show premium page
}
```

### 7.6 Web Handling

IAP is disabled on web (`premiumPopupEnabled = kIsWeb == false`). Debug mode also disables the store (`tryStoreEnabled = kIsWeb == false && kDebugMode == false`).

---

## 8. Notifications & Background Processing

### 8.1 Notification System

**Files:** `lib/struct/notificationsGlobal.dart`, `lib/struct/initializeNotifications.dart`

Uses `flutter_local_notifications` for scheduling:

- **Daily reminders:** Configurable time of day, with an option to trigger based on the user's typical app-open time.
- **Upcoming transaction notifications:** Scheduled for subscription/recurring transactions.
- **iOS limitation:** The plugin initialization is skipped on iOS because "iOS cannot send scheduled notifications when the app is open."

### 8.2 Notification Payloads

Payloads are simple string identifiers:
- `"addTransaction"` -- opens the add transaction page.
- `"upcomingTransaction"` -- marks overdue subscriptions as paid, then opens the overdue page.
- `"openTransaction?transactionPk=..."` -- opens a specific transaction for editing.

### 8.3 Notification Listener Service (Android)

The AndroidManifest declares a `NotificationListenerService`:

```xml
<service android:label="notifications"
    android:name="notification.listener.service.NotificationListener"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="true">
```

This is used for the experimental "notification scanning" feature (parsing incoming push notifications from banking apps to auto-create transactions). This feature is gated behind a debug flag (`notificationScanningDebug`) and is not enabled by default. **This is a significant privacy surface** -- it reads all device notifications.

### 8.4 Background Processing

There are no background workers, isolates, or `WorkManager` integrations. All processing (sync, backup, notification scheduling) happens in the main app process when the app is in the foreground.

---

## 9. Deep Linking & Home Widgets

### 9.1 Deep Linking

**File:** `lib/widgets/util/appLinks.dart`

The app handles deep links via the `app_links` package. Supported URI patterns:

- `https://cashewapp.web.app/addTransaction?...` -- directly creates a transaction.
- `https://cashewapp.web.app/addTransactionRoute?...` -- opens the add transaction page pre-filled.

Supported parameters: `amount`, `title`/`name`, `notes`/`note`, `date`/`dateCreated`, `category`/`categoryPk`, `subcategory`/`subcategoryPk`, `wallet`/`walletPk`/`account`, `messageToParse` (for notification scanning), `JSON` (batch transactions).

**Security concern:** The deep link handler has minimal validation:

```dart
Future executeAppLink(BuildContext? context, Uri uri, ...) async {
  if (appStateSettings["hasOnboarded"] != true) return;
  if (!appLinksThrottler.canProceed()) return;
  String endPoint = getApiEndpoint(uri);
  Map<String, String> params = parseAppLink(uri);
  // ... switch on endPoint
}
```

There is no host validation, no scheme validation, and no allowlist of origins. The throttler (350ms) provides minimal protection against rapid-fire abuse. The `messageToParse` parameter is only processed if a debug flag is on, which limits that attack surface.

The `JSON` parameter deserializes arbitrary JSON and creates transactions from it:

```dart
Map<String, dynamic> jsonData = json.decode(params["JSON"] ?? "");
for (dynamic transactionObject in jsonData["transactions"]) {
  await processAddTransactionFromParams(context, currentObject);
}
```

An attacker could craft a URL that, when opened by the user, creates arbitrary transactions in the database.

### 9.2 Android Deep Link Verification

The AndroidManifest includes `android:autoVerify="true"` intent filters for `cashewapp.web.app` with `/addTransaction` and `/addTransactionRoute` paths:

```xml
<intent-filter android:autoVerify="true">
    <data android:scheme="https" android:host="cashewapp.web.app" android:pathPrefix="/addTransaction"/>
    <data android:scheme="https" android:host="cashewapp.web.app" android:pathPrefix="/addTransactionRoute"/>
</intent-filter>
```

### 9.3 Home Screen Widgets (Android Only)

**File:** `lib/widgets/util/checkWidgetLaunch.dart`

Four Android home screen widgets via `home_widget` package:

1. **PlusWidgetProvider** -- Quick "Add Transaction" shortcut.
2. **TransferWidgetProvider** -- Quick "Transfer" shortcut.
3. **NetWorthWidgetProvider** -- Displays net worth amount.
4. **NetWorthPlusWidgetProvider** -- Net worth + add transaction combined.

Widget data (net worth amount, transaction count, theme colors) is stored via `HomeWidget.saveWidgetData<String>()`. The net worth amount is rendered as a formatted string. **This means financial totals are exposed to the Android widget system in plaintext.**

Widget actions use URI-style payloads: `"addTransactionWidget"`, `"transferTransactionWidget"`, `"netWorthLaunchWidget"`.

---

## 10. Code Quality & Tooling

### 10.1 Lint Rules

**File:** `analysis_options.yaml`

Extremely minimal configuration:

```yaml
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    # All default rules, nothing added or removed
```

No custom rules enabled. `avoid_print` is commented out (and indeed, `print()` is used extensively throughout the codebase for logging). The project uses the legacy `flutter_lints` instead of the newer `flutter_lints` (which provides stronger defaults).

### 10.2 Logging

**File:** `lib/struct/logging.dart`

A custom `LogService` that:
- Captures all `print()` output via `runZonedGuarded` with a custom `ZoneSpecification`.
- Stores logs in memory (max 12,500 entries, trimmed to 10,000).
- Logs are viewable in-app via the debug page.
- Logs can be copied to clipboard.
- Logging is gated behind an `appStateSettings["logging"]` flag.

There is no log sanitization -- sensitive data printed anywhere in the app (emails, transaction details, error messages with user data) ends up in the log.

### 10.3 Debug Page

**File:** `lib/pages/debugPage.dart`

A comprehensive debug toolbox including:
- Toggle flags for graph behavior, UI options, haptic feedback.
- **"Redo migration" button** that sets the DB version back to 37.
- **"Force full sync"** that resets all sync timestamps.
- **"Clean database delete logs"** (with a warning to sync first).
- **"Create preview data"** and **"Create random transactions"** (gated behind `allowDangerousDebugFlags`).
- **App link testing tool** -- a text input where you can paste and execute arbitrary deep links.
- Notification testing, backup forcing, vacuum/clean DB.
- Color theme debug display.

The `DangerousDebugFlag` wrapper hides certain operations unless `allowDangerousDebugFlags` is true.

### 10.4 Testing Strategy

**Finding: Effectively zero test coverage.**

The only test file (`test/widget_test.dart`) is the default Flutter scaffold test that does not import or reference any actual app code:

```dart
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

This test does not even reference the actual app widget and would fail if run. The two other test files belong to vendored third-party packages (`implicitly_animated_reorderable_list` and `sliding_sheet`), not the app itself.

There is no evidence of unit tests, integration tests, widget tests, or any CI pipeline.

### 10.5 Constants

**File:** `lib/struct/randomConstants.dart`

Pre-generated lists of 10 random integers and 10 random doubles, used for shimmer loading animations and preview data. These are regenerated on each app start (not seeded), which is fine for their purpose.

---

## 11. Onboarding Flow

**File:** `lib/pages/onBoardingPage.dart`

A 3-page swipeable onboarding:

1. **Welcome page:** App name, description, optional "Preview Demo" button that generates sample data.
2. **Budget setup:** User sets an initial budget amount, period, recurrence, and can change the primary currency.
3. **Sign-in page:** Platform-differentiated:
   - **Android:** "Sign in with Google" button (triggers Google Sign-In + full cloud sync), with a "Continue without sign-in" fallback.
   - **iOS:** Simple "Let's go" button (no Google sign-in during onboarding due to Apple guidelines).

Key detail: On Android, the onboarding sign-in triggers `runAllCloudFunctions()` after sign-in, which syncs data from any existing backups. This means a returning user on a new device can restore their data during onboarding.

The default database is initialized (`initializeDefaultDatabase()`) after the UI loads, ensuring the user has a wallet before creating their first budget.

---

## 12. Vulnerability Summary

### CRITICAL

| ID | Finding | Location |
|----|---------|----------|
| C1 | **No database encryption at rest.** All financial data stored in plaintext SQLite. | `lib/database/platform/native.dart`, `web.dart` |
| C2 | **No secure storage used anywhere.** Zero usage of `flutter_secure_storage`. Auth tokens, emails, settings all in SharedPreferences/globals. | Entire codebase (confirmed via grep) |
| C3 | **Firebase API keys committed to source.** Web, Android, and iOS API keys hardcoded. | `lib/firebase_options.dart` |
| C4 | **Unencrypted backups on Google Drive.** Raw SQLite files uploaded with no encryption wrapper. | `lib/widgets/accountAndBackup.dart` |

### HIGH

| ID | Finding | Location |
|----|---------|----------|
| H1 | **No Firestore security rules in repo.** Cannot verify server-side authorization for shared budgets. | Missing `firestore.rules` |
| H2 | **Infinite recursion in auth retry.** If credential refresh fails repeatedly, `firebaseGetDBInstance()` recurses without limit. | `lib/struct/firebaseAuthGlobal.dart:38` |
| H3 | **Deep link creates arbitrary transactions with no user confirmation (addTransaction endpoint).** | `lib/widgets/util/appLinks.dart:288` |
| H4 | **No backup integrity validation.** Imported files are not checked for valid SQLite structure or schema compatibility. | `lib/widgets/importDB.dart` |
| H5 | **Notification listener service reads all device notifications.** Even though gated behind a debug flag, the manifest permission is always declared. | `AndroidManifest.xml:87-92` |

### MEDIUM

| ID | Finding | Location |
|----|---------|----------|
| M1 | **Biometric lock bypass on DB import.** Auth error after restore auto-authenticates and disables `requireAuth`. | `lib/struct/initializeBiometrics.dart:87-93` |
| M2 | **No input sanitization on shared budget data.** Category names, transaction names from other users are inserted as-is. | `lib/struct/shareBudget.dart` |
| M3 | **Sync timestamps in SharedPreferences.** Tampering could force a full re-sync or prevent sync. | `lib/struct/syncClient.dart:51-71` |
| M4 | **`requestLegacyExternalStorage="true"`.** Broad storage access on older Android versions. | `AndroidManifest.xml:32` |
| M5 | **Verbose logging with no sanitization.** Emails, transaction data, error details printed to logs. | Throughout codebase |
| M6 | **Last-write-wins sync with no conflict detection.** Concurrent edits from multiple devices silently overwrite each other. | `lib/struct/syncClient.dart` |

### LOW

| ID | Finding | Location |
|----|---------|----------|
| L1 | **Minimal lint rules.** No custom analysis rules, `avoid_print` not enforced. | `analysis_options.yaml` |
| L2 | **Zero test coverage.** Placeholder test file only. | `test/widget_test.dart` |
| L3 | **Global mutable state for auth.** `googleUser`, `_credential`, `canSyncData` are module-level mutable variables. | Multiple files |

---

## 13. Lessons for Variance

### What Cashew Gets Right (Adopt)

1. **Local-first by default.** The app works fully offline. Cloud features are opt-in. This aligns with Variance's core constraint.
2. **Google Drive `appDataFolder` for backups.** This is a reasonable choice -- the folder is hidden from the user's Drive UI and only accessible by the app. Variance should consider this for any cloud backup feature.
3. **Drift ORM with platform-conditional exports.** The `shared.dart` pattern using `dart.library.ffi` / `dart.library.html` conditional exports is clean and idiomatic for cross-platform Drift.
4. **Delete logs for sync propagation.** Tracking deletions as log entries is a practical approach for multi-device scenarios.
5. **Offline queue for cloud operations.** The `sendTransactionsToServerQueue` pattern ensures operations are not lost when offline.

### What Cashew Gets Wrong (Avoid)

1. **No database encryption.** Variance MUST use SQLCipher or equivalent. For a finance app, plaintext SQLite is unacceptable.
2. **No `flutter_secure_storage`.** Auth tokens, sensitive settings, and encryption keys must use platform-secure storage (Keychain on iOS, EncryptedSharedPreferences on Android).
3. **Full-database sync via Drive.** This does not scale. As the database grows, uploading and downloading the entire file becomes slow and bandwidth-intensive. Variance should use a differential sync protocol (e.g., CRDTs or operational transforms on individual records).
4. **No server-side validation for shared features.** If Variance adds any multi-user features, Firestore security rules (or equivalent) must be version-controlled and tested.
5. **Global mutable state for auth.** Variance should use proper state management (Riverpod, BLoC) for auth state, with secure token persistence.
6. **Hardcoded Firebase config in source.** While Firebase API keys are designed to be public (security is enforced by Firestore rules and app restrictions), Variance should still use `--dart-define-from-file` for any service configuration to support multiple environments.
7. **Zero testing.** This is the clearest anti-pattern. Variance must maintain 80%+ coverage per our testing rules.
8. **Unvalidated deep links.** Any deep link handler must validate the origin, scheme, and all parameters before acting on them. The `addTransaction` endpoint that silently creates records is a significant attack vector.
9. **Unencrypted backups.** Any backup feature must encrypt the file before uploading. A user's financial data should not be readable by anyone with access to their Drive/storage.
10. **No backup integrity checks.** Variance must validate imported databases (schema version, table structure, checksums) before overwriting the active database.
