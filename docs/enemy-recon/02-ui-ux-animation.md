# Cashew UI/UX & Animation Intelligence Report

**Target:** Cashew (open-source Flutter personal expense tracker)
**Codebase:** `/Cashew/budget/`
**Date:** 2026-04-15
**Scope:** UI/UX layer, animation system, visual design, layout architecture

---

## 1. Page Framework & Layout System

### 1.1 PageFramework: The Universal Page Scaffold

Every page in Cashew is built on a single widget: `PageFramework` (1,336 lines). It is the app's only page template. Any screen -- budgets, transactions, settings -- is a `PageFramework` with different parameters.

**What the user sees:** A page with a large title that collapses as you scroll, an optional subtitle region, a back button that fades in, and optionally a floating action button at the bottom-right. On iOS, the title centers and shrinks to a compact header; on Android, it uses an expanded collapsing header with parallax subtitle animation.

**How it works technically:**

- Built on `CustomScrollView` with a `SliverAppBar` (`PageFrameworkSliverAppBar`).
- Three animation controllers drive the header experience:
  - `_animationControllerShift` -- tracks scroll position as a 0-to-1 ratio of the expanded header height. Controls title scaling and positioning.
  - `_animationControllerOpacity` -- fades the back button from 0.5 (when expanded) to 1.0 (when collapsed). Starting at 0.5 gives the button a ghosted appearance when the title is large.
  - `_animationControllerDragY` -- handles the drag-to-dismiss gesture, translating the entire scaffold downward.
- Content is injected as either `slivers` (raw sliver widgets) or `listWidgets` (regular widgets wrapped in a `SliverList`). The `sliversBefore` flag controls ordering.
- Horizontal padding is computed dynamically for constrained layouts via `getHorizontalPaddingConstrained()`.

**Key design decisions:**
- **Platform-adaptive headers.** On iOS (`PlatformOS.isIOS`), the expanded header height is 100px max. On Android, it ranges from 110px to 200px, scaling linearly between screen heights of 700-855px. This means smaller phones get compact headers automatically.
- **Title scaling on scroll.** The title scales by `percent * 0.15 + 1` (so up to 1.15x at full expansion). This is subtle -- just enough to feel "alive" without being distracting.
- **Drag-to-dismiss.** Pages that can be dismissed (modal-like pages) register pointer listeners for both vertical drag (threshold: 125px) and horizontal back-swipe from the left edge (threshold: 90px, detection zone: 30px from left). Haptic feedback fires exactly when the user crosses the threshold.

```dart
// Header height calculation -- adaptive to screen size
double getExpandedHeaderHeight(BuildContext context, double? expandedHeightPassed, {bool? isHomePageSpace}) {
  double height = MediaQuery.sizeOf(context).height;
  double minHeaderHeight = getPlatform() == PlatformOS.isIOS ? 100 : 110;
  double maxHeaderHeight = getPlatform() == PlatformOS.isIOS ? 100 : 200;
  if (height >= 855) return maxHeaderHeight;
  if (height <= 700) return minHeaderHeight;
  double heightPercentage = (height - 700) / (855 - 700);
  return minHeaderHeight + heightPercentage * (maxHeaderHeight - minHeaderHeight);
}
```

### 1.2 PopupFramework: Bottom Sheet Content Template

Bottom sheets use `PopupFramework` -- a simpler layout widget that provides:
- A title (centered on iOS, left-aligned and larger on Android)
- An optional subtitle
- An optional icon in the top-left (iOS) or top-right (Android)
- A close button (shown only on full-screen layouts)
- Content with 18px horizontal padding
- Safe area bottom padding that calculates a minimum of 10px

**Platform split:** On iOS, the title is centered with a horizontal divider underneath. On Android, it is left-aligned, larger (up to 29px for short titles, 23px for long ones), with no divider.

### 1.3 Responsive Layout: FullPageDoubleColumnLayout

For wide screens, `FullPageDoubleColumnLayout` splits the content into a fixed-height banner header and two side-by-side columns below it:

```dart
Row(
  children: [
    Flexible(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 700), child: leftWidget)),
    Flexible(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 700), child: rightWidget)),
  ],
)
```

The max column width is 700px, and the entire layout is capped at 1600px. This is used on tablet/desktop views.

### 1.4 Content Width Constraints

