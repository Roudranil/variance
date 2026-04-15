---
title: "Patterns Worth Stealing (With Modifications)"
status: draft
owner: lead-engineer
date: 2026-04-15
depends_on:
  - docs/enemy-recon/01-architecture-data-model.md
  - docs/enemy-recon/02-ui-ux-animation.md
  - docs/enemy-recon/03-state-management-performance.md
  - docs/enemy-recon/04-feature-engineering.md
  - docs/enemy-recon/08-emoji-icons-and-exchange-rates.md
---

# Section 4: Patterns Worth Stealing (With Modifications)

Eight patterns from Cashew that solve real problems and are worth adopting in Variance -- each with explicit modifications to fit our architecture. Two bonus findings (exchange rate API and icon library) are noted at the end.

Sources: Reports 01, 02, 03, 04, and 08.

---

## Pattern 1: Drift Reactive Streams (`.watch()` for Real-Time UI Updates)

### What Cashew Does

Every data query in Cashew returns a `Stream<T>` via Drift's `.watch()` method. When a row in SQLite changes, Drift automatically re-emits the query result. Widgets consume these streams via `StreamBuilder`, so the UI always reflects the current database state without manual refresh calls.

Cashew also returns both a stream and a future from some methods:

```dart
(Stream<List<Transaction>>, Future<List<Transaction>>) getAllSubscriptions() {
  final query = select(transactions)...;
  return (query.watch(), query.get());
}
```

This gives callers the choice between reactive and one-shot access.

### What Is Good About It

- Zero manual synchronization between DB writes and UI reads. Write to the DB; every widget watching that table updates automatically.
- Drift handles the invalidation logic internally -- it knows which tables a query touches and re-fires when those tables change.
- Eliminates an entire class of stale-data bugs.
- The stream-first approach composes well with Flutter's `StreamBuilder` and with state management layers.

### What to Keep

- **Drift as our SQLite ORM.** This is already aligned with our tech stack decisions. Drift's reactive query system is its killer feature for local-first apps.
- **Stream-first query API.** Every repository method that the UI consumes should return `Stream<T>`. One-shot `Future<T>` methods are for background tasks, migrations, and bulk operations only.
- **Database as the single source of truth.** UI state derives from DB state, not the other way around.

### What to Change

