# Cashew Deep Dive: Notification Parsing and Auto-Transaction System

## Executive Summary

Cashew implements a **dual-channel auto-transaction system**: one channel listens to **Android device notifications** in real-time, and the other scans **Gmail emails** on app launch. Both channels share the exact same parsing engine -- a user-configured **ScannerTemplate** system that uses **string-boundary extraction** (not regex, not ML). The user manually selects text boundaries from a sample message, and Cashew uses those boundaries to find the title and amount in all future matching messages.

The notification channel is **gated behind a debug flag** (`notificationScanningDebug`) and is not exposed to production users. The email channel is production-ready, gated behind its own feature flag (`emailScanning`).

---

## 1. Notification Listener System

### 1.1 Package and Registration

**Package:** `notification_listener_service: ^0.3.3` (declared in `pubspec.yaml` line 98)

**Android Manifest declaration** (`android/app/src/main/AndroidManifest.xml`, lines 87-92):

```xml
<service android:label="notifications"
    android:name="notification.listener.service.NotificationListener"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService" />
    </intent-filter>
</service>
```

This is an Android `NotificationListenerService` -- a system-level service that receives callbacks whenever any notification is posted or removed on the device. It requires explicit user permission granted through Android Settings (not a standard runtime permission dialog).

**Historical note:** There is a **commented-out** alternative package `flutter_notification_listener: ^1.3.2` in both `pubspec.yaml` (line 57) and `AndroidManifest.xml` (lines 125-141). This was a previous implementation that included a `RebootBroadcastReceiver` for surviving device reboots. It was abandoned in favor of the simpler `notification_listener_service` package.

### 1.2 Initialization Flow

**File:** `lib/pages/autoTransactionsPageEmail.dart`, lines 35-88

The notification listener is initialized as a **widget wrapper** in the main widget tree:

```
main.dart (line 155):
  OnAppResume
    -> InitializeBiometrics
      -> InitializeNotificationService  <-- HERE
        -> InitializeAppLinks
          -> WatchForDayChange
            -> ...
```

The `InitializeNotificationService` StatefulWidget calls `initNotificationScanning()` in `initState` via a `Future.delayed(Duration.zero, ...)`:

```dart
Future initNotificationScanning() async {
  // 1. Only on Android
  if (getPlatform(ignoreEmulation: true) != PlatformOS.isAndroid) return;
  
  // 2. Cancel any existing subscription
  notificationListenerSubscription?.cancel();
  
  // 3. Check the feature flag
  if (appStateSettings["notificationScanning"] != true) return;
  
  // 4. Request notification listener permission
  bool status = await requestReadNotificationPermission();
  
  // 5. Subscribe to notification stream
  if (status == true) {
    notificationListenerSubscription =
        NotificationListenerService.notificationsStream.listen(onNotification);
  }
}
```

### 1.3 Permission Handling

```dart
Future<bool> requestReadNotificationPermission() async {
  bool status = await NotificationListenerService.isPermissionGranted();
  if (status != true) {
    status = await NotificationListenerService.requestPermission();
  }
  return status;
}
```

The `notification_listener_service` package's `requestPermission()` opens the Android system Settings page for Notification Access. The user must manually toggle the permission on. This is NOT a standard Android runtime permission -- it is a **special access permission** that opens a dedicated system settings page.

### 1.4 Notification Reception and Filtering

**There is NO filtering by app/package name.** Every notification that arrives on the device is processed.

The filtering happens downstream, in the ScannerTemplate matching. When a notification arrives:

```dart
// Global variables (top of file)
StreamSubscription<ServiceNotificationEvent>? notificationListenerSubscription;
List<String> recentCapturedNotifications = [];

onNotification(ServiceNotificationEvent event) async {
  // 1. Convert notification to a text string
  String messageString = getNotificationMessage(event);
  
  // 2. Store in recent list (max 50)
  recentCapturedNotifications.insert(0, messageString);
  recentCapturedNotifications.take(50);
  
  // 3. Attempt to create a transaction
  queueTransactionFromMessage(messageString);
}
```

### 1.5 Notification Data Extraction

The `getNotificationMessage` function extracts these fields from `ServiceNotificationEvent`:

```dart
String getNotificationMessage(ServiceNotificationEvent event) {
  String output = "";
  output = output + "Package name: " + event.packageName.toString() + "\n";
  output = output + "Notification removed: " + event.hasRemoved.toString() + "\n";
  output = output + "\n----\n\n";
  output = output + "Notification Title: " + event.title.toString() + "\n\n";
  output = output + "Notification Content: " + event.content.toString();
  return output;
}
```

**Extracted fields:**
- `event.packageName` -- The app that posted the notification (e.g., `com.chase.sig.android`)
- `event.hasRemoved` -- Whether the notification was removed (dismissed) vs. posted
- `event.title` -- The notification title
- `event.content` -- The notification body text

All of these are concatenated into a single flat string with labels. This means the ScannerTemplate `contains` field can match against any part of this string, including the package name. A template with `contains: "com.chase.sig.android"` would effectively filter to only Chase notifications.

### 1.6 Lifecycle Limitations

**Critical limitation: The notification listener only works while the Flutter engine is running.** The UI description confirms this:

> "When a notification is dismissed and the app is open, attempt to add a transaction given its information."

The `notification_listener_service` package (v0.3.3) uses a Dart stream that is only active while the Flutter engine is alive. When the app is killed or removed from recents, the stream dies. There is no background isolate, no foreground service, and no `WorkManager` setup.

The previously attempted `flutter_notification_listener` package (commented out) DID have a `RebootBroadcastReceiver` that could have survived reboots, but this was abandoned.

**The notification subscription is stored as a global `StreamSubscription?` variable** -- there is no persistence mechanism. On app restart, `initNotificationScanning()` is called again and creates a new subscription.

---

## 2. Auto-Transaction from Email

### 2.1 Gmail API Integration

**File:** `lib/pages/autoTransactionsPageEmail.dart`, lines 391-610

**OAuth flow:**
- Uses Google Sign-In (`google_sign_in` package) with Gmail scopes
- Scopes requested: `GmailApi.gmailReadonlyScope` + `GmailApi.gmailModifyScope` (for marking emails as read)
- Authentication is done through `signInGoogle()` in `lib/widgets/accountAndBackup.dart`
- Uses a custom `GoogleAuthClient` (extends `http.BaseClient`) that injects auth headers into requests

**Email scanning triggers:**
1. **On app launch** (`parseEmailsInBackground` called from `navigationFramework.dart`, line 317) -- runs once when `entireAppLoaded == false`
2. **Pull to refresh** -- if `emailScanningPullToRefresh` setting is true
3. **Manual refresh** -- button in AutoTransactionsPageEmail

### 2.2 Email Parsing Pipeline

```dart
Future<void> parseEmailsInBackground(context, ...) async {
  // Guard clauses
  if (appStateSettings["hasSignedIn"] == false) return;
  if (errorSigningInDuringCloud == true) return;
  if (appStateSettings["emailScanning"] == false) return;
  if (kIsWeb && !entireAppLoaded) return;
  
  // Only run once per app session (unless forceParse)
  if (entireAppLoaded == false || forceParse) {
    if (appStateSettings["AutoTransactions-canReadEmails"] == true) {
      // 1. Sign in to Google
      // 2. Get list of recent emails (configurable: 5, 10, 15, 20, or 25)
      gMail.ListMessagesResponse results = await gmailApi.users.messages
          .list(googleUser!.id.toString(), maxResults: amountOfEmails);
      
      // 3. For each email:
      for (gMail.Message message in results.messages!) {
        // Skip already-parsed emails (dedup by message ID)
        if (emailsParsed.contains(message.id!)) continue;
        
        // Fetch full message content
        gMail.Message messageData = await gmailApi.users.messages
            .get(googleUser!.id.toString(), message.id!);
        
        // Extract text from email
        String messageString = getEmailMessage(messageData);
        
        // Run through ScannerTemplate matching (same as notifications!)
        // ... (see Section 3)
        
        // Mark email as read
        gmailApi.users.messages.modify(
          gMail.ModifyMessageRequest(removeLabelIds: ["UNREAD"]),
          googleUser!.id, message.id!,
        );
      }
    }
  }
}
```