`getHorizontalPaddingConstrained()` computes extra horizontal padding so content does not stretch edge-to-edge on wider screens. Logic:
- Below 550px: no extra padding (phone layout)
- 550-1000px without sidebar: `width/3 - 140` (gradually centers content)
- 1000px+ with sidebar expanded: `(width - 500) / 3`
- The bottom sheet max width is always 650px via `getWidthBottomSheet()`

---

## 2. Navigation Architecture

### 2.1 Navigation Framework (Main Shell)

`PageNavigationFramework` is the root shell widget. It manages navigation state with a `FadeIndexedStack` (a `LazyIndexedStack` wrapped in a `FadeTransition`).

**Architecture:**
- 4 primary pages (Home, Transactions, Budgets, More) are in `pages[]`
- 14 extended pages (Subscriptions, Notifications, All Spending, Accounts, Edit pages, Goals, etc.) are in `pagesExtended[]`
- All pages are mounted into a single indexed stack. Tab switching changes the visible index -- pages are never destroyed/recreated.
- `LazyIndexedStack` (from the `flutter_lazy_indexed_stack` package) delays building a page until it is first selected, avoiding the cost of building all 18 pages upfront.

**Tab switching:** `changePage(int page)` sets state with `currentPage` and `previousPage`. Haptic feedback on tab switch is optional (`tabNavigationHapticFeedback` setting).

### 2.2 Bottom Navigation Bar

The bottom nav bar (`BottomNavBar`) is entirely platform-adaptive:

**iOS version:**
- Custom implementation using `Row` of `NavBarSpaceButton` widgets (not Material `NavigationBar`)
- Each icon is a `NavBarIcon` that uses `ScaleIn` animation to scale in a circular selection indicator from 0 to 1
- No text labels; circular background indicates selection
- Compact height: 70px + bottom safe area

**Android version:**
- Uses a **forked/modified** Material 3 `NavigationBar` (from `lib/widgets/framework/navigation_bar/navigation_bar.dart`)
- The fork is essentially a copy of Flutter's source with the same API -- they needed to customize the indicator animation
- Uses `easeInOutCubicEmphasized` curve for indicator scaling
- Height: 80px + bottom safe area
- Always shows labels (`alwaysShow` behavior)

**Customizable shortcuts:** All three primary nav bar icons (not "More") are customizable via long-press. Long-pressing any icon opens a bottom sheet (`SelectNavBarShortcutPopup`) where the user can reassign it to Home, Transactions, Budgets, Goals, All Spending, Subscriptions, Scheduled, or Loans.

### 2.3 Navigation Sidebar (Wide Screens)

When screen width exceeds 700px, the bottom nav bar disappears and a left sidebar (`NavigationSidebar`) appears.

**Features:**
- Collapsible: toggle between 270px expanded and 70px icon-only mode
- Collapse animation uses `AnimatedContainer` with 1500ms duration and `easeInOutCubicEmphasized` curve
- **Clock widget** in the expanded sidebar: shows current time, day, and date (updates every 5 seconds)
- Nested "Edit Data" section with animated expand/collapse (accounts, budgets, categories, titles, goals)
- Sync button at the bottom showing last sync time
- Selected item is highlighted with `secondaryContainer` background color

**Sidebar width calculation:**
```dart
double getWidthNavigationSidebar(BuildContext context) {
  if (MediaQuery.sizeOf(context).width < 700) return 0;  // No sidebar on phones
  if (!expanded) return 70 + leftSafeArea;
  return min(MediaQuery.sizeOf(context).width * 0.3, 270) + leftSafeArea;
}
```

### 2.4 FAB (Floating Action Button)

The FAB uses `OpenContainerNavigation` (from the `animations` package) for a Material container transform: when tapped, the FAB expands into the Add Transaction page with a smooth morphing animation.

- FAB size: 60px on phones, 70px on full-screen
- Border radius: 18px on phones, 22px on full-screen
- **Long press opens a "quick add" popup** (`AddMoreThingsPopup`) with shortcuts to add: Account, Transaction (with most-common-transactions chips), Loan, Goal, Budget, Category
- The FAB uses `AnimateFAB` which wraps it in `AnimatedSwitcher` with `FadeScaleTransitionButton` -- it scales in from 0.3 and fades in over 500ms with `easeInOutCubicEmphasized`
- Only visible on certain pages: `[0, 1, 2, 14]` (Home, Transactions, Budgets, Goals)