- **No global `late` database variable.** Cashew stores the Drift database as a module-level `late FinanceDatabase database`. We use dependency injection. The database instance is provided through the DI container (likely `get_it` or Riverpod's provider tree) and injected into repositories. This makes testing trivial -- swap in an in-memory Drift database for tests.
- **Repositories consume Drift streams, UI consumes BLoC/Cubit state.** Cashew pipes `StreamBuilder` directly into widgets. We insert a state management layer between the database and the UI. Repositories expose `Stream<T>`, Cubits/BLoCs subscribe to those streams and emit typed state objects (sealed classes: Loading, Success, Failure). Widgets consume Cubit state via `BlocBuilder`, never raw database streams.
- **No `StreamZip` for multi-wallet aggregation.** Cashew merges N per-wallet streams with `StreamZip` to compute multi-currency totals. Our DEB model with per-currency EQ entries means we can compute multi-currency balances with a single query that joins entries with their exchange rates. One stream, not N.

---

## Pattern 2: ListenableSelector (Targeted Widget Rebuilds)

### What Cashew Does

Cashew has a custom `ListenableSelector` extension that converts a `Listenable` into a `ValueListenable<Value>` with a selector function and an optional equality filter:

```dart
extension ListenableSelectorExtension<Controller extends Listenable> on Controller {
  ValueListenable<Value> select<Value>(
    ListenableSelector<Controller, Value> selector, [
    ListenableFilter<Value>? test,
  ]) => _ValueListenableView<Controller, Value>(this, selector, test);
}
```

The internal `_ValueListenableView` lazily subscribes to the source, compares previous and next selected values using `identical()` and the optional filter, and only notifies downstream listeners when the selected value actually changed.

### What Is Good About It

- Prevents cascading rebuilds. If a parent `Listenable` has 10 properties, a widget that only cares about property 3 does not rebuild when properties 1-2 or 4-10 change.
- The lazy subscription model means no overhead until a widget actually mounts.
- It is a general-purpose optimization that works with any `Listenable`, not tied to a specific state management framework.

### What to Keep

- **The concept of selective listening.** Widgets should only rebuild when the specific slice of state they depend on changes. This is a non-negotiable performance principle for Variance.

### What to Change

- **Use Riverpod's `select()` or BLoC's `buildWhen`/`listenWhen` instead of a custom implementation.** The concept is sound, but we do not need to hand-roll it. Both Riverpod and BLoC have built-in selector mechanisms that achieve the same result with framework integration:
  - **BLoC route:** `BlocBuilder<MyCubit, MyState>(buildWhen: (prev, curr) => prev.amount != curr.amount, builder: ...)`
  - **Riverpod route:** `ref.watch(myProvider.select((s) => s.amount))`
- **Immutable state classes make selectors reliable.** Cashew's `ListenableSelector` uses `identical()` comparison, which only works with immutable objects. Our sealed state classes (via `freezed` or manual sealed hierarchies) guarantee this. Cashew's mutable `Map<String, dynamic>` for settings would break the selector -- a mutation does not change identity. We avoid this problem by design.
- **No `GlobalKey`-based refresh.** Cashew uses `ListenableSelector` in a few places but falls back to `GlobalKey.currentState?.refreshState()` for most UI updates. We eliminate imperative refresh entirely. Every UI update flows through the state management layer.

---

## Pattern 3: Currency Conversion via Base Currency Intermediary (USD Pivot)

### What Cashew Does

All exchange rates are fetched relative to USD from the fawazahmed0 API. Rates are cached as a flat map: `{"eur": 0.912, "inr": 83.12, ...}`. To convert from currency A to currency B, Cashew goes through USD as the intermediary:

```
rate = (USD_to_B) * (1 / USD_to_A)
```

For multi-currency totals, the system iterates over every wallet, sums transactions per wallet in native currency, then multiplies each sum by the conversion ratio to the primary (display) currency. These per-wallet results are merged via `StreamZip`.

Custom/manual exchange rates are supported per currency, always stored as USD-relative to avoid chain-dependency issues when API rates update.

### What Is Good About It

- The USD intermediary means you only need N rates (one per currency relative to USD) rather than N^2 rates (every pair). With 537 currencies in the dataset, that is 537 values instead of ~288,000.
- The math is correct and simple. Two multiplications per conversion.
- Custom rates being USD-relative is a smart design decision -- it prevents custom overrides from drifting when the API rate for the primary currency changes.
- Fallback to cached rates on network failure provides offline resilience.

### What to Keep

- **The intermediary currency concept.** One base currency, N rates, two multiplications. This is the standard approach and it works.
- **The fawazahmed0 API itself** is worth evaluating seriously (see Bonus Finding 1 below). Free, no API key, CDN-served.
- **Custom rate overrides.** Users with exotic currencies or crypto need to manually set rates.
- **Offline-first caching.** Rates must survive app restarts and network outages.

### What to Change

- **Home currency as the base, not USD.** Cashew stores all rates as USD-relative because it was simpler for the developer. We store rates as home-currency-relative. The user's home currency (set during onboarding, INR fallback per PRD) is the base. This eliminates one multiplication for the most common conversion (foreign -> home). It also makes the rate column on transactions (`exchange_rate_to_home`) directly usable without an additional USD lookup.
- **Per-transaction rate capture, not per-display-moment.** Cashew converts at display time using the latest cached rate. We lock the exchange rate at transaction creation time (per PRD decision: `exchange_rate_to_home` stored on each transaction). Historical totals use historical rates. Net worth uses current rates (explicitly documented).
- **No per-wallet loop.** Cashew runs N queries (one per wallet) and merges streams. Our DEB ledger entries each carry the transaction's exchange rate. Category and account balances can be computed in a single query: `SUM(entry_amount * exchange_rate_to_home)` for cross-currency aggregation. This is both simpler and more performant.
- **Structured rate storage, not SharedPreferences.** Cashew dumps the entire rate map into `appStateSettings` (a `Map<String, dynamic>` in SharedPreferences). We store exchange rates in a dedicated Drift table with columns for currency code, rate, fetched_at timestamp, and source (api/manual). This supports TTL checks, staleness warnings, and audit of when rates were last refreshed.
- **Rounding discipline.** Cashew does two floating-point multiplications per conversion with no rounding strategy. We define a rounding policy: rates stored to 6 decimal places, converted amounts rounded to the target currency's decimal precision (2 for most fiat, up to 8 for crypto).

---

## Pattern 4: Deterministic Key Generation for Sync Dedup

### What Cashew Does

When a recurring transaction is paid and the next instance is spawned, Cashew generates the new transaction's primary key deterministically from the original key:

```dart
String updatePredictableKey(String originalKey) {
  // "abc" -> "abc::predict::1" -> "abc::predict::2" -> ...
}
```

If the original key is `"tx-uuid-123"`, the first spawned instance gets `"tx-uuid-123::predict::1"`, the second gets `"tx-uuid-123::predict::2"`, and so on. This means that if two devices both auto-pay the same subscription offline, they generate the same key for the next instance. When the devices sync, the duplicate is detected by primary key collision and resolved via last-writer-wins -- instead of creating two separate next-instances.

### What Is Good About It

- Solves a genuinely hard problem. Concurrent materialization of recurring transactions across devices is a classic sync conflict scenario. Deterministic keys turn a conflict-resolution problem into an idempotency problem.
- The implementation is trivial -- string concatenation with a counter suffix.
- It composes cleanly with last-writer-wins sync: same key means same logical entity, so the merge is automatic.

### What to Keep

- **The principle of deterministic key generation for system-generated entities.** Any time the system creates an entity automatically (recurring transaction instances, balance adjustment entries, EQ entries), the key should be derivable from the inputs, not randomly generated.

### What to Change

- **UUIDs stay random for user-created entities.** Only system-generated entities (recurring instances, reversal entries, correction entries) use deterministic keys. User-created transactions use UUID v4.
- **Use a proper deterministic function, not string concatenation.** The `::predict::N` suffix is fragile -- it encodes ordering assumptions and does not handle branching (what if a device skips an instance?). We use UUID v5 (namespace + name-based): `uuidV5(recurringTemplateId, instanceDateISO)`. The template ID is the namespace, the occurrence date is the name. This is deterministic, collision-resistant, and does not encode a sequential counter.
- **Broader application to DEB correction pairs.** When the system creates a reversal+correction pair for an edit, the reversal entry's key should be deterministic from the original transaction ID. This prevents duplicate reversals if the edit is retried.
- **Compound group IDs.** For compound transactions (transfer-with-fee), the `compound_group_id` should also be deterministic from its constituent transaction IDs, not a fresh UUID. This supports idempotent creation of compound groups.

---

## Pattern 5: Animation Curves -- easeInOutCubicEmphasized Everywhere

### What Cashew Does

Cashew uses a deliberate animation curve hierarchy across the entire app:

1. **`Curves.easeInOutCubicEmphasized`** is the dominant curve. It is used for sidebar expand/collapse (1500ms), tab indicators, FAB show/hide (500ms), `AnimatedSize` (800ms), and scroll-to-top (1200ms). This is the Material 3 recommended motion curve -- slow start, aggressive acceleration, satisfying deceleration.

2. **`ElasticOutCurve(0.5-0.6)`** is used for delight moments: pie chart segment animations (1300ms), scale-in pop effects (1500ms), category badge pop-ins. The elastic overshoot-and-settle gives interactive elements a physical, springy feel.

3. **Short durations for interactions, long durations for reveals.** Tap feedback is 150-230ms (via `FadedButton`). Content reveals are 500-1500ms. The app responds instantly to touch but takes its time for visual storytelling.

### What Is Good About It

- Consistent motion language. Every transition in the app feels like it belongs. The same curve family is used everywhere, creating a cohesive personality.
- The three-tier timing (instant touch feedback / medium interaction / slow reveal) is perceptually correct. Users experience responsiveness (no lag on tap) and polish (smooth content transitions) simultaneously.
- `easeInOutCubicEmphasized` genuinely looks better than generic `easeInOut` -- the aggressive mid-section and gentle settle give transitions a sense of momentum.

### What to Keep

- **`easeInOutCubicEmphasized` as our default motion curve.** This is the Material 3 standard and it works. No reason to deviate.
- **The timing hierarchy.** Touch feedback: 100-200ms. Interactive state changes (toggle, expand, tab switch): 300-500ms. Content reveals and page transitions: 500-1000ms. No animation over 1500ms.
- **Elastic curves for delight-only moments.** Reserve `ElasticOutCurve` for non-critical celebratory animations -- goal reached, balance milestone, onboarding illustrations. Never use elastic on functional interactions (it delays the settled state).

### What to Change

- **Codify the motion constants.** Cashew hard-codes duration and curve values at every call site. We define a `VarianceMotion` constants class:
  - `VarianceMotion.defaultCurve` = `easeInOutCubicEmphasized`
  - `VarianceMotion.tapDuration` = 150ms
  - `VarianceMotion.interactionDuration` = 400ms
  - `VarianceMotion.revealDuration` = 700ms
  - `VarianceMotion.delightCurve` = `ElasticOutCurve(0.5)`
  - `VarianceMotion.delightDuration` = 1200ms
- **No animations over 1000ms in functional UI.** Cashew's 1500ms sidebar animation and 2500ms circular progress animation are too slow for daily-use interactions. Cap functional animations at 1000ms; only decorative/celebratory animations may exceed.
- **Android only simplifies platform branching.** Cashew has separate animation paths for iOS (opacity-based tap) and Android (ripple/InkSplash). We target Android only (per PRD), so we standardize on Material ripple everywhere.

---

## Pattern 6: PageFramework / PopupFramework Scaffolding

### What Cashew Does

Cashew has two universal layout widgets that enforce consistent page structure:

**PageFramework** (1,336 lines) wraps every page. It provides:
- A `CustomScrollView` with a `SliverAppBar` that collapses as the user scrolls.
- A large title that scales by up to 1.15x when the header is expanded, settling to normal size on scroll.
- A back button that fades from ghosted (50% opacity) to full opacity as the header collapses.
- Drag-to-dismiss gesture support (vertical threshold: 125px, horizontal swipe from left edge: 90px).
- Adaptive header height based on screen size (110-200px on Android, scaled linearly between 700-855px screen heights).
- Content injection via `slivers` (raw slivers) or `listWidgets` (auto-wrapped in `SliverList`).

**PopupFramework** wraps every bottom sheet. It provides:
- A title (left-aligned on Android), optional subtitle, optional icon.
- 18px horizontal padding, safe area bottom padding.
- A close button on full-screen layouts.

### What Is Good About It

- Every page and popup in the app looks and feels consistent without developers thinking about it. The framework handles scroll behavior, header collapse, safe areas, padding, and gesture dismissal.
- New pages are trivially created: pass a title, pass content widgets, done. The structural boilerplate is zero.
- Adaptive header sizing means the design works across phone sizes without manual breakpoints per page.

### What to Keep

- **A single base page scaffold for all pages.** Every Variance page should extend (or compose) a common page widget that handles: app bar behavior, scroll view setup, safe area padding, content width constraints, and consistent spacing.
- **A single base popup scaffold for all bottom sheets.** Title, padding, close affordance, max width -- standardized.
- **Adaptive sizing based on screen dimensions.** Dynamic header heights, constrained content widths on larger screens.

### What to Change

- **Decompose the monolith.** Cashew's `PageFramework` is 1,336 lines because it handles too many concerns: scroll tracking, animation controllers, drag-to-dismiss, header rendering, fab positioning, responsive layout. We separate these into composable pieces:
  - `VarianceScaffold` -- handles safe areas, app bar slot, content slot, optional FAB slot.
  - `CollapsibleHeader` -- the scroll-aware animated header, usable within the scaffold.
  - `DismissiblePage` -- optional mixin or wrapper for drag-to-dismiss behavior.
  - `VarianceBottomSheet` -- the popup scaffold, kept deliberately small.
- **No platform branching in the scaffold.** Cashew's `PageFramework` checks `PlatformOS.isIOS` in 10+ places for header height, title alignment, and gesture behavior. We target Android only. One code path.
- **Width constraints from a theme/responsive utility.** Cashew computes constrained widths via `getHorizontalPaddingConstrained()` -- a function with complex branching. We define responsive breakpoints in a centralized utility and reference them from the scaffold, not inline.
- **Content injection via slots, not parameter overloading.** Cashew's `PageFramework` has dozens of optional parameters for every customization. We use a slot-based API (named child parameters) that is explicit about what goes where.

---

## Pattern 7: Composable Filter Expressions

### What Cashew Does

Cashew's most well-designed subsystem is its composable filter expression architecture (lines 5773-6456 of `tables.dart`). Every list and aggregation query accepts filter parameters and composes them into a single Drift `Expression<bool>`:

| Function | Purpose |
|---|---|
| `onlyShowIfFollowsSearchFilters()` | Master filter accepting a `SearchFilters` object (income/expense, paid/unpaid, date range, amount range, title/note search, transaction types, wallet/category/budget/objective PKs) |
| `onlyShowTransactionBasedOnSearchQuery()` | Full-text-like search across transaction name, note, category name, subcategory name, amount, and parsed date text |
| `onlyShowIfFollowsFilters()` | Budget-specific filters (shared, added, income, debt/credit, objectives, balance corrections) |
| `onlyShowBasedOnTimeRange()` | Date range filtering with special handling for custom budget periods |
| `isInCategory()` | Category include/exclude list filtering |
| `onlyShowBasedOnWalletFks()` | Wallet-level filtering |

These are pure expression builders. Each returns an `Expression<bool>` that composes with others via `&` (AND) and `|` (OR). Any query can apply any combination of filters by chaining these builders.

### What Is Good About It

- Clean separation of filter logic from query logic. The filters do not know what query they are part of.
- High reusability. The same `onlyShowIfFollowsSearchFilters()` is used by the transactions list, budget calculations, category totals, and export.
- Type-safe at the Drift level -- `Expression<bool>` compiles to valid SQL WHERE clauses.
- Incrementally composable. Adding a new filter dimension requires writing one new builder function, not modifying every existing query.

### What to Keep

- **Pure expression builders as the filter pattern.** Every filter dimension is an independent function that returns `Expression<bool>`. Queries compose them freely.
- **A `SearchFilters` data class as the transport object.** A single typed class carries all active filters, serializable for persistence.
- **Reuse across all query contexts.** Transaction lists, category totals, budget progress, net worth -- all share the same filter infrastructure.

### What to Change

- **Extract filters out of the database class.** Cashew defines all filter functions inside the 7,667-line `FinanceDatabase` class. We define filter builders in a separate `filters/` directory, organized by domain:
  - `filters/transaction_filters.dart` -- date range, amount range, search query, status, purpose
  - `filters/account_filters.dart` -- account PKs, account type
  - `filters/category_filters.dart` -- category PKs, include/exclude
  - `filters/entry_filters.dart` -- debit/credit side, currency
- **DEB-aware filters.** Cashew filters on transactions only. Our filter expressions operate on both transactions and ledger entries. For example, "show all expenses over 5000" filters on transactions, but "show all debits to account X" filters on entries. The expression builders must work with both Drift table types.
- **No JSON-in-columns.** Cashew stores category PK lists and budget filter flags as JSON strings in text columns, then uses `String.contains()` checks in Dart (not SQL) to apply them. We use proper junction tables for many-to-many relationships (e.g., budget-to-category inclusions). This keeps filtering entirely in SQL.
- **Immutable filter state.** Cashew mutates filter parameters in place. Our `SearchFilters` class is immutable (via `freezed` or manual `copyWith`). Filter changes produce new instances; the Cubit compares old and new and re-queries only if filters actually changed.
- **FTS for search.** Cashew uses `LIKE '%query%'` for text search -- no indexes, no stemming, case-insensitive via collation. If search performance matters at scale (10k+ transactions), we evaluate SQLite FTS5 as a dedicated search index. For v1, `LIKE` is acceptable with proper column indexes.

---

## Pattern 8: Three-Tier Animation Opt-Out System

### What Cashew Does

Cashew implements three levels of animation fidelity that users can choose between:

1. **Full animations** (default). All transitions, elastic curves, pie chart reveals, breathing widgets, and shadows are active.

2. **Reduced animations.** Controlled by `appStateSettings["appAnimations"]` (an `AppAnimations` enum). When not set to `all`, animation durations become `Duration.zero` and some widgets skip their animation entirely. The layout and content remain identical; only motion is removed.

3. **Battery saver mode.** `appStateSettings["batterySaver"]` disables box shadows (via `boxShadowCheck()` returning `null`) and all decorative animations. Animation widgets check this flag and return their child directly without wrapping in animation controllers.

Every animation widget in the app has a bailout path:

```dart
// Typical pattern in animation widgets:
if (appStateSettings["batterySaver"]) return child; // skip animation entirely
```

### What Is Good About It

- Accessibility-conscious. Users with motion sensitivity can reduce or eliminate animations without losing functionality.
- Battery-aware. Shadow rendering and continuous animations (breathing, rotation) are the most GPU-intensive elements and are the first to go.
- Graceful degradation. The app works identically at all three tiers -- only the visual polish changes.
- Every animation widget is independently responsible for its bailout check, so the system works without a central coordinator.

### What to Keep

- **The three-tier concept.** Full / reduced / minimal is the right granularity. Material 3 respects `MediaQuery.disableAnimations`, and Android exposes "Remove animations" in developer options. We should honor both system settings and an in-app override.
- **Per-widget bailout checks.** Each animation widget decides its own degradation behavior. A `CountNumber` widget can fall back to showing the final value instantly. An `AnimatedExpanded` can snap to its final size.
- **Shadow removal in battery saver.** Box shadows are expensive and purely cosmetic.

### What to Change

- **System integration, not just a settings flag.** Cashew only checks its own `appStateSettings["batterySaver"]` flag. We integrate with Android's `MediaQuery.platformBrightness`, `MediaQuery.disableAnimations`, and battery-saver API (`Battery` package or platform channel). When the OS is in battery saver mode, we automatically switch to reduced animations. Users can override in either direction.
- **A centralized `MotionConfig` via InheritedWidget or Riverpod provider.** Cashew checks `appStateSettings` (a global mutable map) in every animation widget. We provide the animation tier via `MotionConfig.of(context)` or a Riverpod provider, making it testable and mockable. Widget tests can set `MotionConfig.tier = AnimationTier.none` to skip all animation logic during test runs.
- **Respect `AccessibilityFeatures.reduceMotion`.** Flutter provides `MediaQueryData.accessibleNavigation` and `MediaQueryData.disableAnimations`. We check these in addition to our custom setting. If the OS says reduce motion, we reduce motion -- even if the user has not toggled our in-app setting.
- **No global mutable state.** Cashew reads `appStateSettings["batterySaver"]` directly in widget `build()` methods. We read from the DI-provided config. State changes propagate reactively through the widget tree, not via imperative refresh.

---

## Bonus Finding 1: Exchange Rate API (fawazahmed0 via jsDelivr)

Cashew uses the [fawazahmed0/exchange-api](https://github.com/fawazahmed0/exchange-api), served via jsDelivr CDN:

```
https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json
```

Key characteristics:
- **Free, no API key required.** No registration, no rate limits documented.
- **CDN-served** via jsDelivr (global edge caching, high availability).
- **537 currencies** including fiat and crypto (BTC, ETH, ADA, DOGE, etc.).
- **Updated daily.** Only latest rates; no historical endpoint used by Cashew.
- **Response format:** `{"date": "2024-01-15", "usd": {"eur": 0.912, "inr": 83.12, ...}}`

**Evaluation for Variance:**
- **Pros:** Zero cost, zero auth complexity, supports crypto, CDN reliability.
- **Cons:** No SLA, no guaranteed uptime, no historical rates API, no rate-limit documentation, single maintainer open-source project.
- **Recommendation:** Use as the primary source for v1. Cache aggressively in a Drift table. If the API goes down or is deprecated, the cached rates continue to work, and we can swap to another provider (exchangerate.host, Open Exchange Rates) by changing one URL. The abstraction cost of a pluggable rate provider is near zero.

---

## Bonus Finding 2: Category Icon Library (277 Curated PNGs with Search Tags)

Cashew does NOT convert emojis to icons. It provides two completely independent paths:

1. **277 curated PNG illustrations** (`assets/categories/`), each with ~10 search tags and a suggested category name. The icons are flat-design, colored PNGs (Flaticon/Freepik style). Users search by tag in a grid picker. Selecting an icon auto-suggests a category name (e.g., `apple.png` suggests "Food").

2. **Raw emoji input.** Users type an emoji from their keyboard. The emoji is stored as a Unicode string and rendered as text using the device's native emoji font. No conversion, no custom rendering.

These two paths are mutually exclusive on a category: setting one clears the other.

**Evaluation for Variance:**
- **We chose `material_symbols_icons` package** (per PRD decision: curated subset bundled). This gives us vector SVG icons that scale cleanly, support tinting/theming, and do not require 277 PNG assets in the bundle.
- **The tag-based search UX is worth stealing.** Cashew's icon picker is effective because each icon has ~10 semantic tags. We should build a similar search-tagged metadata structure for our Material Symbols subset.
- **Emoji as a secondary path is low-cost UX value.** Even though we use Material Symbols as the primary icon set, allowing emoji input as an alternative costs almost nothing to implement (one text field, one regex filter, store as a string). Consider as a v1 or v2 addition.
- **The auto-name suggestion pattern** (selecting an icon pre-fills the category name) is a nice UX touch that reduces friction during category creation.