### 2.3 Email Content Extraction

```dart
String getEmailMessage(gMail.Message messageData) {
  // Try to get content from multipart message parts
  String messageEncoded = messageData.payload?.parts?[0].body?.data ?? "";
  
  if (messageEncoded == "") {
    // Fallback: try to decode the payload body directly (HTML)
    gMail.MessagePart payload = messageData.payload!;
    try {
      String htmlString = utf8
          .decode(payload.body!.dataAsBytes)
          .replaceAll("[^\\x00-\\x7F]", "");
      String parsedString = parseHtmlString(htmlString);
      messageString = parsedString;
    } catch (e) {
      // Last resort: use snippet
      messageString = (messageData.snippet ?? "") +
          "\n\n" + "There was an error getting the rest of the email";
    }
  } else {
    // Decode base64 content and parse HTML
    messageString = parseHtmlString(utf8.decode(base64.decode(messageEncoded)));
  }
  
  // Clean up whitespace: collapse spaces, normalize newlines, strip leading spaces
  return messageString
      .split(RegExp(r"[ \t\r\f\v]+")).join(" ")
      .replaceAll(new RegExp(r'(?:[\t ]*(?:\r?\n|\r))+'), '\n\n')
      .replaceAll(RegExp(r"(?<=\n) +"), "");
}
```

HTML parsing uses the `html` package's `parse()` function to extract text content from HTML emails.

### 2.4 Duplicate Prevention

Cashew uses a **message ID dedup list** stored in settings:

```dart
List<dynamic> emailsParsed =
    appStateSettings["EmailAutoTransactions-emailsParsed"] ?? [];

// For each email:
if (emailsParsed.contains(message.id!)) {
  print("Already checked this email!");
  continue;
}

// After processing (regardless of match):
emailsParsed.insert(0, message.id!);

// Persist the list, keeping 10 extra beyond the scan window
List<dynamic> emails = [
    ...emailsParsed.take(
        appStateSettings["EmailAutoTransactions-amountOfEmails"] + 10)
];
updateSettings("EmailAutoTransactions-emailsParsed", emails, ...);
```

The list is capped at `amountOfEmails + 10` to avoid unbounded growth while keeping a small buffer for recently deleted emails.

**For notifications, there is NO duplicate prevention.** Every notification that matches a template triggers the transaction creation flow. However, since notifications route to the `AddTransactionPage` UI (the user must confirm), accidental duplicates are less likely.

---

## 3. Scanner Templates -- The Parsing Engine

### 3.1 Database Schema

**File:** `lib/database/tables.dart`, lines 488-511

```dart
@DataClassName('ScannerTemplate')
class ScannerTemplates extends Table {
  TextColumn get scannerTemplatePk => text().clientDefault(() => uuid.v4())();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => new DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now())).nullable()();
  
  // User-facing name for this template (e.g., "Chase Debit", "Zelle Incoming")
  TextColumn get templateName => text().withLength(max: NAME_LIMIT)();
  
  // The substring that must be present in the message to match this template
  TextColumn get contains => text().withLength(max: NAME_LIMIT)();
  
  // Boundary strings for extracting the transaction title
  TextColumn get titleTransactionBefore => text().withLength(max: NAME_LIMIT)();
  TextColumn get titleTransactionAfter => text().withLength(max: NAME_LIMIT)();
  
  // Boundary strings for extracting the transaction amount
  TextColumn get amountTransactionBefore => text().withLength(max: NAME_LIMIT)();
  TextColumn get amountTransactionAfter => text().withLength(max: NAME_LIMIT)();
  
  // Default category when no associated title match is found
  TextColumn get defaultCategoryFk =>
      text().references(Categories, #categoryPk)();
  
  // Wallet to assign (or "-1" for primary/default wallet)
  TextColumn get walletFk =>
      text().references(Wallets, #walletPk).withDefault(const Constant("0"))();
  
  // TODO flag (not yet used)
  BoolColumn get ignore => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {scannerTemplatePk};
}
```

### 3.2 The Parsing Algorithm: String Boundary Extraction

This is the core intellectual contribution of Cashew's parsing system. It does NOT use regex patterns or ML. Instead, it uses a simple but effective approach:

**Step 1: Template Matching** -- find which template applies:

```dart
for (ScannerTemplate scannerTemplate in scannerTemplates) {
  if (messageString.contains(scannerTemplate.contains)) {
    templateFound = scannerTemplate;
    // ... extract title and amount
    break;  // FIRST MATCH WINS
  }
}
```

**Step 2: Title Extraction** via string boundaries:

```dart
String? getTransactionTitleFromEmail(String messageString,
    String titleTransactionBefore, String titleTransactionAfter) {
  String? title;
  try {
    // Find the "before" boundary, then start after it
    int startIndex = messageString.indexOf(titleTransactionBefore) +
        titleTransactionBefore.length;
    // Find the "after" boundary, searching from after the "before" boundary
    int endIndex = messageString.indexOf(titleTransactionAfter, startIndex);
    // Extract the text between the two boundaries
    title = messageString.substring(startIndex, endIndex);
    title = title.replaceAll("\n", "");
    title = title.toLowerCase();
    title = title.capitalizeFirst;
  } catch (e) {}
  return title;
}
```

**Step 3: Amount Extraction** via string boundaries:

```dart
double? getTransactionAmountFromEmail(String messageString,
    String amountTransactionBefore, String amountTransactionAfter) {
  double? amountDouble;
  try {
    int startIndex = messageString.indexOf(amountTransactionBefore) +
        amountTransactionBefore.length;
    int endIndex = messageString.indexOf(amountTransactionAfter, startIndex);
    String amountString = messageString.substring(startIndex, endIndex);
    // Strip all non-numeric characters except dots
    amountDouble = double.parse(amountString.replaceAll(RegExp('[^0-9.]'), ''));
  } catch (e) {}
  return amountDouble;
}
```

### 3.3 How the Boundary Strings are Determined

**File:** `lib/pages/addEmailTemplate.dart` -- The template creation wizard

The template creation follows a **guided wizard flow** where the user directly selects text from a sample message:

1. **Select a sample message** from the list of recent emails/notifications
2. **Select Subject Text** -- The user long-presses/double-taps to select a substring. This becomes the `contains` field (the template match string)
3. **Select Amount** -- The user selects the amount text. The system automatically captures **8 characters before and after** the selection as boundary strings
4. **Select Title** -- Same as amount -- user selects text, system captures surrounding context

The magic number is `int characterPadding = 8;` (line 41 of addEmailTemplate.dart).

The boundary capture logic (for amount, shown; title is identical):

```dart
onSelectionChanged: (selection, changeCause) {
  // Capture the 8 characters BEFORE the selection (with bounds checking)
  if (selection.baseOffset - characterPadding < 0) {
    amountTransactionBefore =
        messageString.substring(0, selection.baseOffset);
  } else {
    amountTransactionBefore = messageString.substring(
        selection.baseOffset - characterPadding,
        selection.baseOffset);
  }
  
  // Capture the 8 characters AFTER the selection (with bounds checking)
  if (selection.extentOffset + characterPadding >
      messageString.length - 1) {
    amountTransactionAfter = messageString.substring(
        selection.extentOffset, messageString.length);
  } else {
    amountTransactionAfter = messageString.substring(
        selection.extentOffset,
        selection.extentOffset + characterPadding);
  }
  
  selectedAmount = messageString.substring(
      selection.baseOffset, selection.extentOffset);
}
```

### 3.4 Concrete Example

Consider a Chase bank notification:

```
Package name: com.chase.sig.android
Notification removed: false

----

Notification Title: Chase

Notification Content: You made a $42.50 purchase at WHOLE FOODS MARKET on your card ending in 1234.
```

The user would create a template:
- **Template name:** "Chase Debit"
- **Contains:** "You made a" (or "com.chase.sig.android")
- **Amount boundaries:** before = `"made a $"`, after = `" purchas"` (8 chars before/after "$42.50")
- **Title boundaries:** before = `"hase at "`, after = `" on your"` (8 chars before/after "WHOLE FOODS MARKET")
- **Default category:** "Groceries"
- **Wallet:** "Chase Checking"