---

## 3. Animation Patterns

### 3.1 Animation Philosophy

Cashew has a sophisticated, three-tier animation system:

1. **Battery Saver mode:** All decorative animations are skipped. Widgets check `appStateSettings["batterySaver"]` and return the child directly without animation wrappers.
2. **Reduced animations:** `appStateSettings["appAnimations"]` has an `AppAnimations.all` enum. When not set to `all`, durations become `Duration.zero` and some animations are completely disabled.
3. **Full animations:** The default rich experience.

This is a considerate pattern -- every animation widget has a bailout path.

### 3.2 Core Animation Widgets

**FadeIn** -- Simple opacity animation from 0 to 1 over 500ms. Used for initial content appearance.

**ScaleIn** -- Elastic scale animation from 0 to 1 using `ElasticOutCurve(0.5)` over 1500ms. Supports optional delay and looping. The elastic curve gives a satisfying "pop" effect.

**AnimatedExpanded** -- The workhorse for show/hide animations. Combines `FadeTransition` + `SizeTransition` with `fastOutSlowIn` curve over 425ms. Used everywhere content conditionally appears (settings toggles, expanded sections, etc.).

**AnimatedSizeSwitcher** -- Wraps `AnimatedSize` + `AnimatedSwitcher` for widgets that change content and size simultaneously. Default size curve: `easeInOutCubicEmphasized` over 800ms; default switcher: 250ms.

**CountNumber** -- Animates numeric values (financial amounts) with `TweenAnimationBuilder<int>`. Uses `easeOutQuint` over 1000ms. Converts between int representations to avoid floating-point jitter during animation.

**BreathingWidget** -- Looping scale animation (1.0 to 1.3) over 3000ms with `Curves.ease`. Used for attention-drawing indicators.

**PinWheelReveal** -- A custom `ClipPath` animation that reveals content in a clockwise sweep (like a clock hand drawing a circle). Uses `easeInOutCubic` over 850ms. Used exclusively for pie chart reveals.

**InfiniteRotationAnimation** -- Continuous 360-degree rotation, used for loading/sync indicators.

**ShakeAnimation** -- Uses `ElasticInOutCurve(0.19)` for a physical "shake" effect. The delta displacement is computed as `0.3 * (0.5 - (0.5 - curve.transform(t)).abs())`.

**BouncingWidget** -- Vertical bounce using `ElasticOutCurve(0.6)` for forward and `Curves.bounceIn` for reverse. Used to draw attention to elements.

**AnimatedCircularProgress** -- Custom `CustomPainter`-based circular progress indicator. Animates from 0 to target using `easeInOutCubicEmphasized` over 2500ms. Supports overage visualization (spending more than 100% of a budget) with a shadow effect.

**CustomDelayedCurve** -- A custom `Curve` that stays at 0.0 for a configurable percentage of the animation duration, then applies the inner curve for the remainder. This creates a "wait, then animate" effect.

### 3.3 The "Snappy" Feel

The snappiness comes from three deliberate choices:

1. **Curve selection.** The dominant curve throughout the app is `Curves.easeInOutCubicEmphasized` -- a Material 3 curve that starts slow, accelerates aggressively, then settles with a satisfying deceleration. It is used for:
   - Sidebar expand/collapse (1500ms)
   - Tab switching indicators
   - FAB show/hide (500ms)
   - Size transitions (800ms)
   - Scroll-to-top (1200ms) -- with `elasticOut` on Android for a springy bounce

2. **Elastic curves for delight.** `ElasticOutCurve(0.5-0.6)` is used for:
   - Pie chart segment animations (1300ms swap animation)
   - Scale-in animations (1500ms)
   - Category badge pop-ins
   This gives objects a satisfying overshoot-and-settle.

3. **Short durations for interactions, long durations for reveals.** Tap feedback is 150-230ms (via `FadedButton`). Content reveals are 500-1500ms. This means the app responds instantly to touch but takes its time for visual storytelling.

### 3.4 Implicit vs Explicit Animations

The app uses **both** extensively:

**Implicit** (via `AnimatedFoo` or `TweenAnimationBuilder`):
- `AnimatedContainer` for sidebar width, padding changes
- `AnimatedRotation` for chevron expand indicators
- `AnimatedOpacity` for content reveal/hide
- `AnimatedScale` for pie chart badge pop-in
- `AnimatedPadding` for layout shifts
- `AnimatedSwitcher` throughout for content swaps with cross-fade
- `TweenAnimationBuilder` for number count-up, shake, clip rect

**Explicit** (via `AnimationController`):
- All `PageFramework` header animations (shift, opacity, drag)
- `FadedButton` (iOS tap feedback)
- `BreathingWidget`, `InfiniteRotationAnimation`
- `AnimatedCircularProgress` (custom painter)
- `PinWheelReveal` (clip path animation)

The general pattern: simple state-driven visibility uses implicit animations; complex multi-part sequences use explicit controllers.

### 3.5 Tappable: Platform-Adaptive Touch Feedback

`Tappable` is Cashew's universal tap handler, used by every interactive element.

**On Android/Web:**
- Uses `Material` + `InkWell` with `InkSparkle.constantTurbulenceSeedSplashFactory` (the ripple effect)
- Right-click (mouse) triggers `onLongPress`

**On iOS:**
- Uses custom `FadedButton` -- an opacity-based feedback that fades to 50% opacity on press (150ms ease-in) and recovers on release (230ms ease-out with `Curves.easeOutCubic`)
- Long press triggers `HapticFeedback.heavyImpact()` before the callback
- No ripple/splash effect at all

This is one of the biggest contributors to the app feeling "native" on each platform.

---

## 4. Chart & Data Visualization

### 4.1 Pie Chart

The pie chart is built on `fl_chart` (`PieChart`) but wrapped in substantial custom UI:

**Visual composition:**
- Three concentric layers in a `Stack`: the pie chart, a frosted glass-like semi-transparent circle (0.2 opacity), and a solid background circle in the center
- Chart size: 200x200 on phones, 300x300 on wide screens
- Center hole: 80px on phones, 110px on wide screens

**Reveal animation:** The entire pie chart is wrapped in `PinWheelReveal` -- it sweeps in clockwise over 850ms.

**Segment interaction:**
- Tap a segment to expand it (radius grows from 100 to 106, or 136 to 146 on wide screens)
- Category badges (icon + percentage label) pop in sequentially: after a 500ms initial delay, each badge appears with a 70ms stagger. This creates a cascade effect.
- The badge scale uses `ElasticOutCurve(0.6)` over 1300ms for the icon, and `easeInOutCubicEmphasized` over 700ms for hide/show
- `swapAnimationDuration: 1300ms` with `ElasticOutCurve(0.6)` for segment data changes

**Color handling:** Adjacent segments with the same category color get automatically differentiated -- every 3rd segment gets 20-35% more lightening/darkening applied via `dynamicPastel`.

### 4.2 Line Graph

Uses `fl_chart` (`LineChart`) with:
- 2000ms animation duration with `fastLinearToSlowEaseIn` curve for data transitions
- Initial "zoom in" effect: starts with compressed X range (70% narrower) and Y range offset, then animates to full data extent
- Touch tooltips for data point inspection
- Horizontal zero-line and optional target line (dashed)
- Date labels along the bottom axis

### 4.3 Heatmap (GitHub-style)

A fully custom implementation (no library) using `ListView.builder` in horizontal scroll:
- Each cell: 18x18px with 1.5px padding, 5px border radius
- Color intensity mapped to spending amount using a 4-bucket range index
- Income cells: green with varying opacity (0.5 to 1.0)
- Expense cells: red with varying opacity (0.5 to 1.0)
- Zero-spend days: neutral color at 0.6 opacity
- Tapping a cell opens a bottom sheet with that day's transactions
- Infinite scroll: scrolling to the end triggers `loadMoreMonths(1)` to load one more month of data
- Month labels appear every 4th week column

### 4.4 Bar Graph

Uses `fl_chart` (`BarChart`) -- referenced in the codebase but follows the same `dynamicPastel` color scheme and animation patterns as the line and pie charts.

---

## 5. Transaction Entry UX

### 5.1 Overview

`AddTransactionPage` at 5,207 lines is the most complex page. It handles creating and editing transactions, including regular, upcoming, recurring (subscription/repetitive), and credit/debt types.

### 5.2 State Management