When a future notification matches, the engine:
1. Finds `"You made a"` in the message -> template matches
2. Finds `"made a $"` then extracts text until `" purchas"` -> gets "$42.50" -> strips to "42.50" -> double: 42.50
3. Finds `"hase at "` then extracts text until `" on your"` -> gets "WHOLE FOODS MARKET" -> title: "Whole foods market"

### 3.5 Template Visual Preview

The AddEmailTemplate page shows a live preview with this format:

```
Sample
[Subject text in primary color]
[amountBefore]... [Amount] ...[amountAfter]  (in secondary color)
[titleBefore]... [Title] ...[titleAfter]     (in tertiary color)
```

### 3.6 Handling Different Banks/Services

Each bank or notification source requires its own `ScannerTemplate`. The templates are stored in the database and synced across devices. Users can create unlimited templates.

**Key limitation:** The system uses `indexOf()` which finds the **first occurrence** of the boundary string. If a message contains the boundary text more than once, it will always extract from the first occurrence.

**First-match-wins:** When scanning, templates are iterated in order and the first template whose `contains` string is found in the message wins. There is no priority mechanism beyond insertion order.

---

## 4. Transaction Creation Pipeline

### 4.1 From Notification to Transaction

**File:** `lib/pages/autoTransactionsPageEmail.dart`, lines 91-158

```dart
Future queueTransactionFromMessage(String messageString,
    {bool willPushRoute = true, DateTime? dateTime}) async {
  
  // 1. Load all scanner templates from database
  List<ScannerTemplate> scannerTemplates =
      await database.getAllScannerTemplates();
  ScannerTemplate? templateFound;
  
  // 2. Find matching template and extract data
  for (ScannerTemplate scannerTemplate in scannerTemplates) {
    if (messageString.contains(scannerTemplate.contains)) {
      templateFound = scannerTemplate;
      title = getTransactionTitleFromEmail(...);
      amountDouble = getTransactionAmountFromEmail(...);
      break;
    }
  }
  
  // 3. Bail if no template matched or data missing
  if (templateFound == null) return false;
  if (amountDouble == null || title == null) return false;
  
  // 4. Category resolution -- try associated title first, then template default
  TransactionAssociatedTitleWithCategory? foundTitle =
      (await database.getSimilarAssociatedTitles(title: title, limit: 1))
          .firstOrNull;
  category = foundTitle?.category;
  if (category == null) {
    category = await database
        .getCategoryInstanceOrNull(templateFound.defaultCategoryFk);
  }
  
  // 5. Wallet resolution
  TransactionWallet? wallet = templateFound.walletFk == "-1"
      ? null
      : await database.getWalletInstanceOrNull(templateFound.walletFk);
  
  // 6. Route to AddTransactionPage (user confirmation) OR auto-create
  if (willPushRoute) {
    pushRoute(null, AddTransactionPage(
      selectedAmount: amountDouble,
      selectedTitle: title,
      selectedCategory: category,
      selectedWallet: wallet,
      selectedDate: dateTime,
      startInitialAddTransactionSequence: false,
      useCategorySelectedIncome: true,
      routesToPopAfterDelete: RoutesToPopAfterDelete.None,
    ));
  } else {
    processAddTransactionFromParams(navigatorKey.currentContext!, {
      "title": title,
      "categoryPk": category?.categoryPk,
      "walletPk": wallet?.walletPk,
      "amount": amountDouble.toString(),
      "date": dateTime.toString(),
    });
  }
}
```

### 4.2 Notification Path vs. Email Path

| Aspect | Notification | Email |
|--------|-------------|-------|
| **User confirmation** | YES -- opens AddTransactionPage | NO -- auto-creates directly |
| **Duplicate prevention** | NONE | Message ID tracking |
| **Batch processing** | One at a time (real-time) | Batch on app launch |
| **Transaction creation** | Via `pushRoute(AddTransactionPage(...))` | Via `database.createOrUpdateTransaction(insert: true, ...)` |
| **Method tracking** | Not tagged (goes through manual add flow) | Tagged as `MethodAdded.email` |
| **Date source** | Current time (default) | Email's `internalDate` |
| **Post-processing** | None | Marks email as read |

### 4.3 Category Resolution (Smart Mapping)

Both paths use the same two-tier category resolution:

1. **Associated Titles lookup** -- Cashew maintains a mapping of transaction titles to categories. When you add a transaction with title "Whole Foods" to category "Groceries", that association is saved. On future messages, `getSimilarAssociatedTitles()` performs a fuzzy match and returns the most likely category.

2. **Template default** -- If no associated title match is found, the template's `defaultCategoryFk` is used.

For emails specifically, there is also a title cleaning step:

```dart
String filterEmailTitle(string) {
  // Remove store number (everything past the last '#' symbol)
  int position = string.lastIndexOf('#');
  String title = (position != -1) ? string.substring(0, position) : string;
  title = title.trim();
  return title;
}
```

### 4.4 Transaction Amount Handling

The amount extraction strips all non-numeric characters except dots:

```dart
amountDouble = double.parse(amountString.replaceAll(RegExp('[^0-9.]'), ''));
```

For email transactions, the sign is determined by the category:

```dart
amount: (amountDouble).abs() * (selectedCategory.income ? 1 : -1)
```

If the category is tagged as "income", the amount is positive; otherwise negative.

---

## 5. Android Platform Integration

### 5.1 Manifest Permissions

```xml
<!-- Standard permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="com.android.vending.BILLING"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

<!-- Notification Listener Service (the key one for this feature) -->
<service android:label="notifications"
    android:name="notification.listener.service.NotificationListener"
    android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
    android:exported="true">
    <intent-filter>
        <action android:name="android.service.notification.NotificationListenerService"/>
    </intent-filter>
</service>
```

There is **no explicit `RECEIVE_NOTIFICATIONS` or `READ_NOTIFICATIONS` permission** -- the `BIND_NOTIFICATION_LISTENER_SERVICE` permission on the service declaration is what Android uses. The actual user-facing permission is granted through Settings > Apps > Special App Access > Notification Access.

### 5.2 Native Kotlin Code

**File:** `android/app/src/main/kotlin/com/example/budget/MainActivity.kt`

```kotlin
package com.budget.tracker_app
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity: FlutterFragmentActivity() {}
```

Minimal -- no custom native notification handling. All notification processing happens on the Dart/Flutter side. The Kotlin files are purely for widget providers (home screen widgets for transactions, net worth, etc.) and the main activity.

### 5.3 Deep Link Integration

The app registers deep links for `https://cashewapp.web.app/addTransaction` and `addTransactionRoute`. These deep links support a `messageToParse` parameter that can be used to trigger the same parsing pipeline externally:

```dart
if (params["messageToParse"] != null &&
    appStateSettings["notificationScanningDebug"] == true) {
  processMessageToParse(context, params);
}
```

This `processMessageToParse` function (in `lib/widgets/util/appLinks.dart`) inserts the message into `recentCapturedNotifications` and calls `queueTransactionFromMessage()`. This could theoretically be used by external automation tools (e.g., Tasker, IFTTT) to send messages into Cashew's parsing pipeline.

---

## 6. Feature Flags and Gating

### 6.1 Settings Map (from `lib/struct/defaultPreferences.dart`)

```dart
"notificationScanningDebug": false,  // Debug-only: shows notification transactions in settings
"notificationScanning": false,       // Enables the actual notification listener
"emailScanning": false,              // Shows email transaction option in settings
"emailScanningPullToRefresh": false, // Re-scans emails on pull-to-refresh (not just app launch)
"AutoTransactions-canReadEmails": false,  // User has opted in to email reading
"EmailAutoTransactions-amountOfEmails": 10,  // Number of recent emails to scan
"EmailAutoTransactions-emailsParsed": [],    // List of already-processed email IDs
```

### 6.2 Visibility in Settings Page

```dart
// Email scanning -- controlled by emailScanning flag
appStateSettings["emailScanning"]
    ? SettingsContainerOpenPage(openPage: AutoTransactionsPageEmail(), ...)
    : SizedBox.shrink(),

// Notification scanning -- controlled by debug flag + Android platform check
appStateSettings["notificationScanningDebug"] &&
    getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid
    ? SettingsContainerOpenPage(
        title: "Notification Transactions",
        openPage: AutoTransactionsPageNotifications(), ...)
    : SizedBox.shrink(),
```