All form state is managed as individual `setState` fields in the `_AddTransactionPageState` class -- about 25 separate state variables (category, subcategory, amount, title, type, date, end date, period, recurrence, income flag, payer, objective, budget, paid status, wallet, notes focus, etc.).

Each setter (e.g., `setSelectedCategory`, `setSelectedAmount`, `setSelectedIncome`) is a named method that handles side effects:
- Setting a category auto-sets income/expense based on the category's `income` flag
- Changing between credit and debt auto-flips income direction
- Changing transaction type auto-adjusts the `paid` status

### 5.3 The "Initial Add Transaction Sequence"

When adding a new transaction (`startInitialAddTransactionSequence = true`), the app launches a guided flow: category selection first, then amount input. This is a wizard-style UX that reduces cognitive load -- the user does not see the full form until they have picked the most important fields.

### 5.4 Saving Logic

Transaction saving is debounced with a `lockAddTransaction` boolean to prevent double-taps. After saving:
- The UI frame is allowed to complete (`SchedulerBinding.instance.endOfFrame`) before unlocking, ensuring smooth animation on dismissal
- The saved transaction triggers a "flash" highlight animation in the transactions list
- If the new transaction date is within 5 minutes of now, it gets a shorter flash (2 count); otherwise a full flash
- Balance transfer detection: if editing a transaction that was part of a pair (e.g., a transfer between accounts), a popup asks whether to update both sides

### 5.5 What Makes It Feel Smooth

Despite being enormous, the form stays responsive because:
1. **Lazy rendering.** Many sections use `AnimatedExpanded` and only appear when relevant (e.g., recurrence options only show when type is set to subscription/repetitive)
2. **No page transitions for sub-flows.** Category selection, amount input, and date picking use bottom sheets (`openBottomSheet`) which slide up without a full page push
3. **Immediate visual feedback.** Every setter calls `setState` so the form title, amount display, and category icon update in real-time
4. **Lock-and-wait pattern for save.** The save button cannot be double-tapped, and the app waits for the animation frame to complete before navigating away

---

## 6. Theming & Color System

### 6.1 Material 3 with Custom Color Logic

Cashew uses Material 3 (`useMaterial3: true`) with `ColorScheme.fromSeed()` -- but layers a significant custom color system on top.

**Theme generation flow:**
1. An accent color is stored in settings (user-selectable or system-derived)
2. `getColorScheme(brightness)` generates a `ColorScheme` from seed
3. `getAppColors()` generates a custom `AppColors` `ThemeExtension` with 14 named colors
4. Both are assembled in `generateThemeDataWithExtension()`

**The `AppColors` extension** provides semantic color names:
| Name | Light Mode | Dark Mode |
|------|-----------|-----------|
| `white` | `Colors.white` | `Colors.black` |
| `black` | `Colors.black` | `Colors.white` |
| `textLight` | Black @ 40% opacity | White @ 25% opacity |
| `incomeAmount` | Green `#59A849` | Green `#62CA77` |
| `expenseAmount` | Red `#CA5A5A` | Red `#DA7272` |
| `warningOrange` | Orange `#CA995A` | Orange `#DA9C72` |
| `starYellow` | `#FFD723` | `Colors.yellow` |
| `lightDarkAccent` | Lightened accent | Darkened accent |

Note the inverted `white`/`black` names: `getColor(context, "white")` returns white in light mode and black in dark mode, functioning as semantic "background" and "foreground" tokens.

### 6.2 Dynamic Pastel System

The most distinctive color function is `dynamicPastel()`:

```dart
Color dynamicPastel(BuildContext context, Color color, {
  double amount = 0.1,
  bool inverse = false,
  double? amountLight,
  double? amountDark,
})
```

This lightens a color in light mode and darkens it in dark mode (or vice versa if `inverse`). It uses `Color.alphaBlend` with white/black overlays. Nearly every colored surface in the app passes through this function, ensuring that category colors, chart segments, and UI accents all adapt gracefully to the current theme.

### 6.3 Material You Support

When `appStateSettings["materialYou"]` is true:
- Background colors become tinted with the accent color (light mode: 91% lightened; dark mode: 92% darkened)
- `secondaryContainer` is further blended for popups and bottom sheets
- Splash colors on tappable elements are computed from the accent color
- Navigation bar backgrounds use the `secondaryContainer` with 40-55% lightening/darkening

When false: plain whites/blacks are used for backgrounds.

### 6.4 System Color Integration

On supported Android devices (API 12+), the app reads the system accent color via the `system_theme` package. A special check prevents a Samsung bug where an unsupported device returns a default cyan.

### 6.5 Grayscale Color Scheme

If the user selects a grayscale accent color (detected by checking if R, G, B channels are within 15 of each other), a completely hand-crafted `ColorScheme` is used with `blueGrey` tones instead of `fromSeed()`, because `fromSeed()` produces ugly results with gray inputs.

### 6.6 Fonts

```dart
fontFamily: appStateSettings["font"],
fontFamilyFallback: ['Inter'],
```

The user can select from: Avenir, Inter, DMSans, Metropolis, RobotoCondensed, Inconsolata. Inter is always the fallback. A custom Icons font is included for the app-specific icon set.

Code blocks (error messages, debug output) use `Inconsolata` with monospace fallbacks.

---

## 7. Custom Widget Patterns

### 7.1 Bottom Sheet System

`openBottomSheet()` uses a **modified** `sliding_sheet` package (`sliding_sheet-0.5.2-modified`). Key behaviors:

- **Snap points:** On tall phones (aspect ratio > 2) and non-keyboard popups: snaps at 60% and 100%. On shorter devices or with keyboard: snaps at 95% and 100%.
- **Corner radius:** 10px on iOS, 20px on Android
- **Duration:** 300ms slide animation
- **Width:** Capped at 650px, centered on wide screens
- **Haptic feedback:** Heavy impact when the sheet reaches full expansion (on Android only, not iOS)
- **Theme inheritance:** The parent context's theme is passed through to the sheet content, handling the edge case where the sheet's builder context might have a default theme

### 7.2 Popup/Dialog System

`openPopup()` uses `showGeneralDialog` with custom transition:
- **Entry:** Scale from 0.95 to 1.0 with `easeInOutQuart` + fade
- **Exit:** Scale from 1.0 to 0.9 + fade
- **Duration:** 200ms both ways
- Background: 40% black barrier
- Max width: same as bottom sheet (650px)
- Border radius: 10px iOS, 25px Android

Button colors in popups are dynamically computed: primary buttons use a lightened primary color; cancel buttons use a lightened tertiary color. The exact blending depends on `materialYou` setting and brightness.

### 7.3 OpenContainerNavigation

The `AddFAB` and various "add" buttons use the Flutter `animations` package's `OpenContainer` for Material container transform. When the user taps the FAB, the button itself morphs into the destination page -- the bounds of the FAB become the bounds of the new page with a smooth animated expansion.

### 7.4 Pull Down to Refresh Sync

On the home page (and other root pages), pulling down triggers cloud sync (`runAllCloudFunctions`). This is implemented via `PullDownToRefreshSync` which wraps the scroll controller.

### 7.5 Swipe to Select Transactions

`SwipeToSelectTransactions` wraps page content and enables multi-select mode where users can swipe across transaction entries to select them. Selected transactions show a special app bar (`SelectedTransactionsAppBar`).

### 7.6 AnimatedSizeSwitcher: The Swiss Army Knife

This tiny widget (20 lines) is used in dozens of places:

```dart
AnimatedSize(
  duration: 800ms, curve: easeInOutCubicEmphasized,
  child: AnimatedSwitcher(duration: 250ms, child: child),
)
```

When the `child` changes (via its `key`), `AnimatedSwitcher` cross-fades and `AnimatedSize` smoothly resizes the container. This handles the common pattern of "this section might show different content or disappear entirely."

---

## 8. Home Page Composition

### 8.1 Architecture

The home page (`HomePage`) is a plain `ListView` (not a `CustomScrollView` with slivers). It contains a configurable, user-reorderable set of sections.

### 8.2 Section Registry

All sections are registered in a `Map<String, Widget?>`:

| Key | Widget | What It Shows |
|-----|--------|--------------|
| `wallets` | `HomePageWalletSwitcher` | Horizontal scrolling wallet cards |
| `walletsList` | `HomePageWalletList` | Vertical list of wallets |
| `budgets` | `HomePageBudgets` | Pinned budget progress cards |
| `overdueUpcoming` | `HomePageUpcomingTransactions` | Overdue/upcoming transaction alerts |
| `allSpendingSummary` | `HomePageAllSpendingSummary` | Summary of all spending |
| `netWorth` | `HomePageNetWorth` | Net worth display |
| `objectives` | `HomePageObjectives (goal)` | Savings goals progress |
| `creditDebts` | `HomePageCreditDebts` | Active credit/debt tracking |
| `objectiveLoans` | `HomePageObjectives (loan)` | Loan tracking |
| `spendingGraph` | `HomePageLineGraph` | Time-series spending line chart |
| `pieChart` | `HomePagePieChart` | Categorical spending breakdown |
| `heatMap` | `HomePageHeatMap` | GitHub-style spending heatmap |
| `transactionsList` | `HomeTransactions` | Recent transaction entries |

### 8.3 Section Ordering

Each section is independently toggle-able and reorderable via `appStateSettings["homePageOrder"]`. The "Edit Home" page (accessed via the `...` icon) lets users drag sections to reorder them.

### 8.4 Full-Screen (Wide) Layout

On wide screens (`enableDoubleColumn(context) == true`), sections are split into three groups:
1. **Center (full-width):** Sections listed before `ORDER:LEFT` marker
2. **Left column:** Sections after `ORDER:LEFT`
3. **Right column:** Sections after `ORDER:RIGHT`

Each column clips overflow with `LinearGradientFadedEdges` for a polished fade effect at the edges.

### 8.5 Welcome Banner

Two modes:
- **Large banner:** Shows a greeting message (time-of-day-based) and username with parallax scroll animation controlled by `_animationControllerHeader` and `_animationControllerHeader2`
- **Small banner:** A compact header row with username and greeting

### 8.6 Transaction List on Home

The home page's transaction list includes:
- A `SlidingSelectorIncomeExpense` (tab selector for All/Outgoing/Incoming)
- Long-pressing the selector opens settings for the home transactions list
- `HomeTransactions` component
- A "View All Transactions" button

The sliding selector can be customized to show just income/expense or all/outgoing/incoming.

### 8.7 Pie Chart Section

The home page pie chart (`HomePagePieChart`) is particularly sophisticated:
- On narrow screens: uses `ExpandablePageView` to swipe between outgoing and incoming pie charts, with a page indicator at the bottom and an income/expense arrow toggle in the top-right corner
- On wide screens (> 640px): shows both pie charts side-by-side
- Each pie chart includes a category legend (top 3-5 categories) when space permits
- Tapping a category slice expands a detailed `CategoryEntry` below the chart using `AnimatedSizeSwitcher`

### 8.8 Performance Optimizations

- Every section is wrapped in `KeepAliveClientMixin` to preserve state when off-screen
- `StreamBuilder` is used extensively for live database updates (transactions, categories, budgets)
- The page itself uses `ListView` (not `CustomScrollView`) for simpler composition -- the home page has no collapsing app bar

---

## 9. Summary of Key Patterns for Variance

### Patterns Worth Adopting:
1. **Platform-adaptive interaction layer** (`Tappable` with opacity on iOS, ripple on Android)
2. **Three-tier animation opt-out** (battery saver, reduced, full)
3. **`easeInOutCubicEmphasized` as the default curve** -- it is the Material 3 recommended curve and genuinely feels better than `easeInOut`
4. **`AnimatedSizeSwitcher`** for any content that may change or disappear
5. **Dynamic pastel color system** for making category/accent colors work in both light and dark modes
6. **Snap-based bottom sheets** instead of modal dialogs for content-heavy interactions
7. **Container transform for FAB** -- the morphing animation is a proven Material delight pattern
8. **Configurable, reorderable home page sections** -- gives users control without complexity

### Patterns to Improve Upon:
1. **5,207-line AddTransactionPage** -- this file is a maintenance hazard. The form should be decomposed into focused sub-widgets.
2. **String-based color lookup** (`getColor(context, "lightDarkAccent")`) -- this is fragile and lacks compile-time safety. An enum-based approach would be better.
3. **Global mutable state** (`appStateSettings` as a global map, 20+ `GlobalKey` variables) -- Variance should use a proper state management solution.
4. **No separation of concerns** -- UI, business logic, and data fetching are interleaved in widget classes. Variance should enforce clean architecture boundaries.
5. **Custom fork of `sliding_sheet` and `implicitly_animated_reorderable_list`** -- these are vendor-locked modifications. Variance should prefer packages that do not require forking or use composable alternatives.