The `notificationScanningDebug` flag is only toggleable from the **Debug Page**, with the description: "Still in testing, enables the settings option". This confirms notification transactions are an experimental/beta feature.

---

## 7. Edge Cases and Limitations

### 7.1 App Lifecycle

**Notifications only work while the app is alive.** The `notificationListenerSubscription` is a Dart stream subscription stored as a global variable. When the Flutter engine is destroyed (app killed, removed from recents), the subscription dies. There is no foreground service, no `WorkManager`, and no isolate-based background processing.

The abandoned `flutter_notification_listener` package had boot-completed receivers that could have survived reboots, but this was not carried forward.

### 7.2 No SMS Parsing

There is **zero SMS parsing code** in the codebase. The only SMS-related reference is the Android manifest's query intent for `smsto://` (which is for sending SMS, not reading). There is no `READ_SMS` permission, no telephony package, and no SMS content provider access.

### 7.3 Parsing Fragility

The string-boundary approach has inherent fragility:

1. **Position sensitivity** -- `indexOf()` finds the first occurrence. If the boundary text appears earlier in the message than expected, parsing breaks
2. **Fixed context window** -- The 8-character padding is hardcoded. If the surrounding text of the amount/title is shorter than 8 characters, it still works (bounds checking exists), but there's no way to increase precision
3. **No multi-amount handling** -- If a message contains multiple dollar amounts (e.g., "You spent $42.50 on your card with a remaining balance of $1,234.56"), the boundary strings must be precise enough to isolate the correct one
4. **No currency handling** -- The amount parser strips everything except digits and dots: `RegExp('[^0-9.]')`. Commas in amounts (e.g., "$1,234.50") are stripped, but locale-specific decimal commas are not handled in the extraction (only in `getAmountFromString()`)
5. **Silent failures** -- Both extraction functions have bare `catch (e) {}` blocks that silently swallow all errors and return null

### 7.4 No Notification App Filtering

Unlike other finance apps that allow users to specify which apps' notifications to monitor, Cashew processes **all** notifications. The only filtering is whether the notification text contains the template's `contains` string. This means:

- High-volume notification apps could cause unnecessary processing
- A template with a generic `contains` string could accidentally match non-financial notifications
- There is no blocklist/allowlist for notification sources

### 7.5 No Transaction Confirmation for Emails

Email transactions are **auto-created without user confirmation**. They are batch-inserted after all emails are processed:

```dart
for (Transaction transaction in transactionsToAdd) {
  await database.createOrUpdateTransaction(insert: true, transaction);
}
```

Notification transactions, by contrast, open the AddTransactionPage for user review.

### 7.6 Template Syncing

Scanner templates are included in Cashew's cloud sync system (`lib/struct/syncClient.dart`). Templates created on one device will sync to others, maintaining consistency across a user's devices.

---

## 8. Architecture Summary

```
┌──────────────────────────────────────────────────────────────┐
│                    DATA SOURCES                               │
│                                                               │
│  ┌─────────────────────┐    ┌─────────────────────────────┐  │
│  │  Android Notification │    │  Gmail API                   │  │
│  │  Listener Service     │    │  (OAuth + gmailReadonly +    │  │
│  │  (notification_       │    │   gmailModify scopes)        │  │
│  │  listener_service)    │    │                               │  │
│  └──────────┬────────────┘    └──────────────┬────────────────┘  │
│             │                                │                   │
│  getNotificationMessage()         getEmailMessage()              │
│  (packageName + title +           (base64 decode + HTML          │
│   content -> flat string)          parse -> flat string)         │
│             │                                │                   │
└─────────────┼────────────────────────────────┼───────────────────┘
              │                                │
              ▼                                ▼
┌──────────────────────────────────────────────────────────────────┐
│                    UNIFIED PARSING ENGINE                         │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │  ScannerTemplate (from database)                             │ │
│  │  - contains: "Chase" (match string)                          │ │
│  │  - amountTransactionBefore: "made a $" (left boundary)       │ │
│  │  - amountTransactionAfter: " purchas"  (right boundary)      │ │
│  │  - titleTransactionBefore: "hase at "  (left boundary)       │ │
│  │  - titleTransactionAfter: " on your"   (right boundary)      │ │
│  │  - defaultCategoryFk -> "Groceries"                          │ │
│  │  - walletFk -> "Chase Checking"                              │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  1. messageString.contains(template.contains) -> match           │
│  2. indexOf(before) + before.length -> startIndex                │
│  3. indexOf(after, startIndex) -> endIndex                       │
│  4. substring(startIndex, endIndex) -> raw extracted text         │
│  5. Amount: strip non-numeric -> double.parse                    │
│  6. Title: strip newlines, lowercase, capitalizeFirst            │
│                                                                   │
└──────────────────────────┬────────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│                    CATEGORY RESOLUTION                            │
│                                                                   │
│  1. getSimilarAssociatedTitles(extractedTitle) -> fuzzy match    │
│     (uses title<->category mapping built from past transactions) │
│  2. If no match -> use template.defaultCategoryFk                │
│                                                                   │
└──────────────────────────┬────────────────────────────────────────┘
                           │
              ┌────────────┼────────────────┐
              │            │                │
              ▼            │                ▼
┌──────────────────────┐   │   ┌──────────────────────────────┐
│  NOTIFICATION PATH   │   │   │  EMAIL PATH                   │
│                      │   │   │                                │
│  Opens               │   │   │  Auto-creates Transaction:    │
│  AddTransactionPage  │   │   │  - methodAdded: email          │
│  with pre-filled     │   │   │  - date: email internalDate    │
│  fields for user     │   │   │  - paid: true                  │
│  review/confirmation │   │   │  - Marks email as read         │
│                      │   │   │  - Shows snackbar notification │
│  User must tap Save  │   │   │                                │
│                      │   │   │  Batch inserts after scan      │
└──────────────────────┘   │   └──────────────────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  APP LINK PATH  │
                  │  (messageToParse│
                  │   parameter)    │
                  │                 │
                  │  Same as        │
                  │  notification   │
                  │  path           │
                  └─────────────────┘
```

---

## 9. Key Takeaways for Variance

### What Cashew Does Well
1. **Unified parsing engine** -- Same `ScannerTemplate` system works for both notifications and emails
2. **User-driven template creation** -- The "select text from sample" wizard is intuitive and avoids the complexity of regex
3. **Smart category mapping** -- Two-tier resolution (associated titles + template default) gets smarter over time
4. **Email dedup** -- Simple but effective message ID tracking prevents duplicate transactions

### What Cashew Does Poorly
1. **No background processing** -- Notification listener dies when app is killed. For a finance app, this is a critical gap
2. **Silent parsing failures** -- Empty catch blocks swallow errors, giving no feedback about why a notification didn't parse
3. **No notification source filtering** -- All notifications are processed, no package name allowlist
4. **Fixed boundary padding** -- 8 characters is arbitrary and not configurable
5. **No regex/pattern support** -- The string boundary approach fails when the surrounding text varies (e.g., different transaction types from the same bank)
6. **No amount sign detection** -- Cannot distinguish debits from credits by looking at the notification text; relies entirely on the category's income flag
7. **Feature still in beta** -- Notification transactions are behind a debug flag, suggesting the developers themselves don't consider it production-ready
8. **No SMS support** -- Many banks in Asia/India use SMS for transaction alerts, which Cashew completely ignores

### Opportunities for Variance
1. **Background notification processing** -- Use a foreground service or WorkManager to process notifications even when the app is killed
2. **Regex templates** -- Allow power users to define regex patterns with named capture groups for more flexible parsing
3. **ML-assisted parsing** -- Use lightweight on-device NLP to extract amounts and merchant names without manual template setup
4. **SMS channel** -- Critical for Indian/Asian markets where SMS transaction alerts are standard
5. **Template marketplace** -- Allow community sharing of templates for common banks
6. **Notification source management** -- Let users select which apps to monitor, with per-app template associations
7. **Debit/credit detection from text** -- Parse keywords like "debited", "credited", "received", "spent" to determine transaction direction
8. **Confidence scoring** -- Show the user a confidence score for each parsed field, flagging uncertain extractions for review
